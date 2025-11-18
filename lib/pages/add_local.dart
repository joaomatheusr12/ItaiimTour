import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddLocalPage extends StatefulWidget {
  const AddLocalPage({super.key});

  @override
  State<AddLocalPage> createState() => _AddLocalPageState();
}

class _AddLocalPageState extends State<AddLocalPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Controladores para os campos
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _enderecoController = TextEditingController();
  final TextEditingController _linkImgController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _criadoporController = TextEditingController(text: "1"); // Valor padrão como número
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Local"),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _limparFormulario,
            tooltip: "Limpar formulário",
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card do formulário
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Nome do Local
                      TextFormField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          labelText: "Nome do Local *",
                          prefixIcon: Icon(Icons.place, color: Colors.blue[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o nome do local';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Descrição
                      TextFormField(
                        controller: _descricaoController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: "Descrição *",
                          prefixIcon: Icon(Icons.description, color: Colors.blue[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira uma descrição';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Endereço
                      TextFormField(
                        controller: _enderecoController,
                        decoration: InputDecoration(
                          labelText: "Endereço *",
                          prefixIcon: Icon(Icons.location_on, color: Colors.blue[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o endereço';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Link da Imagem
                      TextFormField(
                        controller: _linkImgController,
                        decoration: InputDecoration(
                          labelText: "Link da Imagem",
                          prefixIcon: Icon(Icons.image, color: Colors.blue[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          hintText: "https://exemplo.com/imagem.jpg",
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Coordenadas
                      Row(
                        children: [
                          // Latitude
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: "Latitude *",
                                prefixIcon: Icon(Icons.explore, color: Colors.blue[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Insira a latitude';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Latitude inválida';
                                }
                                return null;
                              },
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          // Longitude
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              decoration: InputDecoration(
                                labelText: "Longitude *",
                                prefixIcon: Icon(Icons.explore, color: Colors.blue[700]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Insira a longitude';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Longitude inválida';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Criado por (número)
                      TextFormField(
                        controller: _criadoporController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "ID do Criador *",
                          prefixIcon: Icon(Icons.person, color: Colors.blue[700]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.blue[700]!, width: 2),
                          ),
                          hintText: "1",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Insira um ID numérico';
                          }
                          if (int.tryParse(value) == null) {
                            return 'ID deve ser um número';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Botão de Adicionar
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _adicionarLocal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline),
                                    SizedBox(width: 8),
                                    Text(
                                      "ADICIONAR LOCAL",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Informações sobre campos obrigatórios
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Campos marcados com * são obrigatórios. "
                          "Avaliação média será definida como 0 automaticamente. "
                          "ID do Criador deve ser um número inteiro.",
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Exemplo de coordenadas para São Paulo
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  _latitudeController.text = "-23.5505";
                  _longitudeController.text = "-46.6333";
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Coordenadas de São Paulo preenchidas!"),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Card(
                  color: Colors.grey[100],
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "💡 Toque aqui para preencher com coordenadas de exemplo (São Paulo)",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _adicionarLocal() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _firestore.collection('locais').add({
        'nome_local': _nomeController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'linkimg': _linkImgController.text.trim(),
        'avaliacao_media': 0.0, // Number
        'latitude': double.parse(_latitudeController.text), // Number
        'longitude': double.parse(_longitudeController.text), // Number
        'criadopor': int.parse(_criadoporController.text), // Number (corrigido)
        'data_criacao': FieldValue.serverTimestamp(),
      });

      // Sucesso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Local adicionado com sucesso!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        
        // Volta para a home após sucesso
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao adicionar local: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _limparFormulario() {
    _nomeController.clear();
    _descricaoController.clear();
    _enderecoController.clear();
    _linkImgController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _criadoporController.text = "1"; // Reseta para valor padrão
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Formulário limpo!"),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    _linkImgController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _criadoporController.dispose();
    super.dispose();
  }
}