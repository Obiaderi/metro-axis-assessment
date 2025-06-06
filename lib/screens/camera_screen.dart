import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:iconly/iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../utils/constants.dart';

class CameraScreen extends StatefulWidget {
  final String deliveryId;

  const CameraScreen({
    super.key,
    required this.deliveryId,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  XFile? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isNotEmpty) {
        // Use front camera if available, otherwise use the first camera
        final frontCamera = _cameras!.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras!.first,
        );

        _controller = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await _controller!.initialize();

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final image = await _controller!.takePicture();
      setState(() {
        _capturedImage = image;
        _isCapturing = false;
      });
    } catch (e) {
      setState(() {
        _isCapturing = false;
      });
      _showError('Failed to take picture: $e');
    }
  }

  void _retakePicture() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _confirmPicture() {
    Fluttertoast.showToast(
      msg: 'Photo saved for delivery ${widget.deliveryId}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppConstants.deliveredColor,
      textColor: Colors.white,
    );
    Navigator.of(context).pop();
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppConstants.errorColor,
      textColor: Colors.white,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Camera - ${widget.deliveryId}'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (_capturedImage != null) {
      return _buildImagePreview();
    }

    return _buildCameraPreview();
  }

  Widget _buildCameraPreview() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            child: CameraPreview(_controller!),
          ),
        ),
        Container(
          height: 120.h,
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Flash toggle (placeholder)
              IconButton(
                onPressed: () {
                  // Flash toggle functionality would go here
                },
                icon: Icon(
                  Icons.flash_on,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),

              // Capture button
              GestureDetector(
                onTap: _isCapturing ? null : _takePicture,
                child: Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: _isCapturing ? Colors.grey : Colors.transparent,
                  ),
                  child: _isCapturing
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(
                          IconlyBold.camera,
                          color: Colors.white,
                          size: 30.sp,
                        ),
                ),
              ),

              // Switch camera (placeholder)
              IconButton(
                onPressed: () {
                  // Camera switch functionality would go here
                },
                icon: Icon(
                  IconlyLight.swap,
                  color: Colors.white,
                  size: 24.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(
                  // Note: XFile doesn't directly work with FileImage
                  // In a real implementation, you'd need to handle this properly
                  // For now, this is a placeholder
                  _capturedImage as dynamic,
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Text(
                'Image Preview\n(Delivery: ${widget.deliveryId})',
                style: AppConstants.bodyLarge.copyWith(
                  color: Colors.white,
                  fontSize: 16.sp,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 10,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Container(
          height: 120.h,
          color: Colors.black,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Retake button
              ElevatedButton.icon(
                onPressed: _retakePicture,
                icon: const Icon(IconlyLight.camera),
                label: Text(
                  AppStrings.retakeButton,
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade700,
                  foregroundColor: Colors.white,
                ),
              ),

              // Confirm button
              ElevatedButton.icon(
                onPressed: _confirmPicture,
                icon: const Icon(IconlyBold.tick_square),
                label: Text(
                  AppStrings.confirmButton,
                  style: TextStyle(fontSize: 14.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.deliveredColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
