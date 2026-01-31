import 'package:flutter/material.dart';
import '../../services/recommendation_service.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX 1: Removed 'final RecommendationService service = RecommendationService();'
    // because your service methods are static.

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Course Recommendations"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white, // Ensures text is visible
      ),
      body: FutureBuilder<List<dynamic>>(
        // FIX 2: Call the static method directly using the Class name
        future: RecommendationService.getRecommendations("user123"), 
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Log the error to console for debugging
            print("UI Error: ${snapshot.error}");
            return const Center(child: Text("Error connecting to AI Engine"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No recommendations found yet!"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final course = snapshot.data![index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.school, color: Colors.white),
                  ),
                  // Ensure 'title' matches the key in your Python dictionary
                  title: Text(
                    course['title'] ?? "Untitled Course", 
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(course['category'] ?? "Personalized for you"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to course details here
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}