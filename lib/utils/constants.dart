import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'Metro Axis';
  static const String appVersion = '1.0.0';
  
  // Colors
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03DAC6);
  static const Color errorColor = Color(0xFFB00020);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color pendingColor = Color(0xFFFF9800);
  static const Color inTransitColor = Color(0xFF2196F3);
  static const Color deliveredColor = Color(0xFF4CAF50);
  static const Color failedColor = Color(0xFFF44336);
  
  // Spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border Radius
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Text Styles
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
  );
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String otpVerification = '/otp-verification';
  static const String deliveriesList = '/deliveries';
  static const String deliveryDetail = '/delivery-detail';
  static const String camera = '/camera';
}

class AppImages {
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderPath = 'assets/images/placeholder.png';
}

class AppStrings {
  static const String appName = 'Metro Axis';
  static const String welcomeMessage = 'Welcome to Metro Axis Delivery';
  static const String loginTitle = 'Login';
  static const String phoneNumberLabel = 'Phone Number';
  static const String phoneNumberHint = 'Enter your phone number';
  static const String sendOtpButton = 'Send OTP';
  static const String otpVerificationTitle = 'OTP Verification';
  static const String otpLabel = 'Enter OTP';
  static const String otpHint = 'Enter 6-digit OTP';
  static const String verifyOtpButton = 'Verify OTP';
  static const String deliveriesTitle = 'Deliveries';
  static const String searchHint = 'Search deliveries...';
  static const String noDeliveriesFound = 'No deliveries found';
  static const String deliveryDetailTitle = 'Delivery Details';
  static const String markAsDeliveredButton = 'Mark as Delivered';
  static const String cameraTitle = 'Camera';
  static const String takePictureButton = 'Take Picture';
  static const String retakeButton = 'Retake';
  static const String confirmButton = 'Confirm';
  static const String logoutButton = 'Logout';
  static const String refreshButton = 'Refresh';
  static const String filterButton = 'Filter';
  static const String allStatus = 'All';
  static const String pendingStatus = 'Pending';
  static const String inTransitStatus = 'In Transit';
  static const String deliveredStatus = 'Delivered';
  static const String failedStatus = 'Failed';
}
