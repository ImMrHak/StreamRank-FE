import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/back-end/ApiService.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/network/no-back-end/MovieApiService.dart';
import 'package:streamrank/core/utils/Config.dart';
import 'package:streamrank/features/movie/MovieDetailsPage.dart';

import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/back-end/ApiService.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/network/no-back-end/MovieApiService.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  List<Movie> _movies = [];  // List to store fetched movies
  int _currentPage = 1;       // Current page number
  bool _isLoading = false;    // Track if movies are being fetched
  bool _hasMoreMovies = true; // Flag to determine if there are more movies to load

  // Fetch the list of movies (Initial fetch)
  Future<List<Movie>> _fetchMovies() async {
    ApiService apiService = (await AuthApiService.ping()) ? UserApiService() : MovieApiService();

    try {
      // Try to fetch movies from UserApiService first
      return await apiService.getMovies();
    } catch (e) {
      // If an error occurs, fallback to MovieApiService
      print("Error fetching movies from UserApiService: $e");
      apiService = MovieApiService();
      try {
        return await apiService.getMovies();
      } catch (e) {
        throw Exception('Failed to load movies from both services: $e');
      }
    }
  }

  // Fetch next page of movies (for subsequent fetches)
  Future<void> _fetchNextMovies() async {
    if (_isLoading || !_hasMoreMovies) return;  // Prevent fetching if already loading or no more movies

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = UserApiService();
      final newMovies = await apiService.getNextMovies(_currentPage);
      if (newMovies.isEmpty) {
        setState(() {
          _hasMoreMovies = false;  // No more movies to fetch
        });
      } else {
        setState(() {
          _movies.addAll(newMovies);  // Append new movies
          _currentPage++;             // Increment page number
        });
      }
    } catch (e) {
      // Handle error (e.g., show an error message)
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load next movies: $e'))
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(  // Wrap with Scaffold to ensure Material context
      appBar: AppBar(
        title: const Text('Movies'),
      ),
      body: FutureBuilder<List<Movie>>(
        future: _fetchMovies(), // Fetch the initial list of movies
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            _movies = snapshot.data!;  // Set the fetched movies to _movies
            return _buildMoviesList();
          } else {
            return const Center(child: Text('No movies found.'));
          }
        },
      ),
    );
  }

  Widget _buildMoviesList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              final movie = _movies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetailsPage(movieId: movie.id), // No token required
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: ImageNetwork(
                          height: 150,
                          width: 100,
                          image: movie.largeCoverImage,
                          onLoading: const CircularProgressIndicator(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie.title,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${movie.year} - Rating: ${movie.rating}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_hasMoreMovies)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _fetchNextMovies(),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Load More Movies'),
            ),
          ),
      ],
    );
  }
}
