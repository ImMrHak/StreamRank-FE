import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamrank/core/network/back-end/ApiService.dart';
import 'package:streamrank/core/network/models/FavoriteMovie.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/network/models/User.dart';
import 'package:streamrank/core/utils/Config.dart';

class UserApiService implements ApiService {
  final String baseUrl = Config.springBaseUrl;

  static List<Movie> favoriteMovies = [];

  // Check if the token is valid
  bool isTokenValid(String? token) {
    return token != null && token.isNotEmpty;
  }

  // Fetch List Movies - /getMovies
  Future<List<Movie>> getMovies() async {
    String token = Config.getToken() as String;
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
  Future<List<Movie>> getNextMovies(int pageNumber) async {
    String token = await Config.getToken() as String;
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
  Future<List<Movie>> getMovieSuggestions(int movieId) async {
    String token = Config.getToken() as String;
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
  Future<Movie> getMovieDetails(int movieId) async {
    String token = Config.getToken() as String;
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

  // Get List Favorite Movies - /getFavoriteMovies
  static Future<List<FavoriteMovie>> getFavoriteMovies() async {
    String token = await Config.getToken() as String;
    print('Token: $token'); // Debug: Show the token being used

    // Making the GET request
    print('Sending GET request to ${Config.springBaseUrl}user/getFavoriteMovies');

    final response = await http.get(
      Uri.parse('${Config.springBaseUrl}user/getFavoriteMovies'),
      headers: {'Authorization': 'Bearer $token'},
    );

    print('Response Status Code: ${response.statusCode}'); // Debug: Print status code

    if (response.statusCode == 200) {
      print('Response Body: ${response.body}'); // Debug: Log the response body

      try {
        final data = json.decode(response.body); // Attempt to decode the response body
        print('Decoded Data: $data'); // Debug: Log the decoded JSON data

        final favoriteMoviesList = (data['data'] as List)
            .map((movieJson) => FavoriteMovie.fromJson(movieJson))
            .toList();

        print('Favorite Movies List Length: ${favoriteMoviesList.length}'); // Debug: Number of movies

        return favoriteMoviesList;
      } catch (e) {
        print('Error decoding JSON: $e'); // Debug: If decoding fails
        throw Exception('Failed to parse the response data');
      }
    } else {
      print('Error Response Body: ${response.body}'); // Debug: Log error response body
      throw Exception('Failed to load favorite movies: ${response.statusCode}');
    }
  }




  Future<List<Movie>> searchMovies(String queryTerm) async {
    String token = Config.getToken() as String;
    if (!isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/searchMovies?queryTerm=$queryTerm'),
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

  // Save Favorite Movie - /saveFavoriteMovie
  Future<bool> saveFavoriteMovie(FavoriteMovie favoriteMovie) async {
    String token = await Config.getToken() as String;
    if (!isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final Map<String, dynamic> requestBody = {
        'idMovie': favoriteMovie.idMovie,
        'movieTitle': favoriteMovie.movieTitle,
        'movieReleaseDate': favoriteMovie.movieReleaseDate,
        'movieCategory': favoriteMovie.movieCategory,
        'movieGenre': favoriteMovie.movieGenre,
        'movieRating': favoriteMovie.movieRating,
        'imageCover': favoriteMovie.imageCover,
        'availableDownloadLinks': favoriteMovie.availableDownloadLinks,
      };

      final response = await http.post(
        Uri.parse('${baseUrl}user/saveFavoriteMovie'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return true; // Successfully saved or deleted
      } else {
        throw Exception('Failed to save/delete favorite movie: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving/deleting favorite movie: $e');
    }
  }
  // Get My Info - /getMyInfo
  Future<User> getMyInfo() async {
    String token = await Config.getToken() as String;
    if (!isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getMyInfo'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Assuming the user data is in the 'data' key and it's formatted properly
        return User.fromJson(data['data']);
      } else {
        throw Exception('Failed to load user info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }
}
