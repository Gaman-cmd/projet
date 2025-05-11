class Attendance {
  final int id;
  final int seance;
  final int participant;
  final String statut;
  final DateTime dateScan;

  Attendance({
    required this.id,
    required this.seance,
    required this.participant,
    required this.statut,
    required this.dateScan,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      seance: json['seance'],
      participant: json['participant'],
      statut: json['statut'],
      dateScan: DateTime.parse(json['date_scan']),
    );
  }
}
