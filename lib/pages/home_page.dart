import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/local_model.dart';
import 'avaliacao_page.dart';
import 'add_local.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? categoriaSelecionada;

  void _checkAndNavigate(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    if (user.email == 'joao@gmail.com') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddLocalPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você não tem permissão para adicionar locais'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Stream<QuerySnapshot> _getLocaisStream() {
    final collection = FirebaseFirestore.instance.collection("locais");

    if (categoriaSelecionada == null) {
      return collection.snapshots();
    }

    return collection
        .where("categoria", isEqualTo: categoriaSelecionada)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Itaimtour",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.blue[800],
        actions: [
          // 🔑 BOTÃO LOGIN (NÃO LOGADO)
          if (user == null)
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text(
                "Login",
                style: TextStyle(color: Colors.white),
              ),
            ),

          // 🚪 BOTÃO LOGOUT (LOGADO)
          if (user != null)
            TextButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Logout realizado com sucesso"),
                      backgroundColor: Colors.green,
                    ),
                  );
                  setState(() {});
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Sair",
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // -------------------- CATEGORIAS -------------------- //
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("locais").snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox();

              final categorias = snapshot.data!.docs
                  .map((doc) => doc['categoria'] as String)
                  .toSet()
                  .toList()
                ..sort();

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text("Todos"),
                      selected: categoriaSelecionada == null,
                      onSelected: (_) {
                        setState(() {
                          categoriaSelecionada = null;
                        });
                      },
                    ),
                    ...categorias.map(
                      (categoria) => ChoiceChip(
                        label: Text(categoria),
                        selected: categoriaSelecionada == categoria,
                        onSelected: (_) {
                          setState(() {
                            categoriaSelecionada = categoria;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 10),

          // -------------------- LISTA DE LOCAIS -------------------- //
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getLocaisStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nenhum local encontrado",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final locais = snapshot.data!.docs.map((doc) {
                  return LocalModel.fromFirestore(
                    doc.id,
                    doc.data() as Map<String, dynamic>,
                  );
                }).toList();

                return ListView.builder(
                  itemCount: locais.length,
                  itemBuilder: (context, index) {
                    final local = locais[index];

                    final media = local.qntdAv > 0
                        ? local.avTotal / local.qntdAv
                        : 0.0;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AvaliacaoPage(local: local),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImage(local.linkimg),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    local.nomeLocal,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(local.descricao),
                                  const SizedBox(height: 8),
                                  Text(
                                    local.endereco,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.star,
                                          color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text(media.toStringAsFixed(1)),
                                      const SizedBox(width: 8),
                                      Text(
                                        "(${local.qntdAv})",
                                        style: const TextStyle(
                                            color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => _checkAndNavigate(context),
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildImage(String url) {
    if (url.isEmpty) {
      return Container(
        height: 200,
        color: Colors.grey[300],
        child: const Center(child: Icon(Icons.photo)),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Image.network(
        url,
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
