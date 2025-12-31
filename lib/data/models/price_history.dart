import 'package:equatable/equatable.dart';

class PriceHistory extends Equatable {
  final String id;
  final double price;
  final DateTime recordedAt;

  const PriceHistory({
    required this.id,
    required this.price,
    required this.recordedAt,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    return PriceHistory(
      id: json['id'] as String,
      price: (json['price'] as num).toDouble(),
      recordedAt: DateTime.parse(json['recordedAt'] as String),
    );
  }

  String get formattedPrice {
    final formatter = price.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    return '$formatter €';
  }

  @override
  List<Object?> get props => [id, price, recordedAt];
}

class PropertyDetail {
  final dynamic property;
  final List<PriceHistory> priceHistory;
  final bool isFavorite;

  const PropertyDetail({
    required this.property,
    required this.priceHistory,
    required this.isFavorite,
  });

  factory PropertyDetail.fromJson(Map<String, dynamic> json) {
    return PropertyDetail(
      property: json['property'],
      priceHistory: (json['priceHistory'] as List<dynamic>)
          .map((e) => PriceHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavorite: json['isFavorite'] as bool? ?? false,
    );
  }
}
