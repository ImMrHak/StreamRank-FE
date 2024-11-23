import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/models/Movie.dart';

class FavoriteMoviesPage extends StatelessWidget {
  final List<Movie> favoriteMovies;

  const FavoriteMoviesPage({
    super.key,
    required this.favoriteMovies,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Movies'),
      ),
      body: favoriteMovies.isEmpty
          ? const Center(
              child: Text(
                'No favorite movies yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = favoriteMovies[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: ImageNetwork(
                      height: 50,
                      width: 50,
                      image: movie.largeCoverImage,
                      onLoading: const CircularProgressIndicator(),
                    ),
                  ),
                  title: Text(movie.title),
                  subtitle: Text('Year: ${movie.year}, Rating: ${movie.rating}'),
                );
              },
            ),
    );
  }
}
