import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/utils/Config.dart';

class UserApiService {
  final String baseUrl = Config.springBaseUrl;

  // Check if the token is valid
  bool isTokenValid(String? token) {
    return token != null && token.isNotEmpty;
  }

  // Fetch List Movies - /getMovies
  Future<List<Movie>> getMovies(String? token) async {
    if (!isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getMovies'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movieList = (data['data'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        return movieList;
      } else {
        throw Exception('Failed to load movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  // Fetch List Next Movies - /getNextMovies
  Future<List<Movie>> getNextMovies(int pageNumber, String? token) async {
    if (!isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getNextMovies?pageNumber=$pageNumber'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movieList = (data['data'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        return movieList;
      } else {
        throw Exception('Failed to load next movies: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching next movies: $e');
    }
  }

  // Get List Movie Suggestions - /getSuggetionMovies
  Future<List<Movie>> getMovieSuggestions(int movieId, String? token) async {
    if (!isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getSuggetionMovies?movieId=$movieId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movieList = (data['data'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        return movieList;
      } else {
        throw Exception('Failed to load movie suggestions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie suggestions: $e');
    }
  }

  // Get Movie Details - /getDetailMovie
  Future<Movie> getMovieDetails(int movieId, String? token) async {
    if (!isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getDetailMovie?movieId=$movieId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movieData = data['data'];
        return Movie.fromJson(movieData);
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }
}
