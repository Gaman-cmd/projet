class User {
  final int id;
  final String nom;
  final String prenom;

  User({required this.id, required this.nom, required this.prenom});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(id: json['id'], nom: json['nom'], prenom: json['prenom']);
  }
}
