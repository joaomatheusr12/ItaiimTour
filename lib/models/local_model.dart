class LocalModel {
  final String id;
  final String nomeLocal;
  final String descricao;
  final String endereco;
  final String linkimg;
  final double avaliacaoMedia;
  final double latitude;
  final double longitude;
  final int criadopor;

  LocalModel({
    required this.id,
    required this.nomeLocal,
    required this.descricao,
    required this.endereco,
    required this.linkimg,
    required this.avaliacaoMedia,
    required this.latitude,
    required this.longitude,
    required this.criadopor,
  });

  factory LocalModel.fromFirestore(String id, Map<String, dynamic> data) {
    return LocalModel(
      id: id,
      nomeLocal: data['nome_local'] ?? '',
      descricao: data['descricao'] ?? '',
      endereco: data['endereco'] ?? '',
      linkimg: data['linkimg'] ?? '',
      avaliacaoMedia: (data['avaliacao_media'] ?? 0).toDouble(),
      latitude: (data['latitude'] ?? 0).toDouble(),
      longitude: (data['longitude'] ?? 0).toDouble(),
      criadopor: (data['criadopor'] ?? 0),
    );
  }
}