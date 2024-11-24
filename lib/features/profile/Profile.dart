import 'package:flutter/material.dart';
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/models/User.dart';
import 'package:streamrank/features/widgets/custom_drawer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final UserApiService _userApiService = UserApiService();
  late Future<User> _userFuture;

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

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

  Future<void> _saveChanges() async {
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;
    String email = _emailController.text;

    // Logic to save the changes, for example, calling an API to update user data
    print('Changes saved: $firstName, $lastName, $email');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: const CustomDrawer(),
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
            _firstNameController.text = user.firstName;
            _lastNameController.text = user.lastName;
            _emailController.text = user.email;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 8,
                      margin: const EdgeInsets.only(bottom: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text('Edit Profile',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 16.0),
                            TextField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                  labelText: 'First Name'),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              controller: _lastNameController,
                              decoration:
                                  const InputDecoration(labelText: 'Last Name'),
                            ),
                            const SizedBox(height: 16.0),
                            TextField(
                              controller: _emailController,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _saveChanges,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: const Text('Save Changes',
                          style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
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
