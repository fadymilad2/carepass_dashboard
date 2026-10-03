import 'package:equatable/equatable.dart';

class PlanEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String currency;
  final int durationDays;
  final String type;
  final List<String> features;
  final bool isActive;
  final bool isPopular;
  final int order;

  const PlanEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.type,
    required this.features,
    required this.isActive,
    required this.isPopular,
    required this.order,
  });

  String get typeLabel => type == 'family' ? 'Family' : 'Individual';

  String get durationLabel {
    if (durationDays >= 365) return '1 Year';
    if (durationDays >= 90) return '3 Months';
    if (durationDays >= 30) return '1 Month';
    return '$durationDays Days';
  }

  String get priceLabel => '$currency ${price.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
    id,
    name,
    price,
    currency,
    durationDays,
    type,
    features,
    isActive,
    isPopular,
    order,
  ];
}
