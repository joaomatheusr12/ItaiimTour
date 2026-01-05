import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../models/local_model.dart';

class AvaliacaoPage extends StatefulWidget {
  final LocalModel local;

  const AvaliacaoPage({super.key, required this.local});

  @override
  State<AvaliacaoPage> createState() => _AvaliacaoPageState();
}

class _AvaliacaoPageState extends State<AvaliacaoPage> {
  // ===== AVALIAÇÃO =====
  double _avaliacao = 0;
  final TextEditingController _comentarioController =
      TextEditingController();

  // ===== MAPA / ROTA =====
  LatLng? _origem;
  late LatLng _destino;
  List<LatLng> _rota = [];
  bool _carregandoMapa = true;

  // ==============================
  // INIT
  // ==============================
  @override
  void initState() {
    super.initState();

    _destino = LatLng(
      widget.local.latitude,
      widget.local.longitude,
    );

    _carregarMapa();
  }

  // ==============================
  // LOCALIZAÇÃO ATUAL
  // ==============================
  Future<LatLng> _getLocalizacaoAtual() async {
    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    final posicao = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(posicao.latitude, posicao.longitude);
  }

  // ==============================
  // BUSCAR ROTA (OSRM)
  // ==============================
  Future<List<LatLng>> _getRota(
    LatLng origem,
    LatLng destino,
  ) async {
    final url =
        'https://router.project-osrm.org/route/v1/driving/'
        '${origem.longitude},${origem.latitude};'
        '${destino.longitude},${destino.latitude}'
        '?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));
    final data = jsonDecode(response.body);

    final coords =
        data['routes'][0]['geometry']['coordinates'];

    return coords
        .map<LatLng>((c) => LatLng(c[1], c[0]))
        .toList();
  }

  Future<void> _carregarMapa() async {
    try {
      _origem = await _getLocalizacaoAtual();
      _rota = await _getRota(_origem!, _destino);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _carregandoMapa = false;
      });
    }
  }

  // ==============================
  // FUNÇÃO PARA FORMATAR DATA
  // ==============================
  String _formatarData(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // ==============================
  // AVALIAÇÃO
  // ==============================
  Future<void> _enviarAvaliacao() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Faça login para avaliar")),
      );
      return;
    }

    if (_comentarioController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um comentário")),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final localRef = firestore.collection('locais').doc(widget.local.id);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(localRef);

      final int qntdAvAtual = (snapshot.data()?['qntd_av'] ?? 0) as int;
      final int avTotalAtual = (snapshot.data()?['av_total'] ?? 0) as int;

      transaction.update(localRef, {
        'qntd_av': qntdAvAtual + 1,
        'av_total': avTotalAtual + _avaliacao.toInt(),
      });

      transaction.set(
        firestore.collection('avaliacoes').doc(),
        {
          'id_local': widget.local.id,
          'id_usuario': user.uid,
          'email_usuario': user.email, // Email completo
          'avaliacao': _avaliacao.toInt(),
          'comentario': _comentarioController.text.trim(),
          'data': Timestamp.now(),
        },
      );
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Avaliação enviada com sucesso"),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context);
  }

  // ==============================
  // UI
  // ==============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Avaliar Local"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// NOME DO LOCAL
            Text(
              widget.local.nomeLocal,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// MAPA COM ROTA
            SizedBox(
              height: 250,
              child: _carregandoMapa
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: _origem ?? _destino,
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'com.exemplo.app',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: _rota,
                              strokeWidth: 5,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            if (_origem != null)
                              Marker(
                                point: _origem!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.green,
                                ),
                              ),
                            Marker(
                              point: _destino,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            /// ESTRELAS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final star = i + 1;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _avaliacao = star.toDouble()),
                  child: Icon(
                    star <= _avaliacao
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            /// COMENTÁRIO
            TextField(
              controller: _comentarioController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Digite seu comentário",
              ),
            ),

            const SizedBox(height: 16),

            /// BOTÃO
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    _avaliacao == 0 ? null : _enviarAvaliacao,
                child: const Text("ENVIAR AVALIAÇÃO"),
              ),
            ),

            const SizedBox(height: 24),

            /// LISTA DE AVALIAÇÕES
            const Text(
              "Avaliações",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('avaliacoes')
                  .where('id_local', isEqualTo: widget.local.id)
                  .orderBy('data', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Nenhuma avaliação ainda.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Email do usuário
                            Text(
                              data['email_usuario'] ?? 'Usuário anônimo',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Estrelas da avaliação
                            Row(
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  size: 18,
                                  color: index < (data['avaliacao'] ?? 0)
                                      ? Colors.amber
                                      : Colors.grey[300],
                                ),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Comentário
                            Text(
                              data['comentario'],
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Data da avaliação
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                _formatarData(data['data']),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }
}