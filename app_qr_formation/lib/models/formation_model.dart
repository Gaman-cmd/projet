class Formation {
  final String titre;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String lieu;
  final int placesTotal;
  final int placesReservees;
  final String contactEmail;
  final String imageUrl;
  final String statut;

  Formation({
    required this.titre,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.lieu,
    required this.placesTotal,
    required this.placesReservees,
    required this.contactEmail,
    this.imageUrl = '',
    required this.statut,
  });

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      lieu: json['lieu'] ?? '',
      placesTotal: json['places_total'] ?? 0,
      placesReservees: json['places_reservees'] ?? 0,
      contactEmail: json['contact_email'] ?? '',
      imageUrl: json['image_url'] ?? '',
      statut: json['statut'] ?? 'a_venir',
    );
  }
}
