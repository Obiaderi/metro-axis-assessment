import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/delivery.dart';
import 'photo_service.dart';

class DeliveryService {
  static const String _mockDataPath = 'assets/data/mock_deliveries.json';
  final PhotoService _photoService = PhotoService();

  Future<List<Delivery>> loadDeliveries() async {
    try {
      final String jsonString = await rootBundle.loadString(_mockDataPath);
      final List<dynamic> jsonList = json.decode(jsonString);

      // Get all delivery photos
      final Map<String, String> deliveryPhotos =
          await _photoService.getAllDeliveryPhotos();

      return jsonList.map((json) {
        // Convert status string to enum
        final statusString = json['status'] as String;
        final status = DeliveryStatusEnumExtension.fromString(statusString);
        final deliveryId = json['id'] as String;

        return Delivery(
          id: deliveryId,
          customerName: json['customerName'] as String,
          address: json['address'] as String,
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
          status: status,
          timestamp: DateTime.parse(json['timestamp'] as String),
          phoneNumber: json['phoneNumber'] as String?,
          notes: json['notes'] as String?,
          photoPath: deliveryPhotos[deliveryId],
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to load deliveries: $e');
    }
  }

  Future<Delivery?> getDeliveryById(String id) async {
    final deliveries = await loadDeliveries();
    try {
      return deliveries.firstWhere((delivery) => delivery.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Delivery>> getDeliveriesByStatus(
      DeliveryStatusEnum status) async {
    final deliveries = await loadDeliveries();
    return deliveries.where((delivery) => delivery.status == status).toList();
  }

  Future<List<Delivery>> searchDeliveries(String query) async {
    final deliveries = await loadDeliveries();
    final lowerQuery = query.toLowerCase();

    return deliveries.where((delivery) {
      return delivery.id.toLowerCase().contains(lowerQuery) ||
          delivery.customerName.toLowerCase().contains(lowerQuery) ||
          delivery.address.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Mock method to update delivery status
  Future<bool> updateDeliveryStatus(
      String deliveryId, DeliveryStatusEnum newStatus) async {
    // In a real app, this would make an API call
    // For now, we'll just simulate a successful update
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  // Method to save a photo for a delivery
  Future<String?> saveDeliveryPhoto(String deliveryId, dynamic photo) async {
    return await _photoService.saveDeliveryPhoto(deliveryId, photo);
  }

  // Method to get photo path for a delivery
  Future<String?> getDeliveryPhotoPath(String deliveryId) async {
    return await _photoService.getDeliveryPhotoPath(deliveryId);
  }
}
