import 'package:flutter/material.dart';

class AppColors {

  // Purple
  static const MaterialColor purple = MaterialColor(
    0xFF7733EE,
    <int, Color>{
      50: Color(0xFFF2ECFD),
      100: Color(0xFFE3D5FB),
      200: Color(0xFFCAAFF8),
      300: Color(0xFFAE85F5),
      400: Color(0xFF925AF1),
      500: Color(0xFF7733EE),
      600: Color(0xFF5912D4),
      700: Color(0xFF430DA0),
      800: Color(0xFF2D096C),
      900: Color(0xFF160434),
      950: Color(0xFF0C021C),
    },
  );

  // Blue
  static const MaterialColor blue = MaterialColor(
    0xFF008EE7,
    <int, Color>{
      50: Color(0xFFE5F5FF),
      100: Color(0xFFC7E9FF),
      200: Color(0xFF8FD4FF),
      300: Color(0xFF57BEFF),
      400: Color(0xFF1FA9FF),
      500: Color(0xFF008EE7),
      600: Color(0xFF0071B8),
      700: Color(0xFF00558A),
      800: Color(0xFF00395C),
      900: Color(0xFF001C2E),
      950: Color(0xFF001019),
    },
  );

  // Green
  static const MaterialColor green = MaterialColor(
    0xFF88CC22,
    <int, Color>{
      50: Color(0xFFF4FBE9),
      100: Color(0xFFE7F7CF),  // Placeholder
      200: Color(0xFFD1F0A3),  // Placeholder
      300: Color(0xFFB9E873),  // Placeholder
      400: Color(0xFFA1E043),  // Placeholder
      500: Color(0xFF88CC22),  // Color base
      600: Color(0xFF6CA21B),  // Placeholder
      700: Color(0xFF527A14),  // Placeholder
      800: Color(0xFF37530E),  // Placeholder
      900: Color(0xFF1A2707),  // Placeholder
      950: Color(0xFF0F1604),  // Placeholder
    },
  );

  // Yellow
  static const MaterialColor yellow = MaterialColor(
    0xFFFFBB00,
    <int, Color>{
      50: Color(0xFFFFF8E5),
      100: Color(0xFFFFF1CC),
      200: Color(0xFFFFE499),
      300: Color(0xFFFFD666),
      400: Color(0xFFFFC933),
      500: Color(0xFFFFBB00),
      600: Color(0xFFCC9600),
      700: Color(0xFF997000),
      800: Color(0xFF664B00),
      900: Color(0xFF332500),
      950: Color(0xFF191300),
    },
  );

  // Red
  static const MaterialColor red = MaterialColor(
    0xFFFF4433,
    <int, Color>{
      50: Color(0xFFFFECEB),
      100: Color(0xFFFFDAD6),
      200: Color(0xFFFFB4AD),
      300: Color(0xFFFF8F85),
      400: Color(0xFFFF695C),
      500: Color(0xFFFF4433),
      600: Color(0xFFF51400),
      700: Color(0xFFB80F00),
      800: Color(0xFF7A0A00),
      900: Color(0xFF3D0500),
      950: Color(0xFF1F0300),
    },
  );

  // Pink
  static const MaterialColor pink = MaterialColor(
    0xFFFF11FF,
    <int, Color>{
      50: Color(0xFFFFE5FF),
      100: Color(0xFFFFD1FF),
      200: Color(0xFFFF9EFF),
      300: Color(0xFFFF70FF),
      400: Color(0xFFFF42FF),
      500: Color(0xFFFF11FF),
      600: Color(0xFFDB00DB),
      700: Color(0xFFA300A3),
      800: Color(0xFF6B006B),
      900: Color(0xFF380038),
      950: Color(0xFF190019),
    },
  );

  // Teal
  static const MaterialColor teal = MaterialColor(
    0xFF00CCCC,
    <int, Color>{
      50: Color(0xFFE0FFFF),
      100: Color(0xFFC2FFFF),
      200: Color(0xFF85FFFF),
      300: Color(0xFF47FFFF),
      400: Color(0xFF0AFFFF),
      500: Color(0xFF00CCCC),
      600: Color(0xFF00A3A3),
      700: Color(0xFF007A7A),
      800: Color(0xFF005252),
      900: Color(0xFF002929),
      950: Color(0xFF001414),
    },
  );

  // Neutral
  static const MaterialColor neutral = MaterialColor(
    0xFF808080,
    <int, Color>{
      50: Color(0xFFF4F4F4),
      100: Color(0xFFE5E5E5),
      200: Color(0xFFCCCCCC),
      300: Color(0xFFB2B2B2),
      400: Color(0xFF999999),
      500: Color(0xFF808080),
      600: Color(0xFF666666),
      700: Color(0xFF4D4D4D),
      800: Color(0xFF333333),
      900: Color(0xFF1A1A1A),
      950: Color(0xFF0D0D0D),
    },
  );

  // Primary
  static const MaterialColor primary = purple;

  // Secondary
  static const MaterialColor secondary = blue;

  // Success
  static const MaterialColor success = green;

  // Danger
  static const MaterialColor danger = red;

  // Colores adicionales
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
}
