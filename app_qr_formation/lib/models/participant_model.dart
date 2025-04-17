class Participant {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String dateNaissance;
  final String lieuNaissance;
  final String qrCode;
  final DateTime dateGenerationQr;
  final bool actif;
  final DateTime dateCreation;

  Participant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.dateNaissance,
    required this.lieuNaissance,
    required this.qrCode,
    required this.dateGenerationQr,
    required this.actif,
    required this.dateCreation,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      telephone: json['telephone'] ?? '',
      dateNaissance: json['date_naissance'] ?? '',
      lieuNaissance: json['lieu_naissance'] ?? '',
      qrCode: json['qr_code'],
      dateGenerationQr: DateTime.parse(json['date_generation_qr']),
      actif: json['actif'],
      dateCreation: DateTime.parse(json['date_creation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'date_naissance': dateNaissance,
      'lieu_naissance': lieuNaissance,
      'qr_code': qrCode,
      'date_generation_qr': dateGenerationQr.toIso8601String(),
      'actif': actif,
      'date_creation': dateCreation.toIso8601String(),
    };
  }
}
