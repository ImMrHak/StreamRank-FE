import 'package:flutter/material.dart';
import 'package:image_network/image_network.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/network/models/Movie.dart';
import 'package:streamrank/core/network/no-back-end/MovieApiService.dart';
import 'package:streamrank/core/utils/Config.dart';
import 'package:streamrank/features/authentication/SignInPage.dart';
import 'package:streamrank/features/favorite/FavoriteMoviesPage.dart';
import 'package:streamrank/features/movie/MovieDetailsPage.dart';
import 'package:streamrank/features/profile/Profile.dart';
import 'package:streamrank/features/widgets/custom_drawer.dart';

class MoviesPage extends StatefulWidget {
  final Key? key;

  MoviesPage({this.key}) : super(key: key);

  @override
  State<MoviesPage> createState() => _MoviesPageState();
}

class _MoviesPageState extends State<MoviesPage> {
  final MovieApiService _movieApiService = MovieApiService();
  final UserApiService _userApiService = UserApiService();
  final List<Movie> _movies = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchMode = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
    _loadMovies();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _checkAuthStatus() async {
    final token = await Config.getToken();
    setState(() {
      _isAuthenticated = token != null;
    });
  }

  Future<void> _loadMovies() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Movie> movies;
      final token = await Config.getToken();

      if (token != null) {
        // User is authenticated, use UserApiService
        movies = await _userApiService.getMovies();
      } else {
        // User is not authenticated, use MovieApiService
        movies = await _movieApiService.getMovies();
      }

      setState(() {
        _movies.clear();
        _movies.addAll(movies);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMovies() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      List<Movie> movies;
      final token = await Config.getToken();

      if (token != null) {
        // User is authenticated, use UserApiService
        movies = await _userApiService.getNextMovies(_currentPage + 1);
      } else {
        // User is not authenticated, use MovieApiService
        movies = await _movieApiService.getNextMovies(_currentPage + 1);
      }

      setState(() {
        _movies.addAll(movies);
        _currentPage++;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreMovies();
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      try {
        final searchedMovies = await _movieApiService.searchMovies(query);
        setState(() {
          _movies.clear();
          _movies.addAll(searchedMovies);
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _error = 'Failed to search movies: $e';
          _isLoading = false;
        });
      }
    } else {
      await _loadMovies(); // Fetch original movie list if query is empty
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Movies'),
        actions: [
          if (_isAuthenticated) ...[
            IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FavoriteMoviesPage()),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
          ] else ...[
            TextButton.icon(
              icon: Icon(Icons.login),
              label: Text('Sign In'),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => SignInPage()),
                );
              },
            ),
          ],
        ],
      ),
      drawer: _isAuthenticated ? CustomDrawer() : null,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.dx > 0) {
            // Sliding right
            _scaffoldKey.currentState?.openDrawer();
          }
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              backgroundColor:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5),
              floating: true,
              pinned: true,
              expandedHeight: 500,
              flexibleSpace: FlexibleSpaceBar(
                background: _movies.isNotEmpty
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ImageNetwork(
                            image: _movies[0].backgroundImage,
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
                                  _movies.isNotEmpty ? _movies[0].title : '',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onBackground,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 16),
                                Row(
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        if (_movies.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MovieDetailsPage(
                                                      selectedMovie:
                                                          _movies[0]),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      icon: Icon(Icons.play_arrow),
                                      label: Text('Play'),
                                    ),
                                    SizedBox(width: 16),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        if (_movies.isNotEmpty) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  MovieDetailsPage(
                                                      selectedMovie:
                                                          _movies[0]),
                                            ),
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 12,
                                        ),
                                      ),
                                      icon: Icon(Icons.info_outline),
                                      label: Text('More Info'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: Theme.of(context).scaffoldBackgroundColor),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground),
                    decoration: InputDecoration(
                      hintText: 'Search movies...',
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      prefixIcon: Icon(Icons.search,
                          color: Theme.of(context).colorScheme.onSurface),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              onPressed: () {
                                _searchController.clear();
                                _loadMovies();
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isEmpty) {
                        _loadMovies();
                      } else {
                        _searchMovies(value);
                      }
                    },
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Trending Now',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _movies.length,
                        itemBuilder: (context, index) {
                          final movie = _movies[index];
                          return Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MovieDetailsPage(selectedMovie: movie),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: SizedBox(
                                  width: 130,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      ImageNetwork(
                                        image: movie.coverImage,
                                        height: 200,
                                        width: 130,
                                        fitAndroidIos: BoxFit.cover,
                                        onLoading: Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                        onError: Container(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          child: Icon(
                                            Icons.error_outline,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
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
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        right: 8,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              movie.title,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onBackground,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.star,
                                                  color: Colors.amber,
                                                  size: 14,
                                                ),
                                                SizedBox(width: 4),
                                                Text(
                                                  movie.rating.toString(),
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onBackground,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.7,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final movie = _movies[index];
                    return Hero(
                      tag: 'movie-${movie.id}',
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  MovieDetailsPage(selectedMovie: movie),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ImageNetwork(
                                  image: movie.largeCoverImage,
                                  height: double.infinity,
                                  width: double.infinity,
                                  fitAndroidIos: BoxFit.cover,
                                  onLoading: Container(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onError: Container(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    child: Icon(
                                      Icons.error_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
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
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  right: 8,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        movie.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onBackground,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 14,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            movie.rating.toString(),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: _movies.length,
                ),
              ),
            ),
            if (_isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
