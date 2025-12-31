import 'package:equatable/equatable.dart';
import 'property.dart';

class Alert extends Equatable {
  final String? id;
  final String? name;
  final OperationType? operationType;
  final PropertyType? propertyType;
  final String? city;
  final List<String>? zones;
  final double? minPrice;
  final double? maxPrice;
  final int? minRooms;
  final int? maxRooms;
  final double? minArea;
  final double? maxArea;
  final bool isActive;
  final DateTime? createdAt;

  const Alert({
    this.id,
    this.name,
    this.operationType,
    this.propertyType,
    this.city,
    this.zones,
    this.minPrice,
    this.maxPrice,
    this.minRooms,
    this.maxRooms,
    this.minArea,
    this.maxArea,
    this.isActive = true,
    this.createdAt,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String?,
      name: json['name'] as String?,
      operationType: json['operationType'] != null
          ? OperationType.values.firstWhere(
              (e) =>
                  e.name.toUpperCase() ==
                  (json['operationType'] as String).toUpperCase(),
              orElse: () => OperationType.venta,
            )
          : null,
      propertyType: json['propertyType'] != null
          ? PropertyType.values.firstWhere(
              (e) =>
                  e.name.toUpperCase() ==
                  (json['propertyType'] as String).toUpperCase(),
              orElse: () => PropertyType.otro,
            )
          : null,
      city: json['city'] as String?,
      zones: (json['zones'] as List<dynamic>?)?.cast<String>(),
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      minRooms: json['minRooms'] as int?,
      maxRooms: json['maxRooms'] as int?,
      minArea: (json['minArea'] as num?)?.toDouble(),
      maxArea: (json['maxArea'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (operationType != null)
        'operationType': operationType!.name.toUpperCase(),
      if (propertyType != null)
        'propertyType': propertyType!.name.toUpperCase(),
      if (city != null) 'city': city,
      if (zones != null) 'zones': zones,
      if (minPrice != null) 'minPrice': minPrice,
      if (maxPrice != null) 'maxPrice': maxPrice,
      if (minRooms != null) 'minRooms': minRooms,
      if (maxRooms != null) 'maxRooms': maxRooms,
      if (minArea != null) 'minArea': minArea,
      if (maxArea != null) 'maxArea': maxArea,
      'isActive': isActive,
    };
  }

  Alert copyWith({
    String? id,
    String? name,
    OperationType? operationType,
    PropertyType? propertyType,
    String? city,
    List<String>? zones,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    int? maxRooms,
    double? minArea,
    double? maxArea,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Alert(
      id: id ?? this.id,
      name: name ?? this.name,
      operationType: operationType ?? this.operationType,
      propertyType: propertyType ?? this.propertyType,
      city: city ?? this.city,
      zones: zones ?? this.zones,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRooms: minRooms ?? this.minRooms,
      maxRooms: maxRooms ?? this.maxRooms,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get summary {
    final parts = <String>[];
    if (city != null) parts.add(city!);
    if (operationType != null) {
      parts.add(operationType == OperationType.venta ? 'Venta' : 'Alquiler');
    }
    if (minPrice != null || maxPrice != null) {
      if (minPrice != null && maxPrice != null) {
        parts.add('${minPrice!.toInt()}€ - ${maxPrice!.toInt()}€');
      } else if (minPrice != null) {
        parts.add('Desde ${minPrice!.toInt()}€');
      } else {
        parts.add('Hasta ${maxPrice!.toInt()}€');
      }
    }
    if (minRooms != null) parts.add('${minRooms}+ hab');
    return parts.isEmpty ? 'Sin filtros' : parts.join(' · ');
  }

  @override
  List<Object?> get props => [
        id,
        name,
        operationType,
        propertyType,
        city,
        zones,
        minPrice,
        maxPrice,
        minRooms,
        maxRooms,
        minArea,
        maxArea,
        isActive,
        createdAt,
      ];
}
