import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Config {
  static String get springBaseUrl {
    return dotenv.env['API_URL_SPRING'].toString();
  }

  static String get moviesBaseUrl {
    return dotenv.env['API_URL_YTS'].toString();
  }

  static final FlutterSecureStorage secureStorage = FlutterSecureStorage();

   // Retrieve token
  static Future<String?> getToken() async {
    return await secureStorage.read(key: 'jwt_token');
  }

  // Retrieve rid
  static Future<String?> getRid() async {
    return await secureStorage.read(key: 'rid');
  }

  // Logout - Clear secure storage
  static Future<void> logout() async {
    await secureStorage.delete(key: 'jwt_token');
    await secureStorage.delete(key: 'rid');
  }
}