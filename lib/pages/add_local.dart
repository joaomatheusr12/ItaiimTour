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
  final TextEditingController _criadoporController =
      TextEditingController(text: "1");
  
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adicionar Local"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services),
            onPressed: _limparFormulario,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nomeController,
                        decoration: const InputDecoration(
                          labelText: "Nome do Local *",
                          prefixIcon: Icon(Icons.place),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Informe o nome'
                                : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descricaoController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Descrição *",
                          prefixIcon: Icon(Icons.description),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Informe a descrição'
                                : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _enderecoController,
                        decoration: const InputDecoration(
                          labelText: "Endereço *",
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        validator: (value) =>
                            value == null || value.isEmpty
                                ? 'Informe o endereço'
                                : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _linkImgController,
                        decoration: const InputDecoration(
                          labelText: "Link da Imagem",
                          prefixIcon: Icon(Icons.image),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _latitudeController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: "Latitude *",
                              ),
                              validator: (value) =>
                                  value == null || double.tryParse(value) == null
                                      ? 'Latitude inválida'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: _longitudeController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                labelText: "Longitude *",
                              ),
                              validator: (value) =>
                                  value == null || double.tryParse(value) == null
                                      ? 'Longitude inválida'
                                      : null,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _criadoporController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "ID do Criador *",
                        ),
                        validator: (value) =>
                            value == null || int.tryParse(value) == null
                                ? 'ID inválido'
                                : null,
                      ),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _adicionarLocal,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                                  "ADICIONAR LOCAL",
                                  style: TextStyle(fontSize: 18),
                                ),
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
    );
  }

  Future<void> _adicionarLocal() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('locais').add({
        'nome_local': _nomeController.text.trim(),
        'descricao': _descricaoController.text.trim(),
        'endereco': _enderecoController.text.trim(),
        'linkimg': _linkImgController.text.trim(),

        // 🔥 AVALIAÇÕES (INICIALIZADAS)
        'av_total': 0,
        'qntd_av': 0,
        'avaliacao_media': 0.0,

        'latitude': double.parse(_latitudeController.text),
        'longitude': double.parse(_longitudeController.text),
        'criadopor': int.parse(_criadoporController.text),
        'data_criacao': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Local adicionado com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erro: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _limparFormulario() {
    _nomeController.clear();
    _descricaoController.clear();
    _enderecoController.clear();
    _linkImgController.clear();
    _latitudeController.clear();
    _longitudeController.clear();
    _criadoporController.text = "1";
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
