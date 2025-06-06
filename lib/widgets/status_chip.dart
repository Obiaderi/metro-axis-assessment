import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../models/delivery.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';

class StatusChip extends StatelessWidget {
  final DeliveryStatusEnum status;
  final bool showIcon;

  const StatusChip({
    super.key,
    required this.status,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        border: Border.all(
          color: status.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              _getStatusIcon(status),
              size: 12.sp,
              color: status.color,
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(DeliveryStatusEnum status) {
    switch (status) {
      case DeliveryStatusEnum.pending:
        return IconlyLight.time_circle;
      case DeliveryStatusEnum.inTransit:
        return IconlyLight.send;
      case DeliveryStatusEnum.delivered:
        return IconlyBold.tick_square;
      case DeliveryStatusEnum.failed:
        return IconlyLight.close_square;
    }
  }
}
