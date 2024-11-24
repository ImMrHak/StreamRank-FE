import 'package:flutter/material.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/User.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserApiService _userApiService = UserApiService();
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserInfo();
  }

  Future<User> _fetchUserInfo() async {
    try {
      return await _userApiService.getMyInfo();
    } catch (e) {
      throw Exception('Failed to load user info: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: FutureBuilder<User>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else if (snapshot.hasData) {
          final user = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('First Name: ${user.firstName}', style: const TextStyle(fontSize: 18)),
                Text('Last Name: ${user.lastName}', style: const TextStyle(fontSize: 18)),
                Text('Email: ${user.email}', style: const TextStyle(fontSize: 18)),
              ],
            ),
          );
        } else {
          return const Center(child: Text('No user data available.'));
        }
      },
    ),
  );
}
}