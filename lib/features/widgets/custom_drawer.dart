// custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/utils/Config.dart';
import 'package:streamrank/features/authentication/SignInPage.dart';
import 'package:streamrank/features/favorite/FavoriteMoviesPage.dart';
import 'package:streamrank/features/movie/MoviesPage.dart';
import 'package:streamrank/features/profile/Profile.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: const Text("StreamRank",
                style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.movie),
            title: const Text('Movies'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MoviesPage()));
            },
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
          if (AuthApiService.isSignedIn) ...[
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FavoriteMoviesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Disconnect'),
              onTap: () {
                AuthApiService.isSignedIn = false;
                Config.logout();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SignInPage()));
              },
            ),
          ]
        ],
      ),
    );
  }
}
