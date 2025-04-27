import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle heading = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  static TextStyle title = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static TextStyle subtitle = GoogleFonts.roboto(
    fontSize: 16,
    color: AppColors.lightText,
  );

  static TextStyle buttonText = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.white,
  );

  static TextStyle inputText = GoogleFonts.roboto(
    fontSize: 16,
    color: AppColors.darkText,
  );

  static TextStyle hintText = GoogleFonts.roboto(
    fontSize: 16,
    color: AppColors.lightText,
  );

  static TextStyle appBarTitle = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static TextStyle appBarSubtitle = GoogleFonts.roboto(
    fontSize: 14,
    color: AppColors.white,
    fontWeight: FontWeight.w300,
  );
}
