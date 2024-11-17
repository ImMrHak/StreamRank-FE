import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamrank/core/utils/Config.dart';

class AuthApiService {
  final String baseUrl = Config.springBaseUrl;

  // Sign In - /SignIn
  Future<Map<String, dynamic>> signIn(String usernameOrEmail, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'auth/SignIn'),
      body: json.encode({
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'error') {
        throw Exception('Sign-in failed: ${data['message']}');
      }

      // Extract the token and rid from the response
      final String token = data['data']['token'];
      final String rid = data['data']['rid'];

      // Return a map containing both token and rid
      return {
        'token': token,
        'rid': rid,
      };
    } else {
      throw Exception('Failed to sign in');
    }
  }

  // Sign Up - /SignUp
  Future<Map<String, dynamic>> signUp(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'auth/SignUp'),
      body: json.encode({
        'username': username,
        'email': email,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'error') {
        throw Exception('Sign-up failed: ${data['message']}');
      }

      // Extract the token and rid from the response
      final String token = data['data']['token'];
      final String rid = data['data']['rid'];

      // Return a map containing both token and rid
      return {
        'token': token,
        'rid': rid,
      };
    } else {
      throw Exception('Failed to sign up');
    }
  }
}
