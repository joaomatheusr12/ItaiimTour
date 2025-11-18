import 'package:flutter/material.dart';
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
            // Imagem do local
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
              child: widget.local.linkimg.isEmpty
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_camera, size: 60, color: Colors.grey),
                        SizedBox(height: 8),
                        Text("Sem imagem", style: TextStyle(color: Colors.grey)),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        widget.local.linkimg,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 60, color: Colors.red),
                              SizedBox(height: 8),
                              Text("Erro ao carregar imagem", style: TextStyle(color: Colors.red)),
                            ],
                          );
                        },
                      ),
                    ),
            ),
            
            const SizedBox(height: 24),
            
            // Nome do local
            Text(
              widget.local.nomeLocal,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Descrição
            Text(
              widget.local.descricao,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Avaliação com estrelas
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Avalie este local:",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Estrelas interativas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _avaliacao = starIndex.toDouble();
                            });
                          },
                          child: Icon(
                            starIndex <= _avaliacao
                                ? Icons.star
                                : Icons.star_border,
                            size: 40,
                            color: Colors.amber,
                          ),
                        );
                      }),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      _avaliacao == 0 
                          ? "Toque nas estrelas para avaliar"
                          : "Sua avaliação: $_avaliacao estrela${_avaliacao > 1 ? 's' : ''}",
                      style: TextStyle(
                        fontSize: 16,
                        color: _avaliacao == 0 ? Colors.grey : Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Comentário
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Comentário (opcional):",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _comentarioController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Digite seu comentário sobre este local...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Botão de enviar avaliação
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _avaliacao == 0 
                    ? null
                    : () {
                        _enviarAvaliacao();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text(
                  "ENVIAR AVALIAÇÃO",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Botão cancelar
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[400]!),
                ),
                child: const Text(
                  "CANCELAR",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _enviarAvaliacao() {
    // Aqui você pode implementar a lógica para salvar no Firebase
    // Por enquanto, vamos apenas mostrar um feedback e voltar
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Avaliação Enviada!"),
        content: Text(
          "Você avaliou ${widget.local.nomeLocal} com $_avaliacao estrela${_avaliacao > 1 ? 's' : ''}",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha o dialog
              Navigator.pop(context); // Volta para a página anterior
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
    
    // TODO: Implementar salvamento no Firebase
    // FirebaseFirestore.instance.collection('avaliacoes').add({
    //   'localId': widget.local.id,
    //   'avaliacao': _avaliacao,
    //   'comentario': _comentarioController.text,
    //   'data': DateTime.now(),
    // });
  }

  @override
  void dispose() {
    _comentarioController.dispose();
    super.dispose();
  }
}