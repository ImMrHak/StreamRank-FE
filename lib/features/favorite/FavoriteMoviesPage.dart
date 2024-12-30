import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/theme/theme_provider.dart';
import 'package:streamrank/features/movie/MovieDetailsPage.dart';
import 'package:streamrank/features/widgets/custom_drawer.dart';
import 'dart:convert';

class FavoriteMoviesPage extends StatefulWidget {
  const FavoriteMoviesPage({Key? key}) : super(key: key);

  @override
  State<FavoriteMoviesPage> createState() => _FavoriteMoviesPageState();
}

class _FavoriteMoviesPageState extends State<FavoriteMoviesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<Movie> favoriteMovies = [];
  bool isLoading = true;
  final String _localFavoritesKey = 'local_favorites';
  final UserApiService _userApiService = UserApiService();

  @override
  void initState() {
    super.initState();
    _loadFavoriteMovies();
  }

  Future<void> _loadFavoriteMovies() async {
    setState(() {
      isLoading = true;
    });

    try {
      if (AuthApiService.isSignedIn) {
        final favorites = await _userApiService.getFavoriteMovies();
        setState(() {
          favoriteMovies = favorites;
          isLoading = false;
        });
      } else {
        final prefs = await SharedPreferences.getInstance();
        final String? favoritesJson = prefs.getString(_localFavoritesKey);
        if (favoritesJson != null) {
          final List<dynamic> decodedList = json.decode(favoritesJson);
          setState(() {
            favoriteMovies = decodedList.map((item) => Movie.fromJson(item)).toList();
            isLoading = false;
          });
        } else {
          setState(() {
            favoriteMovies = [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveFavoritesToLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = json.encode(favoriteMovies.map((m) => m.toJson()).toList());
    await prefs.setString(_localFavoritesKey, encodedList);
  }

  Future<void> _toggleFavorite(Movie movie) async {
    try {
      if (AuthApiService.isSignedIn) {
        final isFavorite = favoriteMovies.any((m) => m.id == movie.id);
        if (isFavorite) {
          await _userApiService.removeFromFavorites(movie.id);
          setState(() {
            favoriteMovies.removeWhere((m) => m.id == movie.id);
          });
        } else {
          await _userApiService.addToFavorites(movie.id);
          setState(() {
            favoriteMovies.add(movie);
          });
        }
      } else {
        setState(() {
          final isFavorite = favoriteMovies.any((m) => m.id == movie.id);
          if (isFavorite) {
            favoriteMovies.removeWhere((m) => m.id == movie.id);
          } else {
            favoriteMovies.add(movie);
          }
        });
        await _saveFavoritesToLocal();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(
          'My Favorites',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onBackground,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onBackground),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : favoriteMovies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 64,
                        color: Theme.of(context).colorScheme.onBackground.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No favorites yet',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start adding movies to your favorites',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.7,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: favoriteMovies.length,
                  itemBuilder: (context, index) {
                    final movie = favoriteMovies[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MovieDetailsPage(selectedMovie: movie),
                          ),
                        );
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: ImageNetwork(
                              image: movie.coverImage,
                              height: double.infinity,
                              width: double.infinity,
                              fitAndroidIos: BoxFit.cover,
                              onLoading: Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              onError: Container(
                                color: Theme.of(context).colorScheme.surface,
                                child: Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Theme.of(context).colorScheme.background.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            right: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onBackground,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      movie.rating.toString(),
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onBackground,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () => _toggleFavorite(movie),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
