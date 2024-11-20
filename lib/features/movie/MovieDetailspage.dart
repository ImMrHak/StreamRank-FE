import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';

class MovieDetailsPage extends StatelessWidget {
  final int movieId;
  final String token;

  const MovieDetailsPage({
    super.key,
    required this.movieId,
    required this.token,
  });

  // Fetch movie details
  Future<Movie> _fetchMovieDetails() async {
    final apiService = UserApiService();
    try {
      return await apiService.getMovieDetails(movieId, token);
    } catch (e) {
      throw Exception('Failed to load movie details: $e');
    }
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
                    // Movie Background Image
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

                    // Movie Title
                    Text(
                      movie.titleLong,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Year, Rating, and Language
                    Text(
                      'Year: ${movie.year} | Rating: ${movie.rating.toStringAsFixed(1)} | IMDb Code: ${movie.imdbCode}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),

                    // Genres
                    if (movie.genres.isNotEmpty)
                      Text(
                        'Genres: ${movie.genres.join(', ')}',
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    const SizedBox(height: 16),

                    // Movie Description
                    Text(
                      movie.description.isEmpty
                          ? 'No description available.'
                          : movie.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // Torrents Section
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
                                // Handle torrent download
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
    );
  }
}
