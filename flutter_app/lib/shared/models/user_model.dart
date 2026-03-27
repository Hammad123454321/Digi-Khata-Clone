import 'package:equatable/equatable.dart';

/// User Model
class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.phone,
    this.name,
    this.email,
  });

  final String id;
  final String phone;
  final String? name;
  final String? email;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),
      phone: json['phone'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    };
  }

  @override
  List<Object?> get props => [id, phone, name, email];
}
