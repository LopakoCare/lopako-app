import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      canvasColor: AppColors.white,
      primarySwatch: AppColors.primary,
      scaffoldBackgroundColor: AppColors.white,
      fontFamily: GoogleFonts.asap().fontFamily,
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: AppColors.black,
        ),
        titleMedium: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary[900],
        ),
        bodyLarge: TextStyle(
          fontSize: 18.0,
          color: AppColors.black,
        ),
        bodySmall: TextStyle(
          fontSize: 14.0,
          color: AppColors.neutral[600],
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          minimumSize: Size(double.infinity, 48),
          textStyle: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          shadowColor: AppColors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.neutral[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          minimumSize: Size(double.infinity, 48),
          textStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
          side: BorderSide(color: AppColors.neutral[300]!, width: 2.0),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neutral[700],
          textStyle: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w500,
          ),
        )
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.neutral[300]!, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.neutral[300]!, width: 2.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.danger, width: 2.0),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: AppColors.neutral[100]!, width: 2.0),
        ),
        labelStyle: TextStyle(
          color: AppColors.neutral,
          fontSize: 18.0,
        ),
        errorStyle: TextStyle(
          color: AppColors.danger,
          fontSize: 12.0,
        ),
        suffixIconColor: AppColors.neutral[500],
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: AppColors.white,
        headerBackgroundColor: AppColors.primary,
        headerForegroundColor: AppColors.white,
        todayBackgroundColor: MaterialStateProperty.all(AppColors.primary[100]),
        todayForegroundColor: MaterialStateProperty.all(AppColors.primary),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.neutral[400],
        selectedLabelStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12.0,
          fontWeight: FontWeight.w400,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),
        iconTheme: IconThemeData(
          color: AppColors.black,
        ),
        shape: Border(
          bottom: BorderSide(
            color: AppColors.neutral[200]!,
            width: 2.0,
          ),
        )
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.red[700],
        contentTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 0,
        hoverElevation: 0,
        focusElevation: 0,
        highlightElevation: 0,
      ),
      cardTheme: CardTheme(
        color: AppColors.neutral[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        elevation: 0,
        shadowColor: AppColors.transparent,
        margin: EdgeInsets.zero,
      ),
    );
  }
}
