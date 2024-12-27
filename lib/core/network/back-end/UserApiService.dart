import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamrank/core/utils/Config.dart';
import 'package:streamrank/core/network/models/FavoriteMovie.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/network/models/User.dart';
import 'package:streamrank/core/network/models/Torrent.dart';

class UserApiService {
  final String baseUrl = Config.springBaseUrl;

  bool isTokenValid(String token) {
    return token.isNotEmpty;
  }

  Future<List<Movie>> getMovies() async {
    final token = await Config.getToken();
    if (token == null || !isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getMovies'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> movies = data['data'];
          return movies.map((json) => Movie.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load movies');
    } catch (e) {
      throw Exception('Error fetching movies: $e');
    }
  }

  Future<List<Movie>> getNextMovies(int pageNumber) async {
    final token = await Config.getToken();
    if (token == null || !isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getNextMovies?pageNumber=$pageNumber'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> movies = data['data'];
          return movies.map((json) => Movie.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load next movies');
    } catch (e) {
      throw Exception('Error fetching next movies: $e');
    }
  }

  Future<List<Movie>> getSuggestionMovies(int movieId) async {
    final token = await Config.getToken();
    if (token == null || !isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getSuggestionMovies?movieId=$movieId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> movies = data['data'];
          return movies.map((json) => Movie.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to load suggestion movies');
    } catch (e) {
      throw Exception('Error fetching suggestion movies: $e');
    }
  }

  Future<Movie> getDetailMovie(int movieId) async {
    final token = await Config.getToken();
    if (token == null || !isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getDetailMovie?movieId=$movieId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return Movie.fromJson(data['data']);
        }
      }
      throw Exception('Failed to load movie details');
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }

  Future<List<Movie>> getFavoriteMovies() async {
    final token = await Config.getToken();
    print('Token: $token'); // Debug token

    if (token == null || !isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final url = '${baseUrl}user/getFavoriteMovies';
      print('Request URL: $url'); // Debug URL
      
      final headers = {'Authorization': 'Bearer $token'};
      print('Request Headers: $headers'); // Debug headers

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> movies = data['data'];
          return movies.map((json) => FavoriteMovie.fromSpringJson(json)).toList();
        }
      }
      
      // If we get here, there was an error
      final errorData = json.decode(response.body);
      throw Exception('Failed to load favorites: ${errorData['message']}');
    } catch (e) {
      print('Error fetching favorites: $e');
      throw Exception('Error fetching favorites: $e');
    }
  }

  Future<List<Movie>> searchMovies(String queryTerm) async {
    final token = await Config.getToken();
    if (token == null || !isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/searchMovies?queryTerm=$queryTerm'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> movies = data['data'];
          return movies.map((json) => Movie.fromJson(json)).toList();
        }
      }
      throw Exception('Failed to search movies');
    } catch (e) {
      throw Exception('Error searching movies: $e');
    }
  }

  Future<bool> saveFavoriteMovie(int movieId) async {
    final token = await Config.getToken();
    if (token == null || !isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final movie = await getDetailMovie(movieId);
      final response = await http.post(
        Uri.parse('${baseUrl}user/saveFavoriteMovie'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'idMovie': movie.id,
          'movieTitle': movie.title,
          'movieReleaseDate': movie.year.toString(),
          'movieCategory': movie.genres.isNotEmpty ? movie.genres[0] : '',
          'movieGenre': movie.genres,
          'movieRating': movie.rating.toString(),
          'imageCover': movie.largeCoverImage, // Using large_cover_image instead of cover_image
          'availableDownloadLinks': movie.torrents.map((t) => t.url).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'success';
      }
      throw Exception('Failed to save favorite movie');
    } catch (e) {
      print('Error saving favorite movie: $e');
      throw Exception('Error saving favorite movie: $e');
    }
  }

  /// Toggles a movie's favorite status. Returns true if movie was added to favorites,
  /// false if it was removed from favorites.
  Future<bool> addToFavorites(int movieId) async {
  final token = await Config.getToken();
  if (token == null || !isTokenValid(token)) {
    print('❌ Authentication failed: No token or invalid token');
    throw Exception('User is not authenticated');
  }

  try {
    print('🎬 Fetching movie details for ID: $movieId...');
    final movie = await getDetailMovie(movieId);

    print('\n📝 Preparing favorite movie data:');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('🎥 Movie ID: $movieId');
    print('📌 Title: ${movie.title}');
    print('📅 Release Date: ${movie.year}');
    print('🏷️ Category: ${movie.genres.isNotEmpty ? movie.genres[0] : "N/A"}');
    print('🎭 Genres: ${movie.genres}');
    print('⭐ Rating: ${movie.rating}');
    print('🖼️ Cover: ${movie.largeCoverImage}');
    print('🔗 Download Links: ${movie.torrents.length} available');

    final requestBody = {
      'idMovie': movieId,
      'movieTitle': movie.title,
      'movieReleaseDate': movie.year.toString(),
      'movieCategory': movie.genres.isNotEmpty ? movie.genres[0] : '',
      'movieGenre': movie.genres,
      'movieRating': movie.rating.toString(),
      'imageCover': movie.largeCoverImage,
      'availableDownloadLinks': movie.torrents.map((t) => t.url).toList(),
    };

    print('\n📤 Sending request to server...');
    print('URL: ${baseUrl}user/saveFavoriteMovie');
    
    final response = await http.post(
      Uri.parse('${baseUrl}user/saveFavoriteMovie'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    print('\n📥 Server response:');
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = response.body;
      final isAdded = !responseBody.toLowerCase().contains('removed');
      print('\n✅ Operation successful:');
      print(isAdded ? '➕ Movie added to favorites' : '➖ Movie removed from favorites');
      return isAdded;
    } else {
      print('\n❌ Server error:');
      print('Status code: ${response.statusCode}');
      print('Error message: ${response.body}');
      final data = json.decode(response.body);
      throw Exception(data['message'] ?? 'Failed to save favorite movie');
    }
  } catch (e) {
    print('\n❌ Error occurred:');
    print('Error details: $e');
    throw Exception('Error adding to favorites: $e');
  }
}

  // Since there's no direct remove endpoint, we'll save with a flag to remove
  Future<void> removeFromFavorites(int movieId) async {
    final token = await Config.getToken();
    if (token == null || !isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final movie = await getDetailMovie(movieId);
      final response = await http.post(
        Uri.parse('${baseUrl}user/saveFavoriteMovie'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          ...movie.toJson(),
          'remove': true,  // Add a flag to indicate removal
        }),
      );

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to remove favorite');
      }
    } catch (e) {
      throw Exception('Error removing from favorites: $e');
    }
  }

  Future<User> getMyInfo() async {
    final token = await Config.getToken();
    if (token == null || !isTokenValid(token)) {
      throw Exception('User is not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${baseUrl}user/getMyInfo'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          return User.fromJson(data['data']);
        }
      }
      throw Exception('Failed to load user info');
    } catch (e) {
      throw Exception('Error fetching user info: $e');
    }
  }
}
