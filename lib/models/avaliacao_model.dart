import 'package:cloud_firestore/cloud_firestore.dart';

class AvaliacaoModel {
  final int avaliacao; // nota (ex: 5)
  final String comentario;
  final Timestamp data;
  final int idAvaliacao;
  final String idLocal;
  final String idUsuario;

  AvaliacaoModel({
    required this.avaliacao,
    required this.comentario,
    required this.data,
    required this.idAvaliacao,
    required this.idLocal,
    required this.idUsuario,
  });

  /// Converte para Map (salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'avaliacao': avaliacao,
      'comentario': comentario,
      'data': data,
      'id_avaliacao': idAvaliacao,
      'id_local': idLocal,
      'id_usuario': idUsuario,
    };
  }

  /// Cria o model a partir do Firestore
  factory AvaliacaoModel.fromMap(Map<String, dynamic> map) {
    return AvaliacaoModel(
      avaliacao: map['avaliacao'] ?? 0,
      comentario: map['comentario'] ?? '',
      data: map['data'] ?? Timestamp.now(),
      idAvaliacao: map['id_avaliacao'] ?? 0,
      idLocal: map['id_local'] ?? '',
      idUsuario: map['id_usuario'] ?? '',
    );
  }
}
