import 'package:flutter/material.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../config/app_config.dart';

class LocationAutocomplete extends StatelessWidget {
  final String hintText;
  final Color iconBackgroundColor;
  final IconData icon;
  final VoidCallback? onMapTap;
  final TextEditingController controller;
  final Function(String) onLocationSelected;
  final bool isPickup;

  const LocationAutocomplete({
    Key? key,
    required this.hintText,
    required this.iconBackgroundColor,
    required this.icon,
    this.onMapTap,
    required this.controller,
    required this.onLocationSelected,
    required this.isPickup,
  }) : super(key: key);

  Future<void> _handlePressButton(BuildContext context) async {
    // Initialize the Places API with your API key
    final GoogleMapsPlaces _places = GoogleMapsPlaces(
      apiKey: AppConfig.placesApiKey,
    );

    // Show the autocomplete search dialog
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: AppConfig.placesApiKey,
      mode: Mode.overlay, // Mode.fullscreen or Mode.overlay
      language: "en",
      components: [
        Component(Component.country, "us")
      ], // Limit to specific country
      types: [], // You can specify place types e.g., ["address", "establishment"]
      strictbounds: false,
      hint: "Search for a location",
    );

    // Handle the selected prediction
    if (p != null) {
      // Get details of the selected place
      PlacesDetailsResponse detail =
          await _places.getDetailsByPlaceId(p.placeId!);
      final address = detail.result.formattedAddress;

      // Update the controller and call the callback
      if (address != null) {
        controller.text = address;
        onLocationSelected(address);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(
                icon,
                color: icon == FontAwesomeIcons.locationDot
                    ? Colors.red
                    : Colors.green,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: InkWell(
              onTap: () => _handlePressButton(context),
              child: IgnorePointer(
                child: TextField(
                  controller: controller,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyles.hintText,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    suffixIcon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  style: AppTextStyles.inputText,
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: onMapTap,
            child: Icon(
              Icons.map_outlined,
              color: Colors.grey.shade400,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
