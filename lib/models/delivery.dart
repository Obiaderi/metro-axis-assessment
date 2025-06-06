import 'package:freezed_annotation/freezed_annotation.dart';

part 'delivery.freezed.dart';
part 'delivery.g.dart';

@freezed
class Delivery with _$Delivery {
  const factory Delivery({
    required String id,
    required String customerName,
    required String address,
    required double latitude,
    required double longitude,
    required DeliveryStatusEnum status,
    required DateTime timestamp,
    String? phoneNumber,
    String? notes,
  }) = _Delivery;

  factory Delivery.fromJson(Map<String, dynamic> json) =>
      _$DeliveryFromJson(json);
}

enum DeliveryStatusEnum {
  pending,
  inTransit,
  delivered,
  failed,
}

extension DeliveryStatusEnumExtension on DeliveryStatusEnum {
  String get displayName {
    switch (this) {
      case DeliveryStatusEnum.pending:
        return 'Pending';
      case DeliveryStatusEnum.inTransit:
        return 'In Transit';
      case DeliveryStatusEnum.delivered:
        return 'Delivered';
      case DeliveryStatusEnum.failed:
        return 'Failed';
    }
  }

  String get statusCode {
    switch (this) {
      case DeliveryStatusEnum.pending:
        return 'pending';
      case DeliveryStatusEnum.inTransit:
        return 'in_transit';
      case DeliveryStatusEnum.delivered:
        return 'delivered';
      case DeliveryStatusEnum.failed:
        return 'failed';
    }
  }

  static DeliveryStatusEnum fromString(String status) {
    switch (status) {
      case 'pending':
        return DeliveryStatusEnum.pending;
      case 'in_transit':
        return DeliveryStatusEnum.inTransit;
      case 'delivered':
        return DeliveryStatusEnum.delivered;
      case 'failed':
        return DeliveryStatusEnum.failed;
      default:
        return DeliveryStatusEnum.pending;
    }
  }
}
