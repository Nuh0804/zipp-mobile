# Zipp Logistics

A Flutter mobile application for logistics and delivery services. The app allows users to select pickup and destination locations, either by typing addresses or selecting locations on an interactive map.

## Features

- User-friendly interface for entering pickup and destination locations
- Interactive Google Maps integration for visual location selection
- Bottom navigation with Book, Trips, and Profile tabs
- Clean, modern UI design

## Setup Google Maps API

To use the Google Maps functionality in the app, you need to obtain a Google Maps API key:

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Search for and enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API
   - Places API
4. Create API credentials (API Key)
5. Add restrictions to your API key (based on application IDs)

### Add Google Maps API Key to the Project (Secure Method)

To keep your API keys secure and avoid committing them to Git, follow these steps:

#### Local Development

1. Create a `.env` file in the root of your project (this file is already in .gitignore)

   ```
   MAPS_API_KEY=your_actual_api_key_here
   ```

2. For Android:

   - The app is already set up to use `${MAPS_API_KEY}` in the AndroidManifest.xml
   - During build, this will be replaced with your actual key

3. For iOS:

   - The app uses environment variables to access the API key
   - When running locally, you might need to set this in your IDE or terminal

4. For Web:
   - Before deploying, replace `API_KEY_PLACEHOLDER` in web/index.html with your actual key
   - For local testing, you can temporarily add your key for testing purposes

#### Setting Up for CI/CD & Production

For a CI/CD pipeline, you should:

1. Store your API keys as secure environment variables in your CI/CD system
2. Create a build script that replaces the placeholders with the actual keys during build
3. Never commit actual API keys to the repository

## Getting Started

1. Clone the repository
2. Create a `.env` file with your Google Maps API key
3. Run `flutter pub get` to install dependencies
4. Run the app: `flutter run`

## Dependencies

- [google_maps_flutter](https://pub.dev/packages/google_maps_flutter) - For Google Maps integration
- [location](https://pub.dev/packages/location) - For accessing device location
- [geocoding](https://pub.dev/packages/geocoding) - For converting between coordinates and addresses
- [google_fonts](https://pub.dev/packages/google_fonts) - For text styling
- [font_awesome_flutter](https://pub.dev/packages/font_awesome_flutter) - For additional icons
