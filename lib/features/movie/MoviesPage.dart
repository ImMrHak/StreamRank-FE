import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/back-end/ApiService.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/network/no-back-end/MovieApiService.dart';
import 'package:streamrank/features/movie/FavoriteMoviesPage.dart';
import 'package:streamrank/features/movie/MovieDetailsPage.dart';

class MoviesPage extends StatefulWidget {
  const MoviesPage({super.key});

  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  List<Movie> _movies = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreMovies = true;
  bool _isSearchMode = false;
  TextEditingController _searchController = TextEditingController();

  Future<List<Movie>> _fetchMovies() async {
    ApiService apiService = (await AuthApiService.ping()) ? UserApiService() : MovieApiService();
    try {
      return await apiService.getMovies();
    } catch (e) {
      print("Error fetching movies from UserApiService: $e");
      apiService = MovieApiService();
      try {
        return await apiService.getMovies();
      } catch (e) {
        throw Exception('Failed to load movies from both services: $e');
      }
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      ApiService apiService = (await AuthApiService.ping()) ? UserApiService() : MovieApiService();

      try {
        final searchedMovies = await apiService.searchMovies(query);
        setState(() {
          _movies = searchedMovies;
          _currentPage = 1;
          _hasMoreMovies = false;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to search movies: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      final originalMovies = await _fetchMovies();
      setState(() {
        _movies = originalMovies;
        _currentPage = 1;
        _hasMoreMovies = true;
      });
    }
  }

  Future<void> _fetchNextMovies() async {
    if (_isLoading || !_hasMoreMovies) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final apiService = UserApiService();
      final newMovies = await apiService.getNextMovies(_currentPage);
      if (newMovies.isEmpty) {
        setState(() {
          _hasMoreMovies = false;
        });
      } else {
        setState(() {
          _movies.addAll(newMovies);
          _currentPage++;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load next movies: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                      builder: (context) => MovieDetailsPage(movieId: movie.id),
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
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearchMode
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search movies...',
            border: InputBorder.none,
          ),
          onSubmitted: (query) async {
            await _searchMovies(query);
          },
        )
            : const Text('StreamRank'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(_isSearchMode ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchMode = !_isSearchMode;
                if (!_isSearchMode) {
                  _searchController.clear();
                  Future.delayed(Duration.zero, () async => await _fetchMovies());
                }
              });
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.blue),
              child: const Text("StreamRank", style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.movie),
              title: const Text('Movies'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.live_tv),
              title: const Text('Channels'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.animation),
              title: const Text('Animes'),
              onTap: () {},
            ),
            if(AuthApiService.isSignedIn) ...[
              ListTile(
                leading: const Icon(Icons.favorite),
                title: const Text('Favorites'),
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) =>
                          const FavoriteMoviesPage()
                      ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profile'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Disconnect'),
                onTap: () {},
              ),
            ]
          ],
        ),
      ),
      body: FutureBuilder<List<Movie>>(
        future: _fetchMovies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            if (!_isSearchMode) {
              _movies = snapshot.data!;
            }
            return _buildMoviesList();
          } else {
            return const Center(child: Text('No movies found.'));
          }
        },
      ),
    );
  }
}
