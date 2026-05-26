import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/movie_model.dart';

class MovieService {
  static const String apiKey = '951559fe4e775099cbbad589abc3726d';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // 1. Trending
  Future<List<Movie>> getTrendingMovies() async {
    final url = Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey');
    return _fetchMovies(url);
  }

  // 2. Now Playing (Latest Releases)
  Future<List<Movie>> getNowPlayingMovies() async {
    final url = Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey');
    return _fetchMovies(url);
  }

  // 3. Upcoming
  Future<List<Movie>> getUpcomingMovies() async {
    final url = Uri.parse('$baseUrl/movie/upcoming?api_key=$apiKey');
    return _fetchMovies(url);
  }

  // 4. Top Rated
  Future<List<Movie>> getTopRatedMovies() async {
    final url = Uri.parse('$baseUrl/movie/top_rated?api_key=$apiKey');
    return _fetchMovies(url);
  }

  // 5. Search
  Future<List<Movie>> searchMovies(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = Uri.parse('$baseUrl/search/movie?api_key=$apiKey&query=$encodedQuery');
    return _fetchMovies(url);
  }

  // Helper
  Future<List<Movie>> _fetchMovies(Uri url) async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null) {
          final List results = data['results'];
          return results.map((json) => Movie.fromJson(json)).toList();
        }
        return [];
      } else {
        debugPrint("TMDB Error: ${response.body}");
        return []; // Return empty list instead of crashing
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      return [];
    }
  }
}