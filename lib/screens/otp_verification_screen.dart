import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'deliveries_list_screen.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-verify when all digits are entered
    if (_otpCode.length == 6) {
      _verifyOtp();
    }
  }

  // Handle backspace key press
  void _onKeyEvent(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_otpControllers[index].text.isEmpty && index > 0) {
        // If current field is empty and backspace is pressed, move to previous field and clear it
        _focusNodes[index - 1].requestFocus();
        _otpControllers[index - 1].clear();
      } else if (_otpControllers[index].text.isNotEmpty) {
        // If current field has content, clear it
        _otpControllers[index].clear();
      }
    }
  }

  // Clear all OTP fields
  void _clearAllFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _verifyOtp() async {
    if (_otpCode.length != 6) {
      Fluttertoast.showToast(
        msg: 'Please enter complete OTP',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ref.read(authStateProvider.notifier).verifyOtp(
            widget.phoneNumber,
            _otpCode,
          );

      if (success) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (context) => const DeliveriesListScreen()),
            (route) => false,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Invalid OTP. Please try again.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppConstants.errorColor,
          textColor: Colors.white,
        );

        // Clear OTP fields
        _clearAllFields();
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

  Future<void> _resendOtp() async {
    try {
      final success = await ref
          .read(authStateProvider.notifier)
          .sendOtp(widget.phoneNumber);

      if (success) {
        Fluttertoast.showToast(
          msg: 'OTP sent successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppConstants.deliveredColor,
          textColor: Colors.white,
        );

        // Clear existing OTP when resending
        _clearAllFields();
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to resend OTP',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppConstants.errorColor,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(AppStrings.otpVerificationTitle),
        backgroundColor: Colors.transparent,
        foregroundColor: AppConstants.primaryColor,
        elevation: 0,
        actions: [
          // Clear all button
          IconButton(
            onPressed: _clearAllFields,
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppConstants.paddingLarge.w),
          children: [
            SizedBox(height: 32.h),

            // Instructions
            Text(
              'Enter the 6-digit code sent to',
              style: AppConstants.bodyLarge.copyWith(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              widget.phoneNumber,
              style: AppConstants.headingSmall.copyWith(
                fontSize: 18.sp,
                color: AppConstants.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 48.h),

            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45.w,
                  height: 55.h,
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) => _onKeyEvent(event, index),
                    child: TextFormField(
                      controller: _otpControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMedium),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMedium),
                          borderSide: const BorderSide(
                            color: AppConstants.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      style:
                          AppConstants.headingSmall.copyWith(fontSize: 20.sp),
                      onChanged: (value) => _onOtpChanged(value, index),
                    ),
                  ),
                );
              }),
            ),

            SizedBox(height: 16.h),

            // Clear button
            Center(
              child: TextButton.icon(
                onPressed: _clearAllFields,
                icon: const Icon(Icons.backspace_outlined, size: 18),
                label: Text(
                  'Clear All',
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade600,
                ),
              ),
            ),

            SizedBox(height: 32.h),

            // Verify Button
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyOtp,
              child: _isLoading
                  ? SizedBox(
                      height: 20.h,
                      width: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      AppStrings.verifyOtpButton,
                      style: TextStyle(fontSize: 16.sp),
                    ),
            ),

            SizedBox(height: 24.h),

            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Didn't receive the code? ",
                  style: AppConstants.bodyMedium.copyWith(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                TextButton(
                  onPressed: _resendOtp,
                  child: Text(
                    'Resend',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            // const Spacer(),
            SizedBox(height: 120.h),

            // Help Text
            Container(
              padding: EdgeInsets.all(AppConstants.paddingMedium.w),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Text(
                'For testing purposes, use OTP: 123456',
                style: AppConstants.bodySmall.copyWith(
                  fontSize: 12.sp,
                  color: AppConstants.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
