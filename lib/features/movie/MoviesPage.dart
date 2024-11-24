import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/back-end/ApiService.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/network/no-back-end/MovieApiService.dart';
import 'package:streamrank/core/utils/Config.dart';
import 'package:streamrank/features/authentication/SignInPage.dart';
import 'package:streamrank/features/movie/FavoriteMoviesPage.dart';
import 'package:streamrank/features/movie/MovieDetailsPage.dart';
import 'package:streamrank/features/profile/Profile.dart';
import 'package:streamrank/features/widgets/custom_drawer.dart';

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
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_isLoading || !_hasMoreMovies) return;
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _fetchNextMovies();
      }
    });
    _fetchInitialMovies(); // Fetch initial movies on startup
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialMovies() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final movies = await _fetchMovies();
      setState(() {
        _movies = movies;
        _currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load movies: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Movie>> _fetchMovies() async {
    ApiService apiService =
        (await AuthApiService.ping()) ? UserApiService() : MovieApiService();
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
      ApiService apiService =
          (await AuthApiService.ping()) ? UserApiService() : MovieApiService();
      try {
        final searchedMovies = await apiService.searchMovies(query);
        setState(() {
          _movies = searchedMovies;
          _currentPage = 1;
          _hasMoreMovies = false; // No more movies to load after search
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to search movies: $e')));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      await _fetchInitialMovies(); // Fetch original movie list if query is empty
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
          SnackBar(content: Text('Failed to load next movies: $e')));
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
            controller: _scrollController,
            itemCount: _movies.length +
                (_hasMoreMovies
                    ? 1
                    : 0), // Add an extra item for loading indicator
            itemBuilder: (context, index) {
              if (index == _movies.length) {
                // Show a loading indicator at the end of the list
                return _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox.shrink();
              }
              final movie = _movies[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MovieDetailsPage(movieId: movie.id)),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
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
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${movie.year} - Rating: ${movie.rating}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.grey),
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
                    hintText: 'Search movies...', border: InputBorder.none),
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
                // Toggle search mode and clear search field if exiting search mode
                if (!_isSearchMode) {
                  Future.delayed(
                      Duration.zero, () async => await _fetchInitialMovies());
                } else {
                  _searchController.clear();
                }
                _isSearchMode = !_isSearchMode;
              });
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: _buildMoviesList(), // Call build list method directly
    );
  }
}
