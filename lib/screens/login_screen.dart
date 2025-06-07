import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'otp_verification_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }

    // Remove any non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final phoneNumber = _phoneController.text.trim();
      final success =
          await ref.read(authStateProvider.notifier).sendOtp(phoneNumber);

      if (success) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  OtpVerificationScreen(phoneNumber: phoneNumber),
            ),
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to send OTP. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppConstants.errorColor,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingLarge.w),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                SizedBox(height: 60.h),

                // Logo and Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          color: AppConstants.primaryColor,
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusXLarge),
                        ),
                        child: Icon(
                          Icons.local_shipping,
                          size: 50.sp,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        AppStrings.appName,
                        style: AppConstants.headingLarge.copyWith(
                          fontSize: 32.sp,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.welcomeMessage,
                        style: AppConstants.bodyMedium.copyWith(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 60.h),

                // Login Form
                Text(
                  AppStrings.loginTitle,
                  style: AppConstants.headingMedium.copyWith(
                    fontSize: 24.sp,
                  ),
                ),

                SizedBox(height: 24.h),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(15),
                  ],
                  decoration: InputDecoration(
                    labelText: AppStrings.phoneNumberLabel,
                    hintText: AppStrings.phoneNumberHint,
                    prefixIcon: const Icon(Icons.phone),
                  ),
                  validator: _validatePhoneNumber,
                ),

                SizedBox(height: 32.h),

                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppStrings.sendOtpButton,
                          style: TextStyle(fontSize: 16.sp),
                        ),
                ),

                // const Spacer(),
                SizedBox(height: 120.h),

                // Footer
                Center(
                  child: Text(
                    'Version ${AppConstants.appVersion}',
                    style: AppConstants.caption.copyWith(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
