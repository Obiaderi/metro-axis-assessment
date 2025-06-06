import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconly/iconly.dart';
import '../models/delivery.dart';
import '../providers/delivery_provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

import '../widgets/delivery_card.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/filter_chips.dart';
import 'delivery_detail_screen.dart';
import 'login_screen.dart';

class DeliveriesListScreen extends ConsumerStatefulWidget {
  const DeliveriesListScreen({super.key});

  @override
  ConsumerState<DeliveriesListScreen> createState() =>
      _DeliveriesListScreenState();
}

class _DeliveriesListScreenState extends ConsumerState<DeliveriesListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _refreshDeliveries() async {
    ref.invalidate(deliveriesProvider);
    ref.invalidate(filteredDeliveriesProvider);
  }

  void _onDeliveryTap(Delivery delivery) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DeliveryDetailScreen(delivery: delivery),
      ),
    );
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await ref.read(authStateProvider.notifier).logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredDeliveries = ref.watch(filteredDeliveriesProvider);
    final searchQuery = ref.watch(searchQueryProvider);
    final selectedFilter = ref.watch(deliveryFilterProvider);

    return Scaffold(
      backgroundColor: AppConstants.surfaceColor,
      appBar: AppBar(
        title: Text(AppStrings.deliveriesTitle),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.logout),
            onPressed: _logout,
            tooltip: AppStrings.logoutButton,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(AppConstants.paddingMedium.w),
            child: Column(
              children: [
                SearchBarWidget(
                  hintText: AppStrings.searchHint,
                  onChanged: (query) {
                    ref.read(searchQueryProvider.notifier).state = query;
                  },
                ),
                SizedBox(height: 12.h),
                FilterChips(
                  selectedFilter: selectedFilter,
                  onFilterChanged: (filter) {
                    ref.read(deliveryFilterProvider.notifier).state = filter;
                  },
                ),
              ],
            ),
          ),

          // Deliveries List
          Expanded(
            child: filteredDeliveries.when(
              data: (deliveries) {
                if (deliveries.isEmpty) {
                  return _buildEmptyState(searchQuery, selectedFilter);
                }

                return RefreshIndicator(
                  onRefresh: _refreshDeliveries,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(
                        vertical: AppConstants.paddingSmall.h),
                    itemCount: deliveries.length,
                    itemBuilder: (context, index) {
                      final delivery = deliveries[index];
                      return DeliveryCard(
                        delivery: delivery,
                        onTap: () => _onDeliveryTap(delivery),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stackTrace) => _buildErrorState(error),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshDeliveries,
        tooltip: AppStrings.refreshButton,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildEmptyState(
      String searchQuery, DeliveryStatusEnum? selectedFilter) {
    String message;
    IconData icon;

    if (searchQuery.isNotEmpty) {
      message = 'No deliveries found for "$searchQuery"';
      icon = IconlyLight.search;
    } else if (selectedFilter != null) {
      message =
          'No ${selectedFilter.displayName.toLowerCase()} deliveries found';
      icon = IconlyLight.filter;
    } else {
      message = AppStrings.noDeliveriesFound;
      icon = IconlyLight.bag;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: AppConstants.bodyLarge.copyWith(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _refreshDeliveries,
            icon: const Icon(Icons.refresh),
            label: Text(AppStrings.refreshButton),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            IconlyLight.danger,
            size: 64.sp,
            color: AppConstants.errorColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load deliveries',
            style: AppConstants.bodyLarge.copyWith(
              fontSize: 16.sp,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            error.toString(),
            style: AppConstants.bodySmall.copyWith(
              fontSize: 12.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _refreshDeliveries,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
