import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/services/firestore_service.dart';
import '../../widgets/bg_wrapper.dart';
import '../../widgets/cinebox_app_bar.dart';
import '../auth/login_screen.dart';
import '../details/movie_detail_screen.dart'; // Import Details Screen

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final User? user = FirebaseAuth.instance.currentUser;

  // 0 = Watched, 1 = Queue
  int _selectedTab = 0;

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CineboxAppBar(showProfileButton: false),

        // 1. FETCH ALL DATA AT THE TOP LEVEL
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestoreService.getAllMoviesStream(),
          builder: (context, snapshot) {
            // Error Handling (Shows actual error if any)
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
            }

            // 2. FILTER DATA MANUALLY
            final allDocs = snapshot.data?.docs ?? [];

            // Separate into two lists
            final watchedMovies = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['isWatched'] == true;
            }).toList();

            final queueMovies = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['inQueue'] == true;
            }).toList();

            // Determine which list to show based on tab
            final currentList = _selectedTab == 0 ? watchedMovies : queueMovies;

            return Column(
              children: [
                const SizedBox(height: 10),

                // --- PROFILE HEADER ---
                _buildProfileHeader(),

                const SizedBox(height: 25),

                // --- TABS WITH COUNTERS ---
                _buildTabSwitch(
                  watchedCount: watchedMovies.length,
                  queueCount: queueMovies.length,
                ),

                const SizedBox(height: 20),

                // --- MOVIE GRID ---
                Expanded(
                  child: currentList.isEmpty
                      ? _buildEmptyState()
                      : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: currentList.length,
                    itemBuilder: (context, index) {
                      final data = currentList[index].data() as Map<String, dynamic>;
                      return _buildMovieCard(data);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- WIDGETS ---

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.redAccent, width: 2),
            ),
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, size: 35, color: Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.phoneNumber ?? "Guest User",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _logout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                    ),
                    child: const Text(
                      "Sign Out",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Now accepts counts!
  Widget _buildTabSwitch({required int watchedCount, required int queueCount}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          // Animated Pill
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: _selectedTab == 0 ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? const Color(0xFF006CA5) : const Color(0xFF7F0000),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))],
                ),
              ),
            ),
          ),

          // Text Buttons with COUNTERS
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 0),
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      "Watched [$watchedCount]", // <--- COUNTER HERE
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: _selectedTab == 0 ? 1 : 0.6),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = 1),
                  child: Container(
                    color: Colors.transparent,
                    alignment: Alignment.center,
                    child: Text(
                      "Queue [$queueCount]", // <--- COUNTER HERE
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withValues(alpha: _selectedTab == 1 ? 1 : 0.6),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Map<String, dynamic> data) {
    return GestureDetector(
      // --- NAVIGATION ADDED ---
      onTap: () {
        // Reconstruct the Movie object
        final movie = Movie(
          id: data['id'],
          title: data['title'],
          posterPath: data['posterPath'],
          backdropPath: data['posterPath'],
          overview: data['overview'] ?? 'No summary available.',
          voteAverage: 0.0,
          releaseDate: data['year'] ?? '',
          genres: data['genres'] ?? 'Unknown',
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetailScreen(movie: movie),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              data['posterPath'],
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
            ),

            // Rating Badge
            if (data['rating'] != null && data['rating'] > 0)
              Positioned(
                top: 8,
                right: 8,
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Text(
                        _getEmojiForRating(data['rating']),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _selectedTab == 0 ? Icons.movie_outlined : Icons.list_alt,
            size: 60,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedTab == 0 ? "No movies watched yet." : "Your queue is empty.",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 16),
          ),
        ],
      ),
    );
  }

  String _getEmojiForRating(int rating) {
    switch (rating) {
      case 1: return '😡';
      case 2: return '😐';
      case 3: return '🙂';
      case 4: return '😃';
      case 5: return '😍';
      default: return '⭐';
    }
  }
}