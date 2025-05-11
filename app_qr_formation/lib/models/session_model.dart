class Session {
  final int id;
  final String titre;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String lieu;
  final String salle;

  Session({
    required this.id,
    required this.titre,
    required this.dateDebut,
    required this.dateFin,
    required this.lieu,
    required this.salle,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      id: json['id'],
      titre: json['titre'] ?? '',
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      lieu: json['lieu'] ?? '',
      salle: json['salle'] ?? '',
    );
  }
}
