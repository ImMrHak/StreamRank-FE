import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:provider/provider.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/theme/theme_provider.dart';
import 'package:streamrank/features/favorite/FavoriteMoviesPage.dart';
import 'package:streamrank/features/widgets/custom_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class MovieDetailsPage extends StatefulWidget {
  final Movie selectedMovie;

  const MovieDetailsPage({Key? key, required this.selectedMovie})
      : super(key: key);

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

Future<void> _launchWatchUrl(String imdbCode) async {
  final url = Uri.parse('https://vidsrc.to/embed/movie/$imdbCode');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isFavorite = false;
  final UserApiService _userApiService = UserApiService();

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      if (AuthApiService.isSignedIn) {
        final favorites = await _userApiService.getFavoriteMovies();
        setState(() {
          _isFavorite = favorites.any((m) => m.id == widget.selectedMovie.id);
        });
      } else {
        final prefs = await SharedPreferences.getInstance();
        final String? favoritesJson = prefs.getString('local_favorites');
        if (favoritesJson != null) {
          final List<dynamic> favorites = json.decode(favoritesJson);
          setState(() {
            _isFavorite =
                favorites.any((m) => m['id'] == widget.selectedMovie.id);
          });
        } else {
          setState(() {
            _isFavorite = false;
          });
        }
      }
    } catch (e) {
      print('Error checking favorite status: $e');
      setState(() {
        _isFavorite = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    try {
      if (AuthApiService.isSignedIn) {
        if (_isFavorite) {
          await _userApiService.removeFromFavorites(widget.selectedMovie.id);
        } else {
          await _userApiService.addToFavorites(widget.selectedMovie.id);
        }
        setState(() {
          _isFavorite = !_isFavorite;
        });
      } else {
        final prefs = await SharedPreferences.getInstance();
        final String? favoritesJson = prefs.getString('local_favorites');
        List<Map<String, dynamic>> favorites = [];

        if (favoritesJson != null) {
          favorites =
              List<Map<String, dynamic>>.from(json.decode(favoritesJson));
        }

        setState(() {
          if (_isFavorite) {
            favorites.removeWhere((m) => m['id'] == widget.selectedMovie.id);
          } else {
            favorites.add(widget.selectedMovie.toJson());
          }
          _isFavorite = !_isFavorite;
        });

        await prefs.setString('local_favorites', json.encode(favorites));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite ? 'Added to favorites' : 'Removed from favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating favorites: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      key: _scaffoldKey,
      drawer: const CustomDrawer(),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) {
            _scaffoldKey.currentState?.openDrawer();
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              floating: true,
              pinned: true,
              expandedHeight: 500,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    ImageNetwork(
                      image: widget.selectedMovie.backgroundImage,
                      height: 500,
                      width: MediaQuery.of(context).size.width,
                      fitAndroidIos: BoxFit.cover,
                      onLoading: Container(
                          color: Theme.of(context).colorScheme.surface),
                      onError: Container(
                          color: Theme.of(context).colorScheme.surface),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Theme.of(context)
                                .colorScheme
                                .background
                                .withOpacity(0.8),
                            Theme.of(context).colorScheme.background,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 80,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.selectedMovie.title,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onBackground,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // Play movie functionality
                                  _launchWatchUrl(
                                      widget.selectedMovie.imdbCode);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                icon: Icon(Icons.play_arrow),
                                label: Text('Play'),
                              ),
                              const SizedBox(width: 16),
                              if (AuthApiService.isSignedIn) ...[
                                ElevatedButton.icon(
                                  onPressed: _toggleFavorite,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onSurface,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 24,
                                      vertical: 12,
                                    ),
                                  ),
                                  icon: Icon(_isFavorite
                                      ? Icons.favorite
                                      : Icons.favorite_border),
                                  label: Text(_isFavorite
                                      ? 'Remove from Favorites'
                                      : 'Add to Favorites'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                if (AuthApiService.isSignedIn) ...[
                  IconButton(
                    icon: Icon(Icons.favorite_border),
                    color: Theme.of(context).colorScheme.onSurface,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoriteMoviesPage(),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overview',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.selectedMovie.summary,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (widget.selectedMovie.genres.isNotEmpty) ...[
                      Text(
                        'Genres',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: widget.selectedMovie.genres.map((genre) {
                          return Chip(
                            label: Text(genre),
                            backgroundColor:
                                Theme.of(context).colorScheme.surface,
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoItem(
                          context,
                          Icons.star,
                          'Rating',
                          widget.selectedMovie.rating.toString(),
                        ),
                        _buildInfoItem(
                          context,
                          Icons.calendar_today,
                          'Year',
                          widget.selectedMovie.year.toString(),
                        ),
                        _buildInfoItem(
                          context,
                          Icons.timer,
                          'Runtime',
                          '${widget.selectedMovie.runtime} min',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
      BuildContext context, IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
