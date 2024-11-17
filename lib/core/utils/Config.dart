import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get springBaseUrl {
    return dotenv.env['API_URL_SPRING'].toString();
  }

  static String get moviesBaseUrl {
    return dotenv.env['API_URL_YTS'].toString();
  }
}