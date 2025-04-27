import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../widgets/location_input.dart';
import '../widgets/custom_button.dart';
import 'map_screen.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({Key? key}) : super(key: key);

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final loc.Location _location = loc.Location();
  bool _isLocationLoading = false;

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _navigateToMap(bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(
          isPickup: isPickup,
          initialText:
              isPickup ? _pickupController.text : _destinationController.text,
        ),
      ),
    );

    if (result != null && result is String) {
      setState(() {
        if (isPickup) {
          _pickupController.text = result;
        } else {
          _destinationController.text = result;
        }
      });
    }
  }

  Future<void> _useCurrentLocation(bool isPickup) async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showErrorMessage(
              'Location services are disabled. Please enable them to use this feature.');
          setState(() {
            _isLocationLoading = false;
          });
          return;
        }
      }

      // Check if permission is granted
      loc.PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == loc.PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != loc.PermissionStatus.granted) {
          _showErrorMessage(
              'Location permission denied. Please grant permission to use this feature.');
          setState(() {
            _isLocationLoading = false;
          });
          return;
        }
      }

      // Get current location
      final loc.LocationData locationData = await _location.getLocation();
      double? lat = locationData.latitude;
      double? lng = locationData.longitude;

      if (lat == null || lng == null) {
        _showErrorMessage(
            'Could not get your current location. Please try again.');
        setState(() {
          _isLocationLoading = false;
        });
        return;
      }

      // Convert location to address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);

        if (placemarks.isEmpty) {
          _showErrorMessage(
              'Could not determine your address. Please try again.');
          setState(() {
            _isLocationLoading = false;
          });
          return;
        }

        Placemark place = placemarks.first;
        String address = '';

        // Build address with available components
        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }

        if (place.country != null && place.country!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.country!;
        }

        if (address.isEmpty) {
          address = "Current Location";
        }

        if (mounted) {
          setState(() {
            if (isPickup) {
              _pickupController.text = address;
            } else {
              _destinationController.text = address;
            }
            _isLocationLoading = false;
          });
        }
      } catch (e) {
        print('Error getting address: $e');
        _showErrorMessage('Error determining your address: ${e.toString()}');
        if (mounted) {
          setState(() {
            _isLocationLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error getting current location: $e');
      _showErrorMessage('Error getting your location: ${e.toString()}');
      if (mounted) {
        setState(() {
          _isLocationLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              // Top header with Zipp logo
              Container(
                padding: const EdgeInsets.only(
                  top: 60,
                  bottom: 20,
                  left: 16,
                  right: 16,
                ),
                width: double.infinity,
                color: AppColors.primaryBlue,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zipp',
                      style: AppTextStyles.appBarTitle,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your reliable logistics partner',
                      style: AppTextStyles.appBarSubtitle,
                    ),
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'Where are you going?',
                        style: AppTextStyles.heading,
                      ),
                      const SizedBox(height: 32),

                      // Pickup location section
                      Row(
                        children: [
                          Expanded(
                            child: LocationInput(
                              hintText: 'Pickup Location',
                              iconBackgroundColor: AppColors.iconGreen,
                              icon: FontAwesomeIcons.locationCrosshairs,
                              controller: _pickupController,
                              readOnly: false,
                              onMapTap: () => _navigateToMap(true),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.my_location,
                                color: AppColors.actionBlue),
                            onPressed: _isLocationLoading
                                ? null
                                : () => _useCurrentLocation(true),
                            tooltip: 'Use current location',
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Destination section
                      Row(
                        children: [
                          Expanded(
                            child: LocationInput(
                              hintText: 'Destination',
                              iconBackgroundColor: AppColors.iconRed,
                              icon: FontAwesomeIcons.locationDot,
                              controller: _destinationController,
                              readOnly: false,
                              onMapTap: () => _navigateToMap(false),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.my_location,
                                color: AppColors.actionBlue),
                            onPressed: _isLocationLoading
                                ? null
                                : () => _useCurrentLocation(false),
                            tooltip: 'Use current location',
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Continue button
                      CustomButton(
                        text: 'Continue',
                        icon: Icons.arrow_forward,
                        onPressed: () {
                          // Validate and continue
                          if (_pickupController.text.isNotEmpty &&
                              _destinationController.text.isNotEmpty) {
                            // Navigate to next screen
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Booking from ${_pickupController.text} to ${_destinationController.text}'),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          } else {
                            // Show error
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Please enter pickup and destination locations'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Bottom navigation
              Container(
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(FontAwesomeIcons.truck, 'Book', true),
                    _buildNavItem(FontAwesomeIcons.listCheck, 'Trips', false),
                    _buildNavItem(FontAwesomeIcons.user, 'Profile', false),
                  ],
                ),
              ),
            ],
          ),

          // Loading indicator
          if (_isLocationLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? AppColors.primaryBlue : Colors.grey,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primaryBlue : Colors.grey,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
