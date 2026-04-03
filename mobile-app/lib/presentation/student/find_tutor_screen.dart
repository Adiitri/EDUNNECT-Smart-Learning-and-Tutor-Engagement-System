import 'tutor_details_screen.dart';
import 'package:flutter/material.dart';
import '../../../services/tutor_service.dart';
import '../../../services/user_session.dart';
import 'package:geolocator/geolocator.dart';

class FindTutorScreen extends StatefulWidget {
  const FindTutorScreen({super.key});

  @override
  State<FindTutorScreen> createState() => _FindTutorScreenState();
}

class _FindTutorScreenState extends State<FindTutorScreen> {
  List<dynamic> _tutors = [];
  List<dynamic> _filteredTutors = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTutors();
    _searchController.addListener(_applySearchFilter);
  }

  @override
  void dispose() {
    _searchController.removeListener(_applySearchFilter);
    _searchController.dispose();
    super.dispose();
  }

  void _loadTutors() async {
    setState(() => _isLoading = true);
    try {
      final user = UserSession.currentUser;
      List<dynamic> tutors = [];

      if (user != null && user['latitude'] != null && user['longitude'] != null) {
        // use saved coordinates
        tutors = await TutorService.getNearbyTutors(user['latitude'], user['longitude']);
      } else {
        // try device location before falling back
        try {
          final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
          tutors = await TutorService.getNearbyTutors(pos.latitude, pos.longitude);
        } catch (_) {
          tutors = await TutorService.getTutors();
        }
      }

      setState(() {
        _tutors = tutors;
        _filteredTutors = tutors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print("Error loading tutors: $e");
    }
  }

  void _applySearchFilter() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredTutors = List<dynamic>.from(_tutors);
      });
      return;
    }

    final filtered = _tutors.where((tutor) {
      final expertise = (tutor['expertise'] ?? tutor['subject'] ?? tutor['about'] ?? '').toString().toLowerCase();
      final location = (tutor['location'] ?? tutor['locationText'] ?? '').toString().toLowerCase();
      final name = (tutor['name'] ?? '').toString().toLowerCase();
      return expertise.contains(query) || location.contains(query) || name.contains(query);
    }).toList();

    setState(() {
      _filteredTutors = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Tutors"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search Physics, Math...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Tutor List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredTutors.isEmpty
                    ? const Center(child: Text("No tutors found."))
                    : ListView.builder(
                        itemCount: _filteredTutors.length,
                        itemBuilder: (context, index) {
                          final tutor = _filteredTutors[index];
                          return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orangeAccent,
                            child: Text(
                              tutor['name'][0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            tutor['name'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            // for users coming from geo-search the object may be a User
                            "${tutor['subject'] ?? tutor['expertise'] ?? ''} • ${tutor['location'] ?? tutor['locationText'] ?? ''}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              Text(tutor['rating'] ?? ''),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TutorDetailsScreen(tutor: tutor),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
