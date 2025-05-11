import 'package:flutter/material.dart';
import 'ParticipantDetailPage.dart';
import 'ajout_participant.dart';
import 'code_barre.dart';
import 'services/participant_service.dart';
import 'models/participant_model.dart';

class ParticipantsPage extends StatefulWidget {
  const ParticipantsPage({super.key});

  @override
  _ParticipantsPageState createState() => _ParticipantsPageState();
}

class _ParticipantsPageState extends State<ParticipantsPage> {
  final ParticipantService _participantService = ParticipantService();
  List<Participant> _participants = [];
  List<Participant> _filteredParticipants = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();

  // Couleurs AUF
  final Color aufRed = const Color(0xFFB2001A);
  final Color aufBlue = const Color(0xFF1A9CD9);
  final Color aufGreen = const Color(0xFF92C020);
  final Color aufPurple = const Color(0xFF7A2A90);
  final Color aufYellow = const Color(0xFFFFD100);

  @override
  void initState() {
    super.initState();
    _loadParticipants();
    _searchController.addListener(_filterParticipants);
  }

  void _filterParticipants() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredParticipants =
          _participants.where((participant) {
            return participant.nom.toLowerCase().contains(query) ||
                participant.prenom.toLowerCase().contains(query) ||
                participant.email.toLowerCase().contains(query);
          }).toList();
    });
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final participants = await _participantService.getAllParticipants();
      setState(() {
        _participants = participants;
        _filteredParticipants = participants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Impossible de charger les participants: ${e.toString()}';
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          backgroundColor: aufRed,
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: _loadParticipants,
          ),
        ),
      );
    }
  }

  // Génère une couleur cohérente basée sur le nom du participant
  Color _getAvatarColor(String name) {
    final List<Color> colors = [aufBlue, aufGreen, aufPurple, aufYellow];
    final int hashCode = name.hashCode;
    return colors[hashCode.abs() % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: aufRed,
        elevation: 0,
        title: const Text(
          'Participants',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        /*  actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BarCodePage()),
              );
            },
          ),
        ],  */
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: aufRed,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Rechercher un participant...',
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white70),
                          onPressed: () {
                            _searchController.clear();
                            _filterParticipants();
                          },
                        )
                        : null,
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(aufRed),
                      ),
                    )
                    : _errorMessage != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, color: aufRed, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: aufRed),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: aufRed,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: _loadParticipants,
                            child: const Text('Réessayer'),
                          ),
                        ],
                      ),
                    )
                    : _filteredParticipants.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            color: Colors.grey[400],
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun participant trouvé',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      itemCount: _filteredParticipants.length,
                      itemBuilder: (context, index) {
                        final participant = _filteredParticipants[index];
                        return _buildParticipantItem(context, participant);
                      },
                    ),
          ),
        ],
      ),
      /* floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddParticipantPage()),
          );
          if (result == true) {
            _loadParticipants();
          }
        },
        backgroundColor: aufRed,
        child: const Icon(Icons.person_add, color: Colors.white),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, */
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildParticipantItem(BuildContext context, Participant participant) {
    final String initials = '${participant.prenom[0]}${participant.nom[0]}';
    final avatarColor = _getAvatarColor(
      '${participant.prenom}${participant.nom}',
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        color: Colors.white,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ParticipantDetailPage(participant: participant),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: <Widget>[
                Hero(
                  tag: 'avatar-${participant.id}',
                  child: CircleAvatar(
                    backgroundColor: avatarColor,
                    radius: 28,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${participant.prenom} ${participant.nom}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              participant.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: aufRed.withOpacity(0.7)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
