import 'package:streamrank/core/network/models/Movie.dart';

abstract class ApiService {
  /// Fetch the initial list of movies.
  Future<List<Movie>> getMovies();

  /// Fetch the next page of movies.
  Future<List<Movie>> getNextMovies(int pageNumber);

  /// Get movie suggestions based on a movie ID.
  Future<List<Movie>> getMovieSuggestions(int movieId);

  /// Get detailed information about a specific movie.
  Future<Movie> getMovieDetails(int movieId);

  Future<List<Movie>> searchMovies(String queryTerm);
}
