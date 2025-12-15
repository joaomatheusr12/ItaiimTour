class ComentarioModel {
  final String idLocal;
  final String texto;
  final String usuario;

  ComentarioModel({
    required this.idLocal,
    required this.texto,
    required this.usuario,
  });

  /// Converte o model para Map (para salvar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'id_local': idLocal,
      'texto': texto,
      'usuario': usuario,
    };
  }

  /// Cria o model a partir de um Map (vem do Firestore)
  factory ComentarioModel.fromMap(Map<String, dynamic> map) {
    return ComentarioModel(
      idLocal: map['id_local'] ?? '',
      texto: map['texto'] ?? '',
      usuario: map['usuario'] ?? '',
    );
  }
}
