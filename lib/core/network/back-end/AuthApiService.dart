import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamrank/core/network/back-end/UserApiService.dart';
import 'package:streamrank/core/network/back-end/dto/authentication/UserSignUpDTO.dart';
import 'package:streamrank/core/network/back-end/dto/authentication/UserSignInDTO.dart';
import 'package:streamrank/core/utils/Config.dart';

class AuthApiService {
  final String baseUrl = Config.springBaseUrl;
  static bool isSignedIn = false;
  // Sign Up - /SignUp
  @override
  Future<Map<String, dynamic>> signUp(UserSignUpDTO signUpDTO) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/SignUp'),
      body: jsonEncode(signUpDTO.toJson()),
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

      // Save token and rid in secure storage via Config
      await Config.secureStorage.write(key: 'jwt_token', value: token);
      await Config.secureStorage.write(key: 'rid', value: rid);

      // Return a map containing both token and rid
      return {
        'token': token,
        'rid': rid,
        'status': 'success'
      };
    } else {
      throw Exception('Failed to sign up');
    }
  }

  // Sign In - /SignIn
  Future<Map<String, dynamic>> signIn(UserSignInDTO signInDTO) async {
    final response = await http.post(
      Uri.parse('${baseUrl}auth/SignIn'),
      body: jsonEncode(signInDTO.toJson()),
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

      // Save token and rid in secure storage via Config
      await Config.secureStorage.write(key: 'jwt_token', value: token);
      await Config.secureStorage.write(key: 'rid', value: rid);

      print("TOKEN:" + token);

      isSignedIn = true;

      // Return a map containing both token and rid
      return {
        'token': token,
        'rid': rid,
        'status': 'success'
      };
    } else {
      throw Exception('Failed to sign in');
    }
  }

  static Future<bool> ping() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.springBaseUrl}auth/ping'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));  // Increase timeout if needed

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['status'] == 'success') ? true : false;
      } else {
        // Log the status code if the request fails
        print('Ping failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Log the exception if there is an error
      print('Ping request error: $e');
    }
    return false;
  }
}
