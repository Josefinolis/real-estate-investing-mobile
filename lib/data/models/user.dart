import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String firebaseUid;
  final String email;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firebaseUid: json['firebaseUid'] as String,
      email: json['email'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firebaseUid': firebaseUid,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, firebaseUid, email];
}
