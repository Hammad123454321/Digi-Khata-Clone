import 'package:equatable/equatable.dart';

/// Device Model
class DeviceModel extends Equatable {
  const DeviceModel({
    this.id,
    required this.deviceId,
    this.deviceName,
    this.deviceType,
    this.isActive,
    this.lastSyncAt,
    this.createdAt,
  });

  final String? id;
  final String deviceId;
  final String? deviceName;
  final String? deviceType;
  final bool? isActive;
  final DateTime? lastSyncAt;
  final DateTime? createdAt;

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id']?.toString(),
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String? ?? 'Unknown Device',
      deviceType: json['device_type'] as String?,
      isActive: json['is_active'] as bool?,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'device_name': deviceName,
      if (deviceType != null) 'device_type': deviceType,
      if (isActive != null) 'is_active': isActive,
      if (lastSyncAt != null) 'last_sync_at': lastSyncAt!.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        deviceId,
        deviceName,
        deviceType,
        isActive,
        lastSyncAt,
        createdAt,
      ];
}
