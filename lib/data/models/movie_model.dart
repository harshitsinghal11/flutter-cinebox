class Movie {
  final String id;
  final String title;
  final String genres; // Stores "Action, Adventure"
  final String posterPath;
  final String backdropPath;
  final String overview;
  final double voteAverage;
  final String releaseDate;

  Movie({
    required this.id,
    required this.title,
    required this.genres,
    required this.posterPath,
    required this.backdropPath,
    required this.overview,
    required this.voteAverage,
    required this.releaseDate,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    // 1. Get the list of genre IDs (e.g., [28, 12])
    final List<dynamic> genreIds = json['genre_ids'] ?? [];

    // 2. Convert IDs to Names using our static helper
    // We take the first 2 genres to keep the UI clean (e.g. "Action, Adventure")
    String genreText = genreIds
        .take(2)
        .map((id) => _genreMap[id] ?? '') // Map ID to Name
        .where((name) => name.isNotEmpty) // Remove unknown IDs
        .join(', '); // Join with comma

    // Fallback if no genres found
    if (genreText.isEmpty) genreText = 'Unknown';

    return Movie(
      id: json['id'].toString(),
      title: json['title'] ?? 'Unknown',

      // 3. Assign the generated text
      genres: genreText,

      posterPath: json['poster_path'] != null
          ? 'https://image.tmdb.org/t/p/w500${json['poster_path']}'
          : 'https://via.placeholder.com/500x750?text=No+Image',

      backdropPath: json['backdrop_path'] != null
          ? 'https://image.tmdb.org/t/p/w780${json['backdrop_path']}'
          : 'https://via.placeholder.com/780x440?text=No+Backdrop',

      overview: json['overview'] ?? 'No description available.',
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      releaseDate: json['release_date'] ?? 'N/A',
    );
  }

  // --- TMDB GENRE ID MAP (Standard IDs) ---
  static final Map<int, String> _genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };
}