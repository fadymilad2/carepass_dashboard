import 'package:equatable/equatable.dart';

class BannerEntity extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String type;
  final String? providerId;
  final String? providerName;
  final int? discountPercent;
  final List<String> areas;
  final bool isActive;
  final int order;
  final String? actionUrl;
  final String createdAt;

  const BannerEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.type,
    this.providerId,
    this.providerName,
    this.discountPercent,
    required this.areas,
    required this.isActive,
    required this.order,
    this.actionUrl,
    required this.createdAt,
  });

  String get typeLabel {
    switch (type) {
      case 'provider':
        return 'Provider';
      case 'promotional':
        return 'Promotional';
      default:
        return 'General';
    }
  }

  String get areasLabel => areas.isEmpty ? 'All Areas' : areas.join(', ');

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    imageUrl,
    type,
    providerId,
    providerName,
    discountPercent,
    areas,
    isActive,
    order,
    actionUrl,
    createdAt,
  ];
}
