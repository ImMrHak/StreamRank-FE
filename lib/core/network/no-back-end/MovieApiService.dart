import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamrank/core/network/back-end/ApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/utils/Config.dart';

class MovieApiService implements ApiService {
  final String baseUrl = Config.moviesBaseUrl;

  Future<List<Movie>> getMovies() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}list_movies.json'));

      print(response.body);

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Decode the response body
        final data = json.decode(response.body);

        final movieList = (data['data']['movies'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();

            return movieList;
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      throw Exception('Error fetching movies: $e');
    }
  }

  Future<List<Movie>> getNextMovies(int pageNumber) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}list_movies.json?page=$pageNumber'));

      // Check if the response is successful
      if (response.statusCode == 200) {
        // Decode the response body
        final data = json.decode(response.body);

        final movieList = (data['data']['movies'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();

            return movieList;
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      throw Exception('Error fetching movies: $e');
    }
  }

Future<List<Movie>> getMovieSuggestions(int movieId) async {
  try {
    // Send the request
    final response = await http.get(Uri.parse('$baseUrl/movie_suggestions.json?movie_id=$movieId'));

    // Check if the response is successful
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Safely navigate the JSON structure
      if (data['data'] != null && data['data']['movies'] != null) {
        final movies = data['data']['movies'] as List;

        // Convert each JSON object into a Movie object
        return movies.map((movieJson) {
          try {
            return Movie.fromJson(movieJson);
          } catch (e) {
            //print('Error parsing movie: $e');
            return null; // Skip invalid entries
          }
        }).whereType<Movie>().toList(); // Filter out null entries
      } else {
        print('No movies found in the response.');
      }
    } else {
      print('Failed to fetch movie suggestions. Status code: ${response.statusCode}');
    }

    // Return an empty list if no valid movies were found
    return [];
  } catch (e) {
    print('An error occurred: $e');
    throw Exception('Error fetching movie suggestions: $e');
  }
}
  Future<Movie> getMovieDetails(int movieId) async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}movie_details.json?movie_id=$movieId'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final movieJson = data['data']['movie']; // Single movie JSON object
        final movie = Movie.fromJson(movieJson); // Create a Movie instance
        return movie;
      } else {
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching movie details: $e');
    }
  }
}