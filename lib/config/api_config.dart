import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get fdaApiKey {
    final key = dotenv.env['FDA_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('FDA_API_KEY not found in environment variables');
    }
    return key;
  }

  // You can add other API configurations here
  static String get fdaBaseUrl => 'https://api.fda.gov';
}
