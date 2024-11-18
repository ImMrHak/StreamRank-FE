import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:streamrank/features/authentication/SignInPage.dart';
import 'package:streamrank/features/movie/MovieDetailsPage.dart';
import 'package:streamrank/features/movie/MoviesPage.dart';

void main() async {
  await dotenv.load(fileName: "../.env");  // Load .env before running the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreamRank',
      // Define the home page or initial route for the app
      initialRoute: '/signin',  // You can set this to '/signin' or '/' as needed
      routes: {
        '/signin': (context) => SignInPage(),
        '/movies': (context) => MoviesPage(),// Correct route to MoviesPage
      },
      // This handles unknown routes (if you attempt to navigate to an undefined route)
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: Text('Page Not Found')),
            body: Center(child: Text('404 - Page not found')),
          ),
        );
      },
    );
  }
}
