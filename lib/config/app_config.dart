import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // Initialize the config
  static Future<void> init() async {
    try {
      // Load the .env file
      await dotenv.load();
    } catch (e) {
      print('Error loading .env file: $e');
      // In a real app, you would handle this more gracefully
    }
  }

  // Placeholder for Maps API Key
  static String get mapsApiKey {
    return "YOUR_API_KEY"; // Placeholder - we'll use mock data instead
  }

  // Placeholder for Places API Key
  static String get placesApiKey {
    return mapsApiKey;
  }

  // This method is for demo purposes only - in a real app, you would use dotenv or similar package
  static String getApiKey() {
    // Placeholder implementation - returns a value based on build mode
    return mapsApiKey;
  }
}
