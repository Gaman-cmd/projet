import 'package:flutter/material.dart';
import 'formation_detail_page.dart';
import 'models/formation_model.dart';
import 'services/formation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Pour formater les dates

// Utiliser les mêmes couleurs AUF définies dans la page d'accueil
class AUFColors {
  static const primary = Color(0xFFB2122B); // Rouge bordeaux AUF
  static const secondary = Color(0xFF333333); // Gris foncé pour le texte
  static const accent1 = Color(0xFF8BC34A); // Vert (cercle du logo)
  static const accent2 = Color(0xFF673AB7); // Violet (cercle du logo)
  static const accent3 = Color(0xFFFFD600); // Jaune (cercle du logo)
  static const accent4 = Color(0xFF03A9F4); // Bleu (cercle du logo)
  static const backgroundLight = Color(0xFFF5F5F5); // Fond clair
  static const cardBackground = Colors.white; // Fond des cartes
}

class FormationsAVenirPage extends StatefulWidget {
  const FormationsAVenirPage({super.key});

  @override
  _FormationsAVenirPageState createState() => _FormationsAVenirPageState();
}

class _FormationsAVenirPageState extends State<FormationsAVenirPage>
    with SingleTickerProviderStateMixin {
  List<Formation> _formations = [];
  bool _isLoading = true;
  String? _error;
  final TextEditingController _searchController = TextEditingController();
  List<Formation> _filteredFormations = [];
  AnimationController? _animationController;

  // Pour trier les formations
  String _sortBy = "date"; // Options: "date", "titre", "lieu"
  bool _showFilters = false;
  String? _selectedCategory;
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _loadFormations();
    _searchController.addListener(_filterFormations);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController?.dispose();
    super.dispose();
  }

  void _filterFormations() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _filteredFormations = List.from(_formations);
      });
    } else {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredFormations =
            _formations.where((formation) {
              return formation.titre.toLowerCase().contains(query) ||
                  formation.description.toLowerCase().contains(query) ||
                  formation.lieu.toLowerCase().contains(query);
            }).toList();
      });
    }

    // Appliquer le tri
    _sortFormations();

    // Filtrer par catégorie si sélectionnée
    if (_selectedCategory != null && _selectedCategory != "Toutes") {
      setState(() {
        _filteredFormations =
            _filteredFormations.where((formation) {
              // Supposons que Formation a une propriété categorie
              // Adaptez selon votre modèle de données réel
              return formation.categorie == _selectedCategory;
            }).toList();
      });
    }
  }

  void _sortFormations() {
    setState(() {
      switch (_sortBy) {
        case "date":
          _filteredFormations.sort(
            (a, b) => a.dateDebut.compareTo(b.dateDebut),
          );
          break;
        case "titre":
          _filteredFormations.sort((a, b) => a.titre.compareTo(b.titre));
          break;
        case "lieu":
          _filteredFormations.sort((a, b) => a.lieu.compareTo(b.lieu));
          break;
      }
    });
  }

  Future<void> _loadFormations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/formations/formations_a_venir/'),
        headers: {"Content-Type": "application/json"},
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        List<Formation> loadedFormations =
            jsonData.map((data) => Formation.fromJson(data)).toList();

        // Extraire les catégories uniques
        Set<String> categoriesSet = Set();
        for (var formation in loadedFormations) {
          // Supposons que Formation a une propriété categorie
          // Si ce n'est pas le cas, ajustez selon votre modèle
          if (formation.categorie != null && formation.categorie.isNotEmpty) {
            categoriesSet.add(formation.categorie);
          }
        }

        setState(() {
          _formations = loadedFormations;
          _filteredFormations = List.from(loadedFormations);
          _isLoading = false;
          _categories = ["Toutes", ...categoriesSet.toList()];
        });
      } else {
        setState(() {
          _error = "Erreur lors du chargement des formations";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Erreur de connexion: $e";
        _isLoading = false;
      });
    }
  }

  Future<void> _inscrireAFormation(int formationId) async {
    try {
      // Afficher un indicateur de chargement
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AUFColors.primary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text("Inscription en cours..."),
                ],
              ),
            ),
          );
        },
      );

      // Récupérer l'ID du participant
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? participantId = prefs.getInt('participant_id');
      if (participantId == null) {
        Navigator.of(context).pop(); // Fermer le dialogue de chargement
        _showSnackBar("Impossible de trouver l'utilisateur connecté", true);
        return;
      }

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/inscription/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "participant_id": participantId,
          "formation_id": formationId,
        }),
      );

      // Fermer la boîte de dialogue de chargement
      Navigator.of(context).pop();

      if (response.statusCode == 201) {
        _showSnackBar("Demande d'inscription envoyée avec succès!", false);
      } else {
        final data = jsonDecode(response.body);
        _showSnackBar(data['error'] ?? "Erreur lors de l'inscription", true);
      }
    } catch (e) {
      // Fermer la boîte de dialogue de chargement en cas d'erreur
      Navigator.of(context).pop();
      _showSnackBar("Erreur lors de l'inscription: $e", true);
    }
  }

  void _showSnackBar(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : AUFColors.accent1,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(12),
        duration: Duration(seconds: isError ? 6 : 3),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Widget _buildFormationCard(Formation formation) {
    // Formater les dates pour un affichage plus agréable
    final dateFormat = DateFormat('dd MMM yyyy', 'fr_FR');

    // Générer une couleur de thème pseudo-aléatoire basée sur le titre
    final int hashCode = formation.titre.hashCode;
    final List<Color> themeColors = [
      AUFColors.accent1,
      AUFColors.accent2,
      AUFColors.accent3,
      AUFColors.accent4,
    ];
    final Color themeColor = themeColors[hashCode % themeColors.length];

    return Hero(
      tag: 'formation-${formation.id}',
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        FormationDetailPage(formationId: formation.id),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  var begin = Offset(0.0, 0.05);
                  var end = Offset.zero;
                  var curve = Curves.easeInOut;
                  var tween = Tween(
                    begin: begin,
                    end: end,
                  ).chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec bannière colorée
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informations de date et lieu
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "${dateFormat.format(formation.dateDebut)} - ${dateFormat.format(formation.dateFin)}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(width: 16),
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            formation.lieu,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Titre de la formation
                    Text(
                      formation.titre,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AUFColors.secondary,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Description abrégée
                    Text(
                      formation.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(height: 16),

                    // Ligne de séparation
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: Colors.grey.shade200,
                    ),
                    SizedBox(height: 16),

                    // Boutons d'action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OutlinedButton.icon(
                          icon: Icon(Icons.info_outline),
                          label: Text("Détails"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AUFColors.secondary,
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => FormationDetailPage(
                                      formationId: formation.id,
                                    ),
                              ),
                            );
                          },
                        ),
                        ElevatedButton.icon(
                          icon: Icon(Icons.add),
                          label: Text("S'inscrire"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () => _inscrireAFormation(formation.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: AUFColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school_outlined,
              size: 64,
              color: AUFColors.primary,
            ),
          ),
          SizedBox(height: 24),
          Text(
            "Aucune formation disponible",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AUFColors.secondary,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              "Désolé, il n'y a pas encore de formations à venir. Revenez vérifier plus tard.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton.icon(
            icon: Icon(Icons.refresh),
            label: Text("Actualiser"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AUFColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: _loadFormations,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Formations à venir",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AUFColors.secondary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            "Découvrez nos prochaines sessions de formation disponibles",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          SizedBox(height: 16),

          // Barre de recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Rechercher une formation...",
              prefixIcon: Icon(Icons.search, color: AUFColors.primary),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AUFColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
          ),
          SizedBox(height: 16),

          // Filtres et tri
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                icon: Icon(
                  _showFilters ? Icons.filter_list_off : Icons.filter_list,
                ),
                label: Text(_showFilters ? "Masquer filtres" : "Filtres"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AUFColors.secondary,
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _showFilters = !_showFilters;
                    if (_showFilters) {
                      _animationController!.forward();
                    } else {
                      _animationController!.reverse();
                    }
                  });
                },
              ),
              DropdownButton<String>(
                value: _sortBy,
                icon: Icon(Icons.sort),
                underline: SizedBox(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _sortBy = newValue;
                      _sortFormations();
                    });
                  }
                },
                items: [
                  DropdownMenuItem(
                    value: "date",
                    child: Text("Trier par date"),
                  ),
                  DropdownMenuItem(
                    value: "titre",
                    child: Text("Trier par titre"),
                  ),
                  DropdownMenuItem(
                    value: "lieu",
                    child: Text("Trier par lieu"),
                  ),
                ],
              ),
            ],
          ),

          // Filtres avancés
          SizeTransition(
            sizeFactor: _animationController!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Text(
                  "Catégories",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AUFColors.secondary,
                  ),
                ),
                SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children:
                        _categories.map((category) {
                          bool isSelected = _selectedCategory == category;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedCategory =
                                      selected ? category : null;
                                  _filterFormations();
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AUFColors.primary.withOpacity(0.1),
                              checkmarkColor: AUFColors.primary,
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? AUFColors.primary
                                        : AUFColors.secondary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? AUFColors.primary
                                          : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AUFColors.backgroundLight,
      body: RefreshIndicator(
        color: AUFColors.primary,
        onRefresh: _loadFormations,
        child:
            _isLoading
                ? Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AUFColors.primary,
                    ),
                  ),
                )
                : _error != null
                ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          fontSize: 16,
                          color: AUFColors.secondary,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        icon: Icon(Icons.refresh),
                        label: Text("Réessayer"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AUFColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _loadFormations,
                      ),
                    ],
                  ),
                )
                : _filteredFormations.isEmpty
                ? _buildEmptyState()
                : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${_filteredFormations.length} formation${_filteredFormations.length > 1 ? 's' : ''} disponible${_filteredFormations.length > 1 ? 's' : ''}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _buildFormationCard(_filteredFormations[index]);
                      }, childCount: _filteredFormations.length),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 16)),
                  ],
                ),
      ),
    );
  }
}

// Modèle Formation adapté pour inclure la propriété catégorie
class Formation {
  final int id;
  final String titre;
  final String description;
  final DateTime dateDebut;
  final DateTime dateFin;
  final String lieu;
  final String statut;
  final String categorie; // Ajouté pour la catégorisation

  Formation({
    required this.id,
    required this.titre,
    required this.description,
    required this.dateDebut,
    required this.dateFin,
    required this.lieu,
    required this.statut,
    required this.categorie,
  });

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: json['id'],
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      lieu: json['lieu'] ?? '',
      statut: json['statut'] ?? '',
      categorie:
          json['categorie'] ??
          'Non classé', // Valeur par défaut si non spécifiée
    );
  }
}
