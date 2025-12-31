import 'package:equatable/equatable.dart';

enum PropertySource { idealista, fotocasa, pisoscom }

enum PropertyType {
  apartamento,
  piso,
  casa,
  chalet,
  duplex,
  atico,
  estudio,
  loft,
  otro
}

enum OperationType { venta, alquiler }

class Property extends Equatable {
  final String id;
  final String externalId;
  final PropertySource source;
  final String? title;
  final String? description;
  final double? price;
  final double? pricePerM2;
  final PropertyType? propertyType;
  final OperationType? operationType;
  final int? rooms;
  final int? bathrooms;
  final double? areaM2;
  final String? address;
  final String? city;
  final String? zone;
  final double? latitude;
  final double? longitude;
  final List<String>? imageUrls;
  final String? url;
  final bool isActive;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;

  const Property({
    required this.id,
    required this.externalId,
    required this.source,
    this.title,
    this.description,
    this.price,
    this.pricePerM2,
    this.propertyType,
    this.operationType,
    this.rooms,
    this.bathrooms,
    this.areaM2,
    this.address,
    this.city,
    this.zone,
    this.latitude,
    this.longitude,
    this.imageUrls,
    this.url,
    required this.isActive,
    required this.firstSeenAt,
    required this.lastSeenAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as String,
      externalId: json['externalId'] as String,
      source: PropertySource.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['source'] as String).toUpperCase(),
        orElse: () => PropertySource.idealista,
      ),
      title: json['title'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      pricePerM2: (json['pricePerM2'] as num?)?.toDouble(),
      propertyType: json['propertyType'] != null
          ? PropertyType.values.firstWhere(
              (e) =>
                  e.name.toUpperCase() ==
                  (json['propertyType'] as String).toUpperCase(),
              orElse: () => PropertyType.otro,
            )
          : null,
      operationType: json['operationType'] != null
          ? OperationType.values.firstWhere(
              (e) =>
                  e.name.toUpperCase() ==
                  (json['operationType'] as String).toUpperCase(),
              orElse: () => OperationType.venta,
            )
          : null,
      rooms: json['rooms'] as int?,
      bathrooms: json['bathrooms'] as int?,
      areaM2: (json['areaM2'] as num?)?.toDouble(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      zone: json['zone'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      imageUrls: (json['imageUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      url: json['url'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      firstSeenAt: DateTime.parse(json['firstSeenAt'] as String),
      lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'externalId': externalId,
      'source': source.name.toUpperCase(),
      'title': title,
      'description': description,
      'price': price,
      'pricePerM2': pricePerM2,
      'propertyType': propertyType?.name.toUpperCase(),
      'operationType': operationType?.name.toUpperCase(),
      'rooms': rooms,
      'bathrooms': bathrooms,
      'areaM2': areaM2,
      'address': address,
      'city': city,
      'zone': zone,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'url': url,
      'isActive': isActive,
      'firstSeenAt': firstSeenAt.toIso8601String(),
      'lastSeenAt': lastSeenAt.toIso8601String(),
    };
  }

  String get formattedPrice {
    if (price == null) return 'Precio no disponible';
    final formatter = price!.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$formatter €';
  }

  String get sourceDisplayName {
    switch (source) {
      case PropertySource.idealista:
        return 'Idealista';
      case PropertySource.fotocasa:
        return 'Fotocasa';
      case PropertySource.pisoscom:
        return 'Pisos.com';
    }
  }

  @override
  List<Object?> get props => [id, externalId, source];
}

class PropertyList {
  final List<Property> properties;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  const PropertyList({
    required this.properties,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory PropertyList.fromJson(Map<String, dynamic> json) {
    return PropertyList(
      properties: (json['properties'] as List<dynamic>)
          .map((e) => Property.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
    );
  }

  bool get hasMore => currentPage < totalPages - 1;
}
