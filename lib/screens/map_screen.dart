import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class MapScreen extends StatefulWidget {
  final bool isPickup;
  final String initialText;

  const MapScreen({
    Key? key,
    required this.isPickup,
    this.initialText = '',
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  final Completer<GoogleMapController> _controller = Completer();
  final loc.Location _location = loc.Location();

  LatLng _center = const LatLng(
      37.42796133580664, -122.085749655962); // Default location (Google HQ)
  LatLng _selectedLocation = const LatLng(37.42796133580664, -122.085749655962);
  LatLng? _currentUserLocation;
  String _selectedAddress = '';
  bool _isLoading = true;
  bool _isMyLocationAvailable = false;
  String _debugInfo = '';
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Optimize display for maps
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Set system UI for better map visibility
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    _getCurrentLocation();
    if (widget.initialText.isNotEmpty) {
      _getLocationFromAddress(widget.initialText);
    } else {
      // Use the placeholder text if available
      _selectedAddress = widget.isPickup ? 'Pickup location' : 'Destination';
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app resuming from background
    if (state == AppLifecycleState.resumed && _mapInitialized) {
      _refreshMap();
    }
  }

  Future<void> _refreshMap() async {
    try {
      final GoogleMapController controller = await _controller.future;
      controller.setMapStyle('[]'); // Reset map style

      // Move camera to refresh the view
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
          target: _selectedLocation,
          zoom: 15,
        ),
      ));
    } catch (e) {
      _addDebugInfo('Error refreshing map: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Restore system settings
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      _addDebugInfo('Requesting location services...');

      // Check if location services are enabled
      bool serviceEnabled = await _location.serviceEnabled();
      _addDebugInfo('Location services enabled: $serviceEnabled');

      if (!serviceEnabled) {
        _addDebugInfo('Requesting to enable location services...');
        serviceEnabled = await _location.requestService();
        _addDebugInfo(
            'User response to location service request: $serviceEnabled');

        if (!serviceEnabled) {
          _addDebugInfo('User denied location services');
          _showErrorMessage(
              'Location services are disabled. Please enable location services in your device settings.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Check if permission is granted
      _addDebugInfo('Checking location permission...');
      loc.PermissionStatus permissionGranted = await _location.hasPermission();
      _addDebugInfo('Current permission status: $permissionGranted');

      if (permissionGranted == loc.PermissionStatus.denied) {
        _addDebugInfo('Permission denied, requesting permission...');
        permissionGranted = await _location.requestPermission();
        _addDebugInfo(
            'User response to permission request: $permissionGranted');

        if (permissionGranted != loc.PermissionStatus.granted) {
          _addDebugInfo('User denied permission');
          _showErrorMessage(
              'Location permission denied. Please grant location permission in your device settings.');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Get current location
      _addDebugInfo('Getting current location...');
      final loc.LocationData locationData = await _location.getLocation();
      double? lat = locationData.latitude;
      double? lng = locationData.longitude;
      _addDebugInfo('Location data received: lat=$lat, lng=$lng');

      if (lat == null || lng == null) {
        _addDebugInfo('Location data has null values');
        _showErrorMessage(
            'Could not get your location coordinates. Please try again.');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final LatLng userLocation = LatLng(lat, lng);
      _addDebugInfo('User location set to: $lat, $lng');

      setState(() {
        _center = userLocation;
        _selectedLocation = _center;
        _currentUserLocation = userLocation;
        _isMyLocationAvailable = true;
        _isLoading = false;
      });

      // Move camera to current location
      try {
        _addDebugInfo('Moving camera to user location...');
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _center,
            zoom: 15,
          ),
        ));
      } catch (e) {
        _addDebugInfo('Error animating camera: $e');
        print('Error animating camera: $e');
      }

      // Get address from location
      _addDebugInfo('Getting address from coordinates...');
      await _getAddressFromLatLng(_selectedLocation);
    } catch (e) {
      _addDebugInfo('Error getting location: $e');
      print('Error getting location: $e');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message to user
        _showErrorMessage(
            'Unable to get your current location: ${e.toString()}');
      }
    }
  }

  void _addDebugInfo(String info) {
    print('DEBUG: $info');
    if (mounted) {
      setState(() {
        _debugInfo += '• $info\n';
      });
    }
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Details',
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Location Debug Info'),
                content: SingleChildScrollView(
                  child: Text(_debugInfo),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _getLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        setState(() {
          _center = LatLng(locations.first.latitude, locations.first.longitude);
          _selectedLocation = _center;
          _selectedAddress = address;
          _isLoading = false;
        });

        // Move camera to the found location
        try {
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _center,
              zoom: 15,
            ),
          ));
        } catch (e) {
          print('Error animating camera: $e');
        }
      }
    } catch (e) {
      print('Error getting location from address: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (placemarks.isNotEmpty) {
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

        if (mounted) {
          setState(() {
            _selectedAddress =
                address.isNotEmpty ? address : "Selected Location";
          });
        }
      }
    } catch (e) {
      print('Error getting address: $e');
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _getAddressFromLatLng(location);
  }

  Future<void> _useCurrentLocation() async {
    if (_currentUserLocation != null) {
      setState(() {
        _selectedLocation = _currentUserLocation!;
      });

      try {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentUserLocation!,
            zoom: 15,
          ),
        ));
      } catch (e) {
        print('Error animating camera: $e');
      }

      await _getAddressFromLatLng(_currentUserLocation!);
    } else {
      await _getCurrentLocation();
      if (_currentUserLocation != null) {
        setState(() {
          _selectedLocation = _currentUserLocation!;
        });
        await _getAddressFromLatLng(_currentUserLocation!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Top header
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
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Interactive Map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.info_outline,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Location Debug Info'),
                            content: SingleChildScrollView(
                              child: Text(_debugInfo.isEmpty
                                  ? 'No debug information available yet.'
                                  : _debugInfo),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map section with Google Maps
          Expanded(
            child: Stack(
              children: [
                // Actual Google Map
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RepaintBoundary(
                        child: GoogleMap(
                          mapType: MapType.normal,
                          onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);
                            setState(() {
                              _mapInitialized = true;
                            });
                            _addDebugInfo('Map created successfully');
                          },
                          initialCameraPosition: CameraPosition(
                            target: _center,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('selected_location'),
                              position: _selectedLocation,
                              icon: BitmapDescriptor.defaultMarkerWithHue(
                                widget.isPickup
                                    ? BitmapDescriptor.hueGreen
                                    : BitmapDescriptor.hueRed,
                              ),
                              infoWindow: InfoWindow(
                                title: widget.isPickup
                                    ? 'Pickup Location'
                                    : 'Destination',
                                snippet: _selectedAddress,
                              ),
                            ),
                            if (_currentUserLocation != null &&
                                _selectedLocation != _currentUserLocation)
                              Marker(
                                markerId: const MarkerId('current_location'),
                                position: _currentUserLocation!,
                                icon: BitmapDescriptor.defaultMarkerWithHue(
                                    BitmapDescriptor.hueAzure),
                                infoWindow: const InfoWindow(
                                  title: 'Your Location',
                                ),
                              ),
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: true,
                          onTap: _onMapTapped,
                          zoomControlsEnabled: true,
                          mapToolbarEnabled: true,
                          compassEnabled: true,
                          trafficEnabled: false,
                          buildingsEnabled: true,
                          rotateGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          tiltGesturesEnabled: true,
                        ),
                      ),

                // Use Current Location button
                if (_isMyLocationAvailable && !_isLoading)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: FloatingActionButton.extended(
                      onPressed: _useCurrentLocation,
                      label: const Text('Use My Location'),
                      icon: const Icon(Icons.my_location),
                      backgroundColor: AppColors.actionBlue,
                    ),
                  ),

                // Selected location text display
                Positioned(
                  bottom: 80,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.isPickup
                                ? FontAwesomeIcons.locationCrosshairs
                                : FontAwesomeIcons.locationDot,
                            color: widget.isPickup ? Colors.green : Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _selectedAddress,
                              style: AppTextStyles.subtitle,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Confirm button
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      // Return the selected location address
                      Navigator.pop(context, _selectedAddress);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionBlue,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: !_isLoading && !_isMyLocationAvailable
          ? FloatingActionButton(
              onPressed: () {
                _getCurrentLocation();
                // Also attempt to refresh the map
                if (_mapInitialized) {
                  _refreshMap();
                }
              },
              backgroundColor: AppColors.actionBlue,
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }
}
