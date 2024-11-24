import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/FavoriteMovie.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/features/widgets/custom_drawer.dart';
class FavoriteMoviesPage extends StatelessWidget {
  const FavoriteMoviesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Movies'),
      ),
      drawer: const CustomDrawer(),
      body: FutureBuilder<List<FavoriteMovie>>(
        future: UserApiService.getFavoriteMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No favorite movies yet!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else if (snapshot.hasData) {
            final favoriteMovies = snapshot.data!;
            return ListView.builder(
              itemCount: favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = favoriteMovies[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      movie.imageCover,
                      height: 50,
                      width: 50,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ),
                  title: Text(movie.movieTitle),
                  subtitle: Text('Rating: ${movie.movieRating}'),
                );
              },
            );
          } else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}
