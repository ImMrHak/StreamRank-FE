import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:streamrank/core/network/back-end/dto/authentication/UserSignInDTO.dart';
import 'package:streamrank/core/utils/Config.dart';

class AuthApiService {
  final String baseUrl = Config.springBaseUrl;

  // Sign In - /SignIn
  Future<Map<String, dynamic>> signIn(UserSignInDTO signInDTO) async {
    final response = await http.post(
      Uri.parse(baseUrl + 'auth/SignIn'),
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

      // Return a map containing both token and rid
      return {
        'token': token,
        'rid': rid,
      };
    } else {
      throw Exception('Failed to sign in');
    }
  }
}
