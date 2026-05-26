import 'package:flutter/material.dart';
import '../../widgets/bg_wrapper.dart';
import '../../../data/services/movie_service.dart';
import '../../../data/models/movie_model.dart';
import '../details/movie_detail_screen.dart';
import '../../widgets/cinebox_app_bar.dart';
import '../search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieService _movieService = MovieService();

  // Futures for the categories
  late Future<List<Movie>> _trendingFuture;
  late Future<List<Movie>> _nowPlayingFuture;
  late Future<List<Movie>> _upcomingFuture;
  late Future<List<Movie>> _topRatedFuture;

  @override
  void initState() {
    super.initState();
    _loadAllCategories();
  }

  void _loadAllCategories() {
    _trendingFuture = _movieService.getTrendingMovies();
    _nowPlayingFuture = _movieService.getNowPlayingMovies();
    _upcomingFuture = _movieService.getUpcomingMovies();
    _topRatedFuture = _movieService.getTopRatedMovies();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CineboxAppBar(),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. SEARCH BUTTON (Navigates to SearchScreen) ---
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      // Make sure you renamed the file to search_screen.dart
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.white70),
                        const SizedBox(width: 12),
                        Text(
                          "Search movies...",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // --- 2. CONTENT AREA ---
              _buildCategoryLists(),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // The Category Lists (Cleaned Titles)
  Widget _buildCategoryLists() {
    return Column(
      children: [
        _buildSection("🔥 Trending Now", _trendingFuture),
        _buildSection("🎬 Now Playing", _nowPlayingFuture),
        _buildSection("📅 Upcoming Releases", _upcomingFuture),
        _buildSection("⭐ Top Rated", _topRatedFuture),
      ],
    );
  }

  // --- WIDGET HELPERS ---
  Widget _buildSection(String title, Future<List<Movie>> future) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20, // Adjusted size for better hierarchy
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Horizontal Scroll List
        SizedBox(
          height: 240, // Optimized height
          child: FutureBuilder<List<Movie>>(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SizedBox();
              }

              final movies = snapshot.data!;
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return Container(
                    width: 150, // Fixed width
                    margin: const EdgeInsets.only(right: 12),
                    child: _buildMovieCard(movies[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MovieDetailScreen(movie: movie)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster Image
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  movie.posterPath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (c, e, s) => Container(color: Colors.grey[900]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            movie.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}