# Google Maps Setup Guide

## Error: Maps not showing on physical devices

If you encounter errors like the following on a physical device:

```
D/Google Android Maps SDK: "AdvancedMarkers: false: Capabilities unavailable without a Map ID."
Data-driven styling: false
```

You need to properly configure the Google Maps API Key and Map ID.

## Setting up Google Maps API Key and Map ID

### Step 1: Create a Google Maps API Key and Map ID

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Navigate to "APIs & Services" > "Dashboard"
4. Click "+ ENABLE APIS AND SERVICES"
5. Search for and enable the following APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Places API (if needed)
6. Go to "APIs & Services" > "Credentials"
7. Click "Create Credentials" > "API Key"
8. Restrict the API key to your app's package name and SHA-1 certificate fingerprint
9. Copy your API key

### Step 2: Create a Map ID (Required for Advanced Features)

1. Go to the [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to "Google Maps Platform" > "Map Management" > "Map IDs"
3. Click "CREATE MAP ID"
4. Give your Map ID a name (e.g., "Zipp Logistics Map")
5. Select the relevant map features you need
6. Create the Map ID and copy it

### Step 3: Update Android Configuration

1. Open `android/app/src/main/AndroidManifest.xml`
2. Replace `YOUR_API_KEY_HERE` with your actual API key in this section:
   ```xml
   <meta-data
       android:name="com.google.android.geo.API_KEY"
       android:value="YOUR_API_KEY_HERE" />
   ```
3. Replace `YOUR_MAP_ID_HERE` with your actual Map ID in this section:
   ```xml
   <meta-data
       android:name="com.google.android.geo.MAP_ID"
       android:value="YOUR_MAP_ID_HERE" />
   ```

### Step 4: Update iOS Configuration

1. Open `ios/Runner/AppDelegate.swift`
2. Replace `YOUR_API_KEY_HERE` with your actual API key:
   ```swift
   GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
   ```
3. Replace `YOUR_MAP_ID_HERE` with your actual Map ID:
   ```swift
   GMSMapID.init(identifier: "YOUR_MAP_ID_HERE")
   ```

## Troubleshooting

If the map still doesn't appear:

1. Ensure that billing is enabled on your Google Cloud project
2. Check that you've enabled all required APIs
3. Verify that your API key restrictions (if any) are correct for your app's package name
4. For Android, make sure your SHA-1 certificate fingerprint is correctly added in the Google Cloud Console
5. Clear your app's cache or uninstall and reinstall
6. Check for any error messages in the console log

## References

- [Google Maps Android SDK Guide](https://developers.google.com/maps/documentation/android-sdk/overview)
- [Google Maps iOS SDK Guide](https://developers.google.com/maps/documentation/ios-sdk/overview)
- [Google Maps API Key Setup](https://developers.google.com/maps/documentation/android-sdk/get-api-key)
