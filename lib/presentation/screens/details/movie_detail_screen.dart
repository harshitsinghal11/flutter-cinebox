import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/services/firestore_service.dart';
import '../profile/profile_screen.dart';
import '../../widgets/custom_buttons.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  final List<Map<String, dynamic>> _ratingLevels = [
    {'level': 1, 'label': 'Dislike'},
    {'level': 2, 'label': 'Meh'},
    {'level': 3, 'label': 'Ok'},
    {'level': 4, 'label': 'Good'},
    {'level': 5, 'label': 'Gem'},
  ];

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 800;
    final double padding = size.width * 0.05;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // --- 1. DYNAMIC BACKGROUND ---
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: isMobile ? size.height * 0.5 : size.height * 0.6,
            child: Image.network(
              widget.movie.posterPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.black),
            ),
          ),

          // --- 2. BLUR & OVERLAY ---
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withValues(alpha: 0.6),
              ),
            ),
          ),

          // --- 3. MAIN CONTENT ---
          SafeArea(
            child: StreamBuilder<DocumentSnapshot>(
              stream: _firestoreService.getMovieStream(widget.movie.id),
              builder: (context, snapshot) {
                // Get Real-Time Data
                Map<String, dynamic>? data;
                if (snapshot.hasData && snapshot.data!.exists) {
                  data = snapshot.data!.data() as Map<String, dynamic>;
                }

                bool isInQueue = data?['inQueue'] ?? false;
                bool isWatched = data?['isWatched'] ?? false;
                int currentRating = data?['rating'] ?? 0;

                // --- HELPER: POSTER SECTION ---
                Widget posterSection = Column(
                  children: [
                    Hero(
                      tag: widget.movie.id,
                      child: AspectRatio(
                        aspectRatio: 2 / 3,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            image: DecorationImage(
                              image: NetworkImage(widget.movie.posterPath),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        if (widget.movie.genres.isNotEmpty)
                          InfoPill(widget.movie.genres.split(',')[0]),
                        InfoPill(widget.movie.releaseDate.split('-')[0]),
                      ],
                    ),
                  ],
                );

                // --- HELPER: INFO SECTION ---
                Widget infoSection = Column(
                  crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isMobile ? 40 : 50),

                    // Title
                    Text(
                      widget.movie.title,
                      textAlign: isMobile ? TextAlign.center : TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: isMobile ? 28 : 36,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- BUTTONS (Enforcing One-At-A-Time Rule) ---
                    Row(
                      children: [
                        // WATCH BUTTON
                        Expanded(
                          child: CineboxActionButton(
                            label: isWatched ? "Watched" : "Mark as Watch",
                            color: const Color(0xFF006CA5),
                            isActive: isWatched,
                            onTap: () {
                              bool targetState = !isWatched;
                              _firestoreService.saveMovie(
                                  widget.movie,
                                  isWatched: targetState,
                                  inQueue: targetState ? false : null,
                                  rating: targetState ? null : 0
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),

                        // QUEUE BUTTON
                        Expanded(
                          child: CineboxActionButton(
                            label: isInQueue ? "In Queue" : "Add in Queue",
                            color: const Color(0xFF7F0000),
                            isActive: isInQueue,
                            onTap: () {
                              bool targetState = !isInQueue;
                              _firestoreService.saveMovie(
                                  widget.movie,
                                  inQueue: targetState,
                                  isWatched: targetState ? false : null,
                                  rating: targetState ? 0 : null
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // --- RATING CONTAINER (Locked if not Watched) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isWatched
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.white.withValues(alpha: 0.03), // Dimmer background if locked
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: isWatched
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.white.withValues(alpha: 0.05)
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            isWatched ? "YOUR RATING" : "WATCH TO RATE", // Change text based on state
                            style: TextStyle(
                              color: isWatched ? Colors.white70 : Colors.white38, // Dim text
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _ratingLevels.map((level) {
                              final int ratingValue = level['level'];
                              final bool isSelected = currentRating >= ratingValue;

                              return GestureDetector(
                                onTap: () {
                                  // --- THE NEW RULE ---
                                  if (!isWatched) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          "You must mark as 'Watched' to rate this movie!",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
                                        behavior: SnackBarBehavior.floating,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                    return; // STOP HERE
                                  }

                                  // Only save if watched
                                  _firestoreService.saveMovie(
                                      widget.movie,
                                      rating: ratingValue
                                  );
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                                      // If locked (not watched), show very dim grey
                                      color: isWatched
                                          ? (isSelected ? const Color(0xFFFFC107) : Colors.white24)
                                          : Colors.white10,
                                      size: isMobile ? 32 : 28,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      level['label'],
                                      style: TextStyle(
                                        color: isWatched
                                            ? (isSelected ? const Color(0xFFFFC107) : Colors.white38)
                                            : Colors.white10,
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Plot Summary
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0E0E0).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PLOT",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.movie.overview.isNotEmpty
                                ? widget.movie.overview
                                : "No summary available.",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              height: 1.6,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );

                // --- MAIN RENDER ---
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: 10),
                  child: Column(
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GlassIconButton(
                            icon: Icons.arrow_back_ios_new,
                            onTap: () => Navigator.pop(context),
                          ),
                          Column(
                            children: [
                              GlassIconButton(
                                icon: Icons.person,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              const Text("Profile", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.03),

                      // Responsive Layout Switcher
                      if (isMobile)
                        Column(
                          children: [
                            SizedBox(width: size.width * 0.55, child: posterSection),
                            const SizedBox(height: 30),
                            infoSection,
                          ],
                        )
                      else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(width: size.width * 0.20, child: posterSection),
                            SizedBox(width: size.width * 0.05),
                            Expanded(child: infoSection),
                          ],
                        ),

                      const SizedBox(height: 50),
                    ],
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