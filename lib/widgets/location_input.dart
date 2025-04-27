import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class LocationInput extends StatelessWidget {
  final String hintText;
  final Color iconBackgroundColor;
  final IconData icon;
  final VoidCallback? onMapTap;
  final TextEditingController? controller;
  final bool readOnly;

  const LocationInput({
    Key? key,
    required this.hintText,
    required this.iconBackgroundColor,
    required this.icon,
    this.onMapTap,
    this.controller,
    this.readOnly = false,
  }) : super(key: key);

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
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.hintText,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: AppTextStyles.inputText,
            ),
          ),
          if (onMapTap != null)
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
