import 'package:equatable/equatable.dart';
import 'property.dart';

class Favorite extends Equatable {
  final String id;
  final String propertyId;
  final Property? property;
  final String? notes;
  final DateTime createdAt;

  const Favorite({
    required this.id,
    required this.propertyId,
    this.property,
    this.notes,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      property: json['property'] != null
          ? Property.fromJson(json['property'] as Map<String, dynamic>)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Favorite copyWith({
    String? id,
    String? propertyId,
    Property? property,
    String? notes,
    DateTime? createdAt,
  }) {
    return Favorite(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      property: property ?? this.property,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, propertyId, notes, createdAt];
}
