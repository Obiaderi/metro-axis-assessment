import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:metro_axis/main.dart';
import 'package:metro_axis/screens/splash_screen.dart';

void main() {
  group('Metro Axis App Tests', () {
    testWidgets('App should start with splash screen', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const ProviderScope(
          child: MyApp(),
        ),
      );

      // Verify that splash screen is displayed
      expect(find.text('Metro Axis'), findsOneWidget);
      expect(find.text('Delivery Management System'), findsOneWidget);
    });

    testWidgets('Splash screen should show loading indicator', (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ScreenUtilInit(
              designSize: const Size(375, 812),
              builder: (context, child) => const SplashScreen(),
            ),
          ),
        ),
      );

      // Verify loading indicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Metro Axis'), findsOneWidget);
    });
  });
}
