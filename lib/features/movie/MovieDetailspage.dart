import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/back-end/ApiService.dart';
import 'package:streamrank/core/network/no-back-end/MovieApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({
    super.key,
    required this.movieId,
  });

  @override
  _MovieDetailsPageState createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final List<Movie> _favoriteMovies = []; // List to store favorite movies

  // Fetch movie details without authentication
  Future<Movie> _fetchMovieDetails() async {
    ApiService apiService = MovieApiService();
    try {
      return await apiService.getMovieDetails(widget.movieId);
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
  }

  // Add movie to favorites
  void _addToFavorites(Movie movie) {
    setState(() {
      if (!_favoriteMovies.contains(movie)) {
        _favoriteMovies.add(movie);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${movie.title} added to favorites!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${movie.title} is already in favorites!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Details'),
      ),
      body: FutureBuilder<Movie>(
        future: _fetchMovieDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No details available for this movie.'),
            );
          } else {
            final movie = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: ImageNetwork(
                        height: 250,
                        width: 200,
                        image: movie.largeCoverImage,
                        onLoading: const CircularProgressIndicator(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      movie.titleLong,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Year: ${movie.year} | Rating: ${movie.rating.toStringAsFixed(1)} | IMDb Code: ${movie.imdbCode}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (movie.genres.isNotEmpty)
                      Text(
                        'Genres: ${movie.genres.join(', ')}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      movie.description.isEmpty
                          ? 'No description available.'
                          : movie.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    if (movie.torrents.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Torrents:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...movie.torrents.map((torrent) {
                            return ListTile(
                              title: Text('${torrent.quality} (${torrent.size})'),
                              trailing: const Icon(Icons.download),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Opening torrent: ${torrent.quality}')),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                  ],
                ),
              ),
            );
          }
        },
      ),
      bottomNavigationBar: FutureBuilder<Movie>(
        future: _fetchMovieDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
            return const SizedBox.shrink();
          }
          final movie = snapshot.data!;
          return BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite),
                label: 'Favorite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_fill),
                label: 'Watch',
              ),
            ],
            onTap: (index) {
              if (index == 0) {
                _addToFavorites(movie);
              } else if (index == 1) {
                Navigator.pop(context); // Go back to the main page
              } else if (index == 2) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Watch feature coming soon!')),
                );
              }
            },
          );
        },
      ),
    );
  }
}
