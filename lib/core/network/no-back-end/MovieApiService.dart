import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamrank/core/utils/Config.dart';
import 'package:streamrank/core/network/models/Movie.dart';

class MovieApiService {
  final String baseUrl = Config.moviesBaseUrl;

  Future<List<Movie>> getMovies() async {
    try {
      print('Making API call to $baseUrl movies');
      final response = await http.get(Uri.parse('${baseUrl}list_movies.json'));
      print('Response received with status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        if (data['status'] == 'ok') {
          final List<dynamic> movies = data['data']['movies'];
          print('Movies data retrieved: ${movies.length} movies found');
          return movies.map((json) => Movie.fromJson(json)).toList();
        }
      }
      print('Failed to load movies');
      throw Exception('Failed to load movies');
    } catch (e) {
      print('Error fetching movies: $e');
      throw Exception('Error fetching movies: $e');
    }
  }

  Future<List<Movie>> getMoviesWithoutAuth() async {
    print('getMoviesWithoutAuth called');
    try {
      print('Making API call to $baseUrl public/movies');
      final response = await http.get(
        Uri.parse('${baseUrl}public/movies'),
      );
      print('Response received with status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        if (data['status'] == 'success') {
          final List<dynamic> movies = data['data'];
          print('Public movies data retrieved: ${movies.length} movies found');
          return movies.map((json) => Movie.fromJson(json)).toList();
        }
      }
      print('Failed to load public movies');
      throw Exception('Failed to load movies');
    } catch (e) {
      print('Error fetching public movies: $e');

      throw Exception('Error fetching public movies: $e');
    }
  }

  Future<List<Movie>> getNextMovies(int pageNumber) async {
    try {
      print('Making API call to $baseUrl movies?page=$pageNumber');
      final response = await http.get(
        Uri.parse('${baseUrl}list_movies.json?page=$pageNumber'),
      );
      print('Response received with status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        if (data['status'] == 'ok') {
          final List<dynamic> movies = data['data']['movies'];
          print('Next movies data retrieved: ${movies.length} movies found');
          return movies.map((json) => Movie.fromJson(json)).toList();
        }
      }
      print('Failed to load more movies');
      throw Exception('Failed to load more movies');
    } catch (e) {
      print('Error fetching more movies: $e');

      throw Exception('Error fetching more movies: $e');
    }
  }

  Future<List<Movie>> getNextMoviesWithoutAuth(int pageNumber) async {
    print('getNextMoviesWithoutAuth called with page number: $pageNumber');
    try {
      print('Making API call to $baseUrl public/movies?page=$pageNumber');
      final response = await http.get(
        Uri.parse('${baseUrl}public/movies?page=$pageNumber'),
      );
      print('Response received with status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        if (data['status'] == 'ok') {
          final List<dynamic> movies = data['data']['movies'];
          print(
              'Next public movies data retrieved: ${movies.length} movies found');
          return movies.map((json) => Movie.fromJson(json)).toList();
        }
      }
      print('Failed to load more public movies');
      throw Exception('Failed to load more movies');
    } catch (e) {
      print('Error fetching more public movies: $e');

      throw Exception('Error fetching more public movies: $e');
    }
  }

  Future<List<Movie>> getMovieSuggestions(int movieId) async {
    print('getMovieSuggestions called with movie id: $movieId');
    try {
      print(
          'Making API call to $baseUrl movie_suggestions.json?movie_id=$movieId');
      final response = await http
          .get(Uri.parse('$baseUrl/movie_suggestions.json?movie_id=$movieId'));
      print('Response received with status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');

        if (data['data'] != null && data['data']['movies'] != null) {
          final movies = data['data']['movies'] as List;
          print(
              'Movie suggestions data retrieved: ${movies.length} movies found');

          return movies
              .map((movieJson) {
                try {
                  return Movie.fromJson(movieJson);
                } catch (e) {
                  print('Error parsing movie: $e');
                  return null; // Skip invalid entries
                }
              })
              .whereType<Movie>()
              .toList(); // Filter out null entries
        } else {
          print('No movies found in the response.');
        }
      } else {
        print(
            'Failed to fetch movie suggestions. Status code: ${response.statusCode}');
      }

      return [];
    } catch (e) {
      print('An error occurred: $e');

      throw Exception('Error fetching movie suggestions: $e');
    }
  }

  Future<Movie> getMovieDetails(int movieId) async {
    print('getMovieDetails called with movie id: $movieId');
    try {
      print('Making API call to $baseUrl movie_details.json?movie_id=$movieId');
      final response = await http
          .get(Uri.parse('${baseUrl}movie_details.json?movie_id=$movieId'));
      print('Response received with status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        final movieJson = data['data']['movie']; // Single movie JSON object
        final movie = Movie.fromJson(movieJson); // Create a Movie instance
        print('Movie details retrieved: $movie');
        return movie;
      } else {
        print(
            'Failed to load movie details. Status code: ${response.statusCode}');
        throw Exception('Failed to load movie details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching movie details: $e');

      throw Exception('Error fetching movie details: $e');
    }
  }

  Future<List<Movie>> searchMovies(String queryTerm) async {
    print('searchMovies called with query term: $queryTerm');
    try {
      print(
          'Making API call to $baseUrl list_movies.json?query_term=$queryTerm');
      final response = await http.get(
        Uri.parse('${baseUrl}list_movies.json?query_term=$queryTerm'),
      );
      print('Response received with status code: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response data: $data');
        final movieList = (data['data']['movies'] as List)
            .map((movieJson) => Movie.fromJson(movieJson))
            .toList();
        print('Search results retrieved: ${movieList.length} movies found');
        return movieList;
      } else {
        print(
            'Failed to load search results. Status code: ${response.statusCode}');
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      print('Error fetching search results: $e');

      throw Exception('Error fetching movies: $e');
    }
  }
}
