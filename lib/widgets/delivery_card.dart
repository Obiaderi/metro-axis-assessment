import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../models/delivery.dart';
import '../utils/constants.dart';

import 'status_chip.dart';

class DeliveryCard extends StatelessWidget {
  final Delivery delivery;
  final VoidCallback onTap;

  const DeliveryCard({
    super.key,
    required this.delivery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium.w,
        vertical: AppConstants.paddingSmall.h,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Padding(
          padding: EdgeInsets.all(AppConstants.paddingMedium.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSmall),
                    ),
                    child: Text(
                      delivery.id,
                      style: AppConstants.bodySmall.copyWith(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  StatusChip(status: delivery.status),
                ],
              ),

              SizedBox(height: 12.h),

              // Customer Name
              Row(
                children: [
                  Icon(
                    IconlyLight.profile,
                    size: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      delivery.customerName,
                      style: AppConstants.headingSmall.copyWith(
                        fontSize: 16.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Address
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    IconlyLight.location,
                    size: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      delivery.address,
                      style: AppConstants.bodyMedium.copyWith(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 8.h),

              // Phone Number (if available)
              if (delivery.phoneNumber != null) ...[
                Row(
                  children: [
                    Icon(
                      IconlyLight.call,
                      size: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      delivery.phoneNumber!,
                      style: AppConstants.bodyMedium.copyWith(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
              ],

              // Timestamp and Notes
              Row(
                children: [
                  Icon(
                    IconlyLight.time_circle,
                    size: 14.sp,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    _formatDateTime(delivery.timestamp),
                    style: AppConstants.bodySmall.copyWith(
                      fontSize: 12.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  if (delivery.notes != null) ...[
                    SizedBox(width: 12.w),
                    Icon(
                      IconlyLight.document,
                      size: 14.sp,
                      color: Colors.grey.shade500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Notes',
                      style: AppConstants.bodySmall.copyWith(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    IconlyLight.arrow_right_2,
                    size: 16.sp,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
