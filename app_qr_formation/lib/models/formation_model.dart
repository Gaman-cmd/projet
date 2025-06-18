class Formation {
  final int id; // Assurez-vous que c'est un int
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
  final Map<String, dynamic>? formateur; // Ajoute cet attribut
  final int nombreParticipantsAcceptes;

  Formation({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.lieu,
    required this.placesTotal,
    required this.placesReservees,
    required this.contactEmail,
    required this.imageUrl,
    required this.statut,
    this.formateur, // Ajoute ce paramètre
    required this.nombreParticipantsAcceptes,
  });

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: json['id'], // Assurez-vous que c'est un int dans l'API
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      lieu: json['lieu'] ?? '',
      placesTotal: json['places_total'] ?? 0,
      placesReservees:
          json['participants_acceptes'] ?? 0, // Modifie cette ligne
      contactEmail: json['contact_email'] ?? '',
      imageUrl: json['image_url'] ?? '', // <-- pas json['image_url'].toString()
      statut: json['statut'] ?? 'a_venir',
      formateur: json['formateur'], // Ajoute cette ligne
      nombreParticipantsAcceptes: json['nombre_participants_acceptes'] ?? 0,
    );
  }
}

extension FormationStatus on Formation {
  String get statutAuto {
    final now = DateTime.now();
    if (now.isBefore(dateDebut)) {
      return 'a_venir';
    } else if (now.isAfter(dateFin)) {
      return 'terminee';
    } else {
      return 'en_cours';
    }
  }
}
