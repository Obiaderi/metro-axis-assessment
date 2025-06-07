import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:iconly/iconly.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/delivery.dart';
import '../providers/delivery_provider.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../utils/mapbox_config.dart';
import '../widgets/status_chip.dart';
import 'camera_screen.dart';

class DeliveryDetailScreen extends ConsumerStatefulWidget {
  final Delivery delivery;

  const DeliveryDetailScreen({
    super.key,
    required this.delivery,
  });

  @override
  ConsumerState<DeliveryDetailScreen> createState() =>
      _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends ConsumerState<DeliveryDetailScreen> {
  bool _isUpdating = false;
  MapboxMap? _mapboxMap;
  String? _currentPhotoPath;

  @override
  void initState() {
    super.initState();
    _currentPhotoPath = widget.delivery.photoPath;
  }

  Future<void> _markAsDelivered() async {
    if (widget.delivery.status == DeliveryStatusEnum.delivered) {
      Fluttertoast.showToast(
        msg: 'This delivery is already marked as delivered',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppConstants.inTransitColor,
        textColor: Colors.white,
      );
      return;
    }

    final shouldUpdate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Delivered'),
        content: const Text(
            'Are you sure you want to mark this delivery as delivered?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (shouldUpdate != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final updateParams =
          (id: widget.delivery.id, status: DeliveryStatusEnum.delivered);
      final result =
          await ref.read(updateDeliveryStatusProvider(updateParams).future);

      if (result) {
        Fluttertoast.showToast(
          msg: 'Delivery marked as delivered successfully',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppConstants.deliveredColor,
          textColor: Colors.white,
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to update delivery status',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: AppConstants.errorColor,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred while updating delivery',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppConstants.errorColor,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _openCamera() async {
    final String? photoPath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => CameraScreen(deliveryId: widget.delivery.id),
      ),
    );

    if (photoPath != null && mounted) {
      setState(() {
        _currentPhotoPath = photoPath;
      });

      // Refresh the delivery data to include the new photo
      ref.invalidate(deliveryByIdProvider(widget.delivery.id));
    }
  }

  Future<void> _addDeliveryMarker() async {
    if (_mapboxMap == null) return;

    try {
      // Create a Point for the delivery location
      final deliveryPoint = Point(
        coordinates: Position(
          widget.delivery.longitude,
          widget.delivery.latitude,
        ),
      );

      // Set the camera to the delivery location
      await _mapboxMap!.setCamera(
        CameraOptions(
          center: deliveryPoint,
          zoom: MapboxConfig.defaultZoom,
        ),
      );

      // Try point annotation first (simpler approach)
      await _addPointAnnotation(deliveryPoint);

      // Also add circle marker as backup
      await _addCircleMarker(deliveryPoint);
    } catch (e) {
      debugPrint('Error adding marker: $e');
    }
  }

  Future<void> _addPointAnnotation(Point deliveryPoint) async {
    if (_mapboxMap == null) return;

    try {
      // Create a point annotation manager
      final pointAnnotationManager =
          await _mapboxMap!.annotations.createPointAnnotationManager();

      // Create a simple point annotation
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: deliveryPoint,
        iconSize: 2.0,
        iconColor: 0xFFFF0000, // Red color
      );

      await pointAnnotationManager.create(pointAnnotationOptions);
      debugPrint('Point annotation added successfully');
    } catch (e) {
      debugPrint('Error adding point annotation: $e');
    }
  }

  Future<void> _addCircleMarker(Point deliveryPoint) async {
    if (_mapboxMap == null) return;

    try {
      // Create a GeoJSON source for the marker
      final geoJsonData = jsonEncode({
        "type": "Feature",
        "geometry": {
          "type": "Point",
          "coordinates": [
            widget.delivery.longitude,
            widget.delivery.latitude,
          ]
        },
        "properties": {
          "delivery_id": widget.delivery.id,
          "status": widget.delivery.status.statusCode,
        }
      });

      final geoJsonSource = GeoJsonSource(
        id: 'delivery-marker-source',
        data: geoJsonData,
      );

      // Add the source to the map
      await _mapboxMap!.style.addSource(geoJsonSource);

      // Create a circle layer for the marker
      final circleLayer = CircleLayer(
        id: 'delivery-marker-layer',
        sourceId: 'delivery-marker-source',
        circleRadius: 15.0, // Larger radius for better visibility
        circleColor: 0xFFFF0000, // Red color
        circleStrokeColor: 0xFFFFFFFF, // White color
        circleStrokeWidth: 4.0, // Thicker stroke
        circleOpacity: 0.9, // Slightly transparent
      );

      // Add the layer to the map
      await _mapboxMap!.style.addLayer(circleLayer);

      // Add a symbol layer for the location icon
      final symbolLayer = SymbolLayer(
        id: 'delivery-icon-layer',
        sourceId: 'delivery-marker-source',
        textField: '📍', // Location emoji as icon
        textSize: 24.0, // Larger text size
        textColor: 0xFFFFFFFF, // White color
        textOffset: [0.0, 0.0], // Center the icon
        textOpacity: 1.0, // Fully opaque
      );

      // Add the symbol layer
      await _mapboxMap!.style.addLayer(symbolLayer);
      debugPrint('Circle marker and icon added successfully');
    } catch (e) {
      debugPrint('Error adding circle marker: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      appBar: AppBar(
        title: Text('Delivery ${widget.delivery.id}'),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.camera),
            onPressed: _openCamera,
            tooltip: 'Take Photo',
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Map
          Card(
            margin: EdgeInsets.zero,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
              ),
              clipBehavior: Clip.antiAlias,
              child: MapWidget(
                key: const ValueKey("mapWidget"),
                onMapCreated: (MapboxMap mapboxMap) {
                  _mapboxMap = mapboxMap;
                  _addDeliveryMarker();
                  setState(() {});
                },
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Status Card
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium.w),
              child: Row(
                children: [
                  Icon(
                    IconlyBold.bag,
                    size: 24.sp,
                    color: widget.delivery.status.color,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Status',
                          style: AppConstants.bodySmall.copyWith(
                            fontSize: 12.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        StatusChip(status: widget.delivery.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Customer Information
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconlyBold.profile,
                        size: 20.sp,
                        color: AppConstants.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Customer Information',
                        style: AppConstants.headingSmall.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoRow('Name', widget.delivery.customerName,
                      IconlyLight.profile),
                  if (widget.delivery.phoneNumber != null) ...[
                    SizedBox(height: 12.h),
                    _buildInfoRow('Phone', widget.delivery.phoneNumber!,
                        IconlyLight.call),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Address Information
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        IconlyBold.location,
                        size: 20.sp,
                        color: AppConstants.primaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Delivery Address',
                        style: AppConstants.headingSmall.copyWith(
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildInfoRow(
                      'Address', widget.delivery.address, IconlyLight.location),
                  SizedBox(height: 12.h),
                  _buildInfoRow(
                    'Coordinates',
                    '${widget.delivery.latitude.toStringAsFixed(6)}, ${widget.delivery.longitude.toStringAsFixed(6)}',
                    IconlyLight.discovery,
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Photo Section
          if (_currentPhotoPath != null) ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.paddingMedium.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          IconlyBold.camera,
                          size: 20.sp,
                          color: AppConstants.primaryColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Delivery Photo',
                          style: AppConstants.headingSmall.copyWith(
                            fontSize: 16.sp,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(IconlyLight.camera),
                          onPressed: _openCamera,
                          tooltip: 'Retake Photo',
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMedium),
                      child: Image.file(
                        File(_currentPhotoPath!),
                        width: double.infinity,
                        height: 200.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200.h,
                            color: Colors.grey.shade200,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  IconlyLight.danger,
                                  size: 48.sp,
                                  color: Colors.grey.shade400,
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Photo not found',
                                  style: AppConstants.bodyMedium.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // // Map
          // Card(
          //   child: Container(
          //     height: MapboxConfig.mapHeight.h,
          //     decoration: BoxDecoration(
          //       borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          //     ),
          //     clipBehavior: Clip.antiAlias,
          //     child: MapWidget(
          //       key: const ValueKey("mapWidget"),
          //       onMapCreated: (MapboxMap mapboxMap) {
          //         _mapboxMap = mapboxMap;
          //         _addDeliveryMarker();
          //       },
          //     ),
          //   ),
          // ),

          SizedBox(height: 16.h),

          // Additional Information
          if (widget.delivery.notes != null) ...[
            Card(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.paddingMedium.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          IconlyBold.document,
                          size: 20.sp,
                          color: AppConstants.primaryColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Notes',
                          style: AppConstants.headingSmall.copyWith(
                            fontSize: 16.sp,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      widget.delivery.notes!,
                      style: AppConstants.bodyMedium.copyWith(
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Timestamp
          Card(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingMedium.w),
              child: _buildInfoRow(
                'Created',
                _formatDateTime(widget.delivery.timestamp),
                IconlyLight.time_circle,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Action Button
          if (widget.delivery.status != DeliveryStatusEnum.delivered)
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppConstants.paddingMedium.w),
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : _markAsDelivered,
                icon: _isUpdating
                    ? SizedBox(
                        width: 16.w,
                        height: 16.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(IconlyBold.tick_square),
                label: Text(
                  AppStrings.markAsDeliveredButton,
                  style: TextStyle(fontSize: 16.sp),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.deliveredColor,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                ),
              ),
            ),

          SizedBox(height: 30.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: Colors.grey.shade600,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppConstants.bodySmall.copyWith(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: AppConstants.bodyMedium.copyWith(
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
