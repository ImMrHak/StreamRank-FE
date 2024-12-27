import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/utils/Config.dart';
import 'package:streamrank/core/theme/theme_provider.dart';
import 'package:streamrank/features/authentication/SignInPage.dart';
import 'package:streamrank/features/movie/MoviesPage.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive
            ? Colors.red
            : isDark
                ? Colors.white
                : Colors.black87,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive
              ? Colors.red
              : isDark
                  ? Colors.white
                  : Colors.black87,
        ),
      ),
      onTap: onTap,
      splashColor: Colors.red.withOpacity(0.1),
      hoverColor: Colors.red.withOpacity(0.05),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(-1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.easeInOut,
        )),
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.red.shade900,
                    Colors.red,
                  ],
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.movie_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "StreamRank",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildListTile(
                    context,
                    icon: Icons.movie_outlined,
                    title: 'Movies',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MoviesPage()),
                    ),
                    isDark: isDark,
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.live_tv_outlined,
                    title: 'Channels',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  _buildListTile(
                    context,
                    icon: Icons.animation_outlined,
                    title: 'Animes',
                    onTap: () {},
                    isDark: isDark,
                  ),
                  Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
                  _buildListTile(
                    context,
                    icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    title: isDark ? 'Light Mode' : 'Dark Mode',
                    onTap: () => themeProvider.toggleTheme(),
                    isDark: isDark,
                  ),
                  if (AuthApiService.isSignedIn) ...[
                    Divider(color: isDark ? Colors.grey[800] : Colors.grey[300]),
                    _buildListTile(
                      context,
                      icon: Icons.logout,
                      title: 'Disconnect',
                      onTap: () {
                        AuthApiService.isSignedIn = false;
                        Config.logout();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SignInPage()),
                          (route) => false,
                        );
                      },
                      isDark: isDark,
                      isDestructive: true,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
