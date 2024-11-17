import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/utils/Config.dart';

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
  Future<List<Movie>> _fetchMovies(String token) async {
    final apiService = UserApiService();
    try {
      // Call the getMovies API method (Only for the initial fetch)
      return await apiService.getMovies(token);
    } catch (e) {
      throw Exception('Failed to load movies: $e');
    }
  }

  // Fetch next page of movies (for subsequent fetches)
  Future<void> _fetchNextMovies(String token) async {
    if (_isLoading || !_hasMoreMovies) return;  // Prevent fetching if already loading or no more movies

    setState(() {
      _isLoading = true;
    });

    try {
      final apiService = UserApiService();
      final newMovies = await apiService.getNextMovies(_currentPage, token);
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
        title: Text('Movies'),
      ),
      body: FutureBuilder<String?>(
        future: Config.getToken(), // Fetch the token asynchronously
        builder: (context, tokenSnapshot) {
          if (tokenSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (tokenSnapshot.hasError) {
            return Center(child: Text('Error: ${tokenSnapshot.error}'));
          } else if (!tokenSnapshot.hasData || !tokenSnapshot.data!.isNotEmpty) {
            return Center(child: Text('Please log in to see movies.'));
          } else {
            final token = tokenSnapshot.data!;

            // Fetch initial movies if _movies is empty
            if (_movies.isEmpty) {
              return FutureBuilder<List<Movie>>(
                future: _fetchMovies(token),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    _movies = snapshot.data!;  // Set the fetched movies to _movies
                    return _buildMoviesList(token);
                  } else {
                    return Center(child: Text('No movies found.'));
                  }
                },
              );
            }

            // Once movies are loaded, build the movies list
            return _buildMoviesList(token);
          }
        },
      ),
    );
  }

  Widget _buildMoviesList(String token) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _movies.length,
            itemBuilder: (context, index) {
              final movie = _movies[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: ImageNetwork(
                        height: 150,
                        width: 100,
                        image: movie.coverImage,

                        onLoading: CircularProgressIndicator(),

                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movie.title,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${movie.year} - Rating: ${movie.rating}',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        if (_hasMoreMovies)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () => _fetchNextMovies(token),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Load More Movies'),
            ),
          ),
      ],
    );
  }
}
