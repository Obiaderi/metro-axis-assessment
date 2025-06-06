import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/delivery.dart';
import '../services/delivery_service.dart';

final deliveryServiceProvider = Provider<DeliveryService>((ref) => DeliveryService());

final deliveriesProvider = FutureProvider<List<Delivery>>((ref) async {
  final deliveryService = ref.read(deliveryServiceProvider);
  return await deliveryService.loadDeliveries();
});

final deliveryByIdProvider = FutureProvider.family<Delivery?, String>((ref, id) async {
  final deliveryService = ref.read(deliveryServiceProvider);
  return await deliveryService.getDeliveryById(id);
});

final deliveriesByStatusProvider = FutureProvider.family<List<Delivery>, DeliveryStatusEnum>((ref, status) async {
  final deliveryService = ref.read(deliveryServiceProvider);
  return await deliveryService.getDeliveriesByStatus(status);
});

final searchDeliveriesProvider = FutureProvider.family<List<Delivery>, String>((ref, query) async {
  final deliveryService = ref.read(deliveryServiceProvider);
  if (query.isEmpty) {
    return await deliveryService.loadDeliveries();
  }
  return await deliveryService.searchDeliveries(query);
});

final deliveryFilterProvider = StateProvider<DeliveryStatusEnum?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredDeliveriesProvider = FutureProvider<List<Delivery>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider);
  final filter = ref.watch(deliveryFilterProvider);
  final deliveryService = ref.read(deliveryServiceProvider);
  
  List<Delivery> deliveries;
  
  if (searchQuery.isNotEmpty) {
    deliveries = await deliveryService.searchDeliveries(searchQuery);
  } else {
    deliveries = await deliveryService.loadDeliveries();
  }
  
  if (filter != null) {
    deliveries = deliveries.where((delivery) => delivery.status == filter).toList();
  }
  
  return deliveries;
});

final updateDeliveryStatusProvider = FutureProvider.family<bool, ({String id, DeliveryStatusEnum status})>((ref, params) async {
  final deliveryService = ref.read(deliveryServiceProvider);
  final result = await deliveryService.updateDeliveryStatus(params.id, params.status);
  
  if (result) {
    // Refresh the deliveries list after successful update
    ref.invalidate(deliveriesProvider);
    ref.invalidate(filteredDeliveriesProvider);
  }
  
  return result;
});
