import 'package:cloud_firestore/cloud_firestore.dart';

class LocalModel {
  final String id;
  final String nomeLocal;
  final String descricao;
  final String endereco;
  final String linkimg;
  final double avaliacaoMedia;
  final int qntdAv;
  final int avTotal; // 🔹 NOVO CAMPO
  final double latitude;
  final double longitude;
  final int criadopor;
  final String categoria;
  final Timestamp dataCriacao;

  LocalModel({
    required this.id,
    required this.nomeLocal,
    required this.descricao,
    required this.endereco,
    required this.linkimg,
    required this.avaliacaoMedia,
    required this.qntdAv,
    required this.avTotal, // 🔹 NOVO CAMPO
    required this.latitude,
    required this.longitude,
    required this.criadopor,
    required this.categoria,
    required this.dataCriacao,
  });

  /// 🔹 Converter para Map (salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'nome_local': nomeLocal,
      'descricao': descricao,
      'endereco': endereco,
      'linkimg': linkimg,
      'avaliacao_media': avaliacaoMedia,
      'qntd_av': qntdAv,
      'av_total': avTotal, // 🔹 NOVO CAMPO
      'latitude': latitude,
      'longitude': longitude,
      'criadopor': criadopor,
      'categoria': categoria,
      'data_criacao': dataCriacao,
    };
  }

  /// 🔹 Criar model a partir do Firestore
  factory LocalModel.fromFirestore(String id, Map<String, dynamic> data) {
    return LocalModel(
      id: id,
      nomeLocal: data['nome_local'] ?? '',
      descricao: data['descricao'] ?? '',
      endereco: data['endereco'] ?? '',
      linkimg: data['linkimg'] ?? '',
      avaliacaoMedia: (data['avaliacao_media'] ?? 0).toDouble(),
      qntdAv: data['qntd_av'] ?? 0,
      avTotal: data['av_total'] ?? 0, // 🔹 NOVO CAMPO
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      criadopor: data['criadopor'] ?? 0,
      categoria: data['categoria'] ?? '',
      dataCriacao: data['data_criacao'] ?? Timestamp.now(),
    );
  }
}
