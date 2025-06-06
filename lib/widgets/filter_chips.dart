import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/delivery.dart';
import '../utils/constants.dart';

class FilterChips extends StatelessWidget {
  final DeliveryStatusEnum? selectedFilter;
  final ValueChanged<DeliveryStatusEnum?> onFilterChanged;

  const FilterChips({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip(
            label: AppStrings.allStatus,
            isSelected: selectedFilter == null,
            onTap: () => onFilterChanged(null),
            color: AppConstants.primaryColor,
          ),
          SizedBox(width: 8.w),
          _buildFilterChip(
            label: AppStrings.pendingStatus,
            isSelected: selectedFilter == DeliveryStatusEnum.pending,
            onTap: () => onFilterChanged(DeliveryStatusEnum.pending),
            color: AppConstants.pendingColor,
          ),
          SizedBox(width: 8.w),
          _buildFilterChip(
            label: AppStrings.inTransitStatus,
            isSelected: selectedFilter == DeliveryStatusEnum.inTransit,
            onTap: () => onFilterChanged(DeliveryStatusEnum.inTransit),
            color: AppConstants.inTransitColor,
          ),
          SizedBox(width: 8.w),
          _buildFilterChip(
            label: AppStrings.deliveredStatus,
            isSelected: selectedFilter == DeliveryStatusEnum.delivered,
            onTap: () => onFilterChanged(DeliveryStatusEnum.delivered),
            color: AppConstants.deliveredColor,
          ),
          SizedBox(width: 8.w),
          _buildFilterChip(
            label: AppStrings.failedStatus,
            isSelected: selectedFilter == DeliveryStatusEnum.failed,
            onTap: () => onFilterChanged(DeliveryStatusEnum.failed),
            color: AppConstants.failedColor,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.animationFast,
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
          border: Border.all(
            color: color,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : color,
          ),
        ),
      ),
    );
  }
}
