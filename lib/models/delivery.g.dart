// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeliveryImpl _$$DeliveryImplFromJson(Map<String, dynamic> json) =>
    _$DeliveryImpl(
      id: json['id'] as String,
      customerName: json['customerName'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: $enumDecode(_$DeliveryStatusEnumEnumMap, json['status']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      phoneNumber: json['phoneNumber'] as String?,
      notes: json['notes'] as String?,
      photoPath: json['photoPath'] as String?,
    );

Map<String, dynamic> _$$DeliveryImplToJson(_$DeliveryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customerName': instance.customerName,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'status': _$DeliveryStatusEnumEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'phoneNumber': instance.phoneNumber,
      'notes': instance.notes,
      'photoPath': instance.photoPath,
    };

const _$DeliveryStatusEnumEnumMap = {
  DeliveryStatusEnum.pending: 'pending',
  DeliveryStatusEnum.inTransit: 'inTransit',
  DeliveryStatusEnum.delivered: 'delivered',
  DeliveryStatusEnum.failed: 'failed',
};
