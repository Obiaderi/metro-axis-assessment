import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/delivery.dart';

class DeliveryService {
  static const String _mockDataPath = 'assets/data/mock_deliveries.json';
  
  Future<List<Delivery>> loadDeliveries() async {
    try {
      final String jsonString = await rootBundle.loadString(_mockDataPath);
      final List<dynamic> jsonList = json.decode(jsonString);
      
      return jsonList.map((json) {
        // Convert status string to enum
        final statusString = json['status'] as String;
        final status = DeliveryStatusEnumExtension.fromString(statusString);
        
        return Delivery(
          id: json['id'] as String,
          customerName: json['customerName'] as String,
          address: json['address'] as String,
          latitude: (json['latitude'] as num).toDouble(),
          longitude: (json['longitude'] as num).toDouble(),
          status: status,
          timestamp: DateTime.parse(json['timestamp'] as String),
          phoneNumber: json['phoneNumber'] as String?,
          notes: json['notes'] as String?,
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
  
  Future<List<Delivery>> getDeliveriesByStatus(DeliveryStatusEnum status) async {
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
  Future<bool> updateDeliveryStatus(String deliveryId, DeliveryStatusEnum newStatus) async {
    // In a real app, this would make an API call
    // For now, we'll just simulate a successful update
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
