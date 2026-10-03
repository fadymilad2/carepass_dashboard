import 'package:equatable/equatable.dart';

class ServiceEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final String providerId;
  final String providerName;
  final int discountPercent;
  final bool isAvailable;
  final String createdAt;
  final String? description;
  final String? imageUrl;

  const ServiceEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.providerId,
    required this.providerName,
    required this.discountPercent,
    required this.isAvailable,
    required this.createdAt,
    this.description,
    this.imageUrl,
  });

  String get categoryLabel {
    switch (category) {
      case 'consultation':
        return 'Consultation';
      case 'radiology':
        return 'Radiology';
      case 'lab':
        return 'Lab';
      case 'pharmacy':
        return 'Pharmacy';
      case 'dental':
        return 'Dental';
      case 'physiotherapy':
        return 'Physiotherapy';
      case 'blood_pressure':
        return 'Blood Pressure';
      case 'blood_sugar':
        return 'Blood Sugar';
      default:
        return category;
    }
  }

  String get discountLabel => '$discountPercent% off';

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    providerId,
    providerName,
    discountPercent,
    isAvailable,
    createdAt,
    description,
    imageUrl,
  ];
}
