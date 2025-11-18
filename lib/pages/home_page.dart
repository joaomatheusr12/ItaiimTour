import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/local_model.dart';
import 'avaliacao_page.dart';
import 'add_local.dart'; // Importe a nova página

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _checkAndNavigate(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user?.email == 'joao@gmail.com') {
      // Usuário autorizado - vai para a página de adicionar local
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AddLocalPage()),
      );
    } else {
      // Usuário não autorizado - mostra mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Você não tem permissão para adicionar locais'),
          backgroundColor: Colors.red[800],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.explore, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "Itaimtour",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue[800],
        elevation: 4,
      ),
      body: Stack(
        children: [
          // Conteúdo principal da lista
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("locais").snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "Carregando locais...",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        "Nenhum local encontrado",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              final locais = docs.map((doc) {
                return LocalModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>);
              }).toList();

              return ListView.builder(
                itemCount: locais.length,
                itemBuilder: (context, index) {
                  final local = locais[index];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AvaliacaoPage(local: local),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildImageWidget(local.linkimg),
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
                                      color: Colors.blueGrey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    local.descricao,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        size: 18,
                                        color: Colors.red[400],
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          local.endereco,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.star, color: Colors.amber[600], size: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        local.avaliacaoMedia.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        "(${local.avaliacaoMedia})",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey[400],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // Botão flutuante do +
          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton(
              onPressed: () => _checkAndNavigate(context),
              backgroundColor: Colors.blue[800],
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.add, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageWidget(String imageUrl) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        color: Colors.grey[200],
      ),
      child: imageUrl.isEmpty
          ? _buildPlaceholder()
          : ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return _buildErrorWidget();
                },
              ),
            ),
    );
  }

  Widget _buildPlaceholder() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.photo_camera, size: 50, color: Colors.grey),
        SizedBox(height: 8),
        Text(
          "Sem imagem",
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildErrorWidget() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 50, color: Colors.red),
        SizedBox(height: 8),
        Text(
          "Erro ao carregar",
          style: TextStyle(color: Colors.red),
        ),
      ],
    );
  }
}