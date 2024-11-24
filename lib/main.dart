import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/back-end/dto/authentication/UserSignInDTO.dart';
import 'package:streamrank/core/network/no-back-end/MovieApiService.dart';
import 'package:streamrank/features/authentication/SignInPage.dart';
import 'package:streamrank/features/movie/MoviesPage.dart';

void main() async {
  await dotenv.load(fileName: ".env");  // Load .env before running the app
/*
  AuthApiService authApiService = AuthApiService();

  authApiService.signIn(new UserSignInDTO(usernameOrEmail: "yassine2001", password: "yassine2001"));

  UserApiService userApiService = UserApiService();
  print(userApiService.getMyInfo());*/

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StreamRank',
      // Define the home page or initial route for the app
      initialRoute: '/signin',  // You can set this to '/signin' or '/' as needed
      routes: {
        '/signin': (context) => SignInPage(),
        '/movies': (context) => const MoviesPage(),// Correct route to MoviesPage
      },
      // This handles unknown routes (if you attempt to navigate to an undefined route)
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page Not Found')),
            body: const Center(child: Text('404 - Page not found')),
          ),
        );
      },
    );
  }
}
