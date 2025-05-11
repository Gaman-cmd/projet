class Participant {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String? dateNaissance;
  final String? lieuNaissance;
  final String? qrCode;
  final DateTime? dateGenerationQr;
  final bool actif;
  final DateTime dateCreation;

  Participant({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.dateNaissance,
    this.lieuNaissance,
    this.qrCode,
    this.dateGenerationQr,
    required this.actif,
    required this.dateCreation,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      id: json['id'],
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      dateNaissance: json['date_naissance'],
      lieuNaissance: json['lieu_naissance'],
      qrCode: json['qr_code'],
      dateGenerationQr:
          json['date_generation_qr'] != null
              ? DateTime.tryParse(json['date_generation_qr'])
              : null,
      actif: json['actif'] ?? false,
      dateCreation: DateTime.parse(json['date_creation']),
    );
  }
}
