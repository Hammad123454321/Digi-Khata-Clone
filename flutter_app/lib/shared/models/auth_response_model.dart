import 'package:equatable/equatable.dart';
import 'business_model.dart';
import 'device_model.dart';
import 'user_model.dart';

/// Authentication Response Model
class AuthResponseModel extends Equatable {
  const AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.user,
    this.businesses,
    this.defaultBusinessId,
    this.device,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final UserModel user;
  final List<BusinessModel>? businesses;
  final String? defaultBusinessId;
  final DeviceModel? device;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String? ?? '',
      tokenType: json['token_type'] as String? ?? 'bearer',
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      businesses: json['businesses'] != null
          ? (json['businesses'] as List<dynamic>)
              .map((e) => BusinessModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      defaultBusinessId: json['default_business_id'] as String?,
      device: json['device'] != null
          ? DeviceModel.fromJson(json['device'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'user': user.toJson(),
      if (businesses != null)
        'businesses': businesses!.map((e) => e.toJson()).toList(),
      if (device != null) 'device': device!.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        accessToken,
        refreshToken,
        tokenType,
        user,
        businesses,
        defaultBusinessId,
        device,
      ];
}
