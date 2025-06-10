import 'package:flutter/material.dart';

class MedicationUIConstants {
  // Colors
  static const primaryColor = Color(0xFF6200EE);
  static const secondaryColor = Color(0xFF03DAC6);
  static const gradientStart = Color(0xFFF5F5F5); // Colors.grey[50]
  static const gradientEnd = Colors.white;
  static const textPrimary = Color(0xFF212121); // black87
  static const textSecondary = Color(0xFF616161); // black54
  static const textGrey = Colors.grey;

  // Text Styles
  static const headerStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: 'Poppins',
  );
  static const titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: 'Poppins',
  );
  static const subtitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textSecondary,
    fontFamily: 'Poppins',
  );
  static const bodyStyle = TextStyle(
    fontSize: 16,
    color: textPrimary,
    fontFamily: 'Poppins',
  );
  static const buttonTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontFamily: 'Poppins',
  );

  // Paddings and Sizes
  static const sectionPadding = EdgeInsets.all(16);
  static const cardPadding = EdgeInsets.all(16);
  static const buttonPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const smallSpacing = SizedBox(height: 4);
  static const mediumSpacing = SizedBox(height: 8);
  static const largeSpacing = SizedBox(height: 16);
  static const cardRadius = BorderRadius.all(Radius.circular(16));
  static const calendarHeight = 250.0;

  // Decorations
  static const cardGradient = LinearGradient(
    colors: [gradientStart, gradientEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const cardShape = RoundedRectangleBorder(borderRadius: cardRadius);
}