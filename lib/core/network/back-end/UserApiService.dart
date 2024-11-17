import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamrank/core/utils/Config.dart';

class UserApiService {
  final String baseUrl = Config.springBaseUrl;

  // Fetch List Movies - /getMovies
  Future<List<dynamic>> getMovies(String token) async {
    final response = await http.get(
      Uri.parse(baseUrl + 'user/getMovies'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Assuming data is inside a 'data' field
    } else {
      throw Exception('Failed to load movies');
    }
  }

  // Fetch List Next Movies - /getNextMovies
  Future<List<dynamic>> getNextMovies(int pageNumber, String token) async {
    final response = await http.get(
      Uri.parse(baseUrl + 'user/getNextMovies?pageNumber=$pageNumber'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Assuming data is inside a 'data' field
    } else {
      throw Exception('Failed to load next movies');
    }
  }

  // Get List Movie Suggestions - /getSuggetionMovies
  Future<List<dynamic>> getMovieSuggestions(int movieId, String token) async {
    final response = await http.get(
      Uri.parse(baseUrl + 'user/getSuggetionMovies?movieId=$movieId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Assuming data is inside a 'data' field
    } else {
      throw Exception('Failed to load movie suggestions');
    }
  }

  // Get Movie Details - /getDetailMovie
  Future<Map<String, dynamic>> getMovieDetails(int movieId, String token) async {
    final response = await http.get(
      Uri.parse(baseUrl + 'user/getDetailMovie?movieId=$movieId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']; // Assuming data is inside a 'data' field
    } else {
      throw Exception('Failed to load movie details');
    }
  }
}