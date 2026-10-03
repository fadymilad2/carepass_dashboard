import 'package:equatable/equatable.dart';

class ProviderEntity extends Equatable {
  final String id;
  final String name;
  final String speciality;
  final String type;
  final List<String> types;
  final String address;
  final String phoneNumber;
  final String area;
  final double? latitude;
  final double? longitude;
  final int discountPercent;
  final double rating;
  final bool isActive;
  final bool isInNetwork;
  final String imageUrl;
  final List<String> services;
  final String workingHours;
  final String? website;
  final String createdAt;

  const ProviderEntity({
    required this.id,
    required this.name,
    required this.speciality,
    required this.type,
    this.types = const [],
    required this.address,
    required this.phoneNumber,
    required this.area,
    this.latitude,
    this.longitude,
    required this.discountPercent,
    required this.rating,
    required this.isActive,
    required this.isInNetwork,
    required this.imageUrl,
    required this.services,
    required this.workingHours,
    this.website,
    required this.createdAt,
  });

  bool get hasLocation => latitude != null && longitude != null;

  List<String> get providerTypes => types.isEmpty ? [type] : types;
  bool offersType(String category) => providerTypes.contains(category);
  String get typeLabel => providerTypes.map(labelForType).join(' · ');

  static String labelForType(String type) {
    switch (type) {
      case 'hospital':
        return 'Hospital';
      case 'pharmacy':
        return 'Pharmacy';
      case 'lab':
        return 'Laboratory';
      case 'dental':
        return 'Dental Clinic';
      case 'clinic':
        return 'Clinic';
      case 'eye_clinic':
        return 'Eye Clinic';
      case 'diagnostic':
        return 'Diagnostic Center';
      case 'doctor':
        return 'Doctor';
      default:
        return type;
    }
  }

  String get discountLabel => 'Up to $discountPercent% off';
  String get avatarLetter => name.isNotEmpty ? name[0].toUpperCase() : '?';

  @override
  List<Object?> get props => [
    id,
    name,
    speciality,
    type,
    types,
    address,
    phoneNumber,
    area,
    latitude,
    longitude,
    discountPercent,
    rating,
    isActive,
    isInNetwork,
    imageUrl,
    services,
    workingHours,
    website,
    createdAt,
  ];
}
