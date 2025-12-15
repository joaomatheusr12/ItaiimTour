import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/local_model.dart';

class AvaliacaoPage extends StatefulWidget {
  final LocalModel local;

  const AvaliacaoPage({super.key, required this.local});

  @override
  State<AvaliacaoPage> createState() => _AvaliacaoPageState();
}

class _AvaliacaoPageState extends State<AvaliacaoPage> {
  double _avaliacao = 0;
  final TextEditingController _comentarioController = TextEditingController();

  String _mascararEmail(String email) {
    final partes = email.split('@');
    if (partes.length != 2) return email;

    final nome = partes[0];
    final dominio = partes[1];

    if (nome.length <= 2) {
      return '${nome[0]}***@$dominio';
    }

    return '${nome.substring(0, 2)}***@$dominio';
  }

  Future<void> _enviarAvaliacao() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para avaliar')),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final localRef = firestore.collection('locais').doc(widget.local.id);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(localRef);

      final int qntdAvAtual = snapshot['qntd_av'] ?? 0;
      final int avTotalAtual = snapshot['av_total'] ?? 0;

      final int novaQtd = qntdAvAtual + 1;
      final int novoAvTotal = avTotalAtual + _avaliacao.toInt();
      final double novaMedia = novoAvTotal / novaQtd;

      // Atualiza o local
      transaction.update(localRef, {
        'qntd_av': novaQtd,
        'av_total': novoAvTotal,
        'avaliacao_media': novaMedia,
      });

      // Salva comentário
      transaction.set(
        firestore.collection('comentarios').doc(),
        {
          'id_local': widget.local.id,
          'comentario': _comentarioController.text,
          'usuario': _mascararEmail(user.email!),
          'avaliacao': _avaliacao.toInt(),
          'data': Timestamp.now(),
        },
      );
    });

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Avaliação Enviada!"),
        content: const Text("Obrigado por avaliar este local."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

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
            // Imagem
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
              child: widget.local.linkimg.isEmpty
                  ? const Center(child: Text("Sem imagem"))
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.local.linkimg,
                        fit: BoxFit.cover,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            Text(
              widget.local.nomeLocal,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(widget.local.descricao),

            const SizedBox(height: 24),

            // Estrelas
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return GestureDetector(
                  onTap: () => setState(() => _avaliacao = star.toDouble()),
                  child: Icon(
                    star <= _avaliacao ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                );
              }),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _comentarioController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Digite seu comentário...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _avaliacao == 0 ? null : _enviarAvaliacao,
                child: const Text("ENVIAR AVALIAÇÃO"),
              ),
            ),

            const SizedBox(height: 32),

            const Text(
              "Avaliações:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('comentarios')
                  .where('id_local', isEqualTo: widget.local.id)
                  .orderBy('data', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("Nenhuma avaliação ainda."),
                  );
                }

                return Column(
                  children: snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        title: Text(data['usuario']),
                        subtitle: Text(data['comentario']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            data['avaliacao'],
                            (_) => const Icon(Icons.star,
                                size: 16, color: Colors.amber),
                          ),
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
