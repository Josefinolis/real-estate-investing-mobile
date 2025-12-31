import 'package:equatable/equatable.dart';
import 'property.dart';

class SearchFilter extends Equatable {
  final String? city;
  final List<String>? zones;
  final OperationType? operationType;
  final PropertyType? propertyType;
  final double? minPrice;
  final double? maxPrice;
  final int? minRooms;
  final int? maxRooms;
  final double? minArea;
  final double? maxArea;
  final int page;
  final int size;

  const SearchFilter({
    this.city,
    this.zones,
    this.operationType,
    this.propertyType,
    this.minPrice,
    this.maxPrice,
    this.minRooms,
    this.maxRooms,
    this.minArea,
    this.maxArea,
    this.page = 0,
    this.size = 20,
  });

  SearchFilter copyWith({
    String? city,
    List<String>? zones,
    OperationType? operationType,
    PropertyType? propertyType,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
    int? maxRooms,
    double? minArea,
    double? maxArea,
    int? page,
    int? size,
  }) {
    return SearchFilter(
      city: city ?? this.city,
      zones: zones ?? this.zones,
      operationType: operationType ?? this.operationType,
      propertyType: propertyType ?? this.propertyType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minRooms: minRooms ?? this.minRooms,
      maxRooms: maxRooms ?? this.maxRooms,
      minArea: minArea ?? this.minArea,
      maxArea: maxArea ?? this.maxArea,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (city != null) params['city'] = city;
    if (operationType != null) {
      params['operationType'] = operationType!.name.toUpperCase();
    }
    if (propertyType != null) {
      params['propertyType'] = propertyType!.name.toUpperCase();
    }
    if (minPrice != null) params['minPrice'] = minPrice.toString();
    if (maxPrice != null) params['maxPrice'] = maxPrice.toString();
    if (minRooms != null) params['minRooms'] = minRooms.toString();
    if (maxRooms != null) params['maxRooms'] = maxRooms.toString();
    if (minArea != null) params['minArea'] = minArea.toString();
    if (maxArea != null) params['maxArea'] = maxArea.toString();
    params['page'] = page.toString();
    params['size'] = size.toString();

    return params;
  }

  bool get hasActiveFilters =>
      city != null ||
      operationType != null ||
      propertyType != null ||
      minPrice != null ||
      maxPrice != null ||
      minRooms != null ||
      maxRooms != null ||
      minArea != null ||
      maxArea != null;

  @override
  List<Object?> get props => [
        city,
        zones,
        operationType,
        propertyType,
        minPrice,
        maxPrice,
        minRooms,
        maxRooms,
        minArea,
        maxArea,
        page,
        size,
      ];
}
