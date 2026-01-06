import 'package:equatable/equatable.dart';

class ScraperConfig extends Equatable {
  final String id;
  final List<String> cities;
  final List<String> operationTypes;
  final List<String>? propertyTypes;
  final double? minPrice;
  final double? maxPrice;
  final int? minRooms;
  final int? maxRooms;
  final double? minArea;
  final double? maxArea;
  final bool enabled;
  final String cronExpression;
  final List<String> sources;
  final DateTime updatedAt;

  const ScraperConfig({
    required this.id,
    required this.cities,
    required this.operationTypes,
    this.propertyTypes,
    this.minPrice,
    this.maxPrice,
    this.minRooms,
    this.maxRooms,
    this.minArea,
    this.maxArea,
    required this.enabled,
    required this.cronExpression,
    required this.sources,
    required this.updatedAt,
  });

  factory ScraperConfig.fromJson(Map<String, dynamic> json) {
    return ScraperConfig(
      id: json['id'] as String,
      cities: (json['cities'] as List<dynamic>).map((e) => e as String).toList(),
      operationTypes: (json['operationTypes'] as List<dynamic>).map((e) => e as String).toList(),
      propertyTypes: json['propertyTypes'] != null
          ? (json['propertyTypes'] as List<dynamic>).map((e) => e as String).toList()
          : null,
      minPrice: (json['minPrice'] as num?)?.toDouble(),
      maxPrice: (json['maxPrice'] as num?)?.toDouble(),
      minRooms: json['minRooms'] as int?,
      maxRooms: json['maxRooms'] as int?,
      minArea: (json['minArea'] as num?)?.toDouble(),
      maxArea: (json['maxArea'] as num?)?.toDouble(),
      enabled: json['enabled'] as bool,
      cronExpression: json['cronExpression'] as String,
      sources: (json['sources'] as List<dynamic>).map((e) => e as String).toList(),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cities': cities,
      'operationTypes': operationTypes,
      'propertyTypes': propertyTypes,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRooms': minRooms,
      'maxRooms': maxRooms,
      'minArea': minArea,
      'maxArea': maxArea,
      'enabled': enabled,
      'cronExpression': cronExpression,
      'sources': sources,
    };
  }

  ScraperConfig copyWith({
    String? id,
    List<String>? cities,
    List<String>? operationTypes,
    List<String>? propertyTypes,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    int? maxRooms,
    double? minArea,
    double? maxArea,
    bool? enabled,
    String? cronExpression,
    List<String>? sources,
    DateTime? updatedAt,
  }) {
    return ScraperConfig(
      id: id ?? this.id,
      cities: cities ?? this.cities,
      operationTypes: operationTypes ?? this.operationTypes,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRooms: minRooms ?? this.minRooms,
      maxRooms: maxRooms ?? this.maxRooms,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      enabled: enabled ?? this.enabled,
      cronExpression: cronExpression ?? this.cronExpression,
      sources: sources ?? this.sources,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get frequencyLabel {
    switch (cronExpression) {
      case '0 */15 * * * *':
        return 'Cada 15 minutos';
      case '0 */30 * * * *':
        return 'Cada 30 minutos';
      case '0 0 * * * *':
        return 'Cada hora';
      case '0 0 */2 * * *':
        return 'Cada 2 horas';
      case '0 0 */6 * * *':
        return 'Cada 6 horas';
      case '0 0 */12 * * *':
        return 'Cada 12 horas';
      case '0 0 8 * * *':
        return 'Una vez al día';
      default:
        return cronExpression;
    }
  }

  @override
  List<Object?> get props => [id, cities, operationTypes, enabled, cronExpression, sources];
}

class ScraperConfigUpdate {
  final List<String> cities;
  final List<String> operationTypes;
  final List<String>? propertyTypes;
  final double? minPrice;
  final double? maxPrice;
  final int? minRooms;
  final int? maxRooms;
  final double? minArea;
  final double? maxArea;
  final bool enabled;
  final String cronExpression;
  final List<String> sources;

  const ScraperConfigUpdate({
    required this.cities,
    required this.operationTypes,
    this.propertyTypes,
    this.minPrice,
    this.maxPrice,
    this.minRooms,
    this.maxRooms,
    this.minArea,
    this.maxArea,
    required this.enabled,
    required this.cronExpression,
    required this.sources,
  });

  Map<String, dynamic> toJson() {
    return {
      'cities': cities,
      'operationTypes': operationTypes,
      'propertyTypes': propertyTypes,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'minRooms': minRooms,
      'maxRooms': maxRooms,
      'minArea': minArea,
      'maxArea': maxArea,
      'enabled': enabled,
      'cronExpression': cronExpression,
      'sources': sources,
    };
  }

  factory ScraperConfigUpdate.fromConfig(ScraperConfig config) {
    return ScraperConfigUpdate(
      cities: config.cities,
      operationTypes: config.operationTypes,
      propertyTypes: config.propertyTypes,
      minPrice: config.minPrice,
      maxPrice: config.maxPrice,
      minRooms: config.minRooms,
      maxRooms: config.maxRooms,
      minArea: config.minArea,
      maxArea: config.maxArea,
      enabled: config.enabled,
      cronExpression: config.cronExpression,
      sources: config.sources,
    );
  }
}
