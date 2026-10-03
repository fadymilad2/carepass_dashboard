import '../../../../core/utils/reporting.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/provider_entity.dart';

class ProviderModel extends ProviderEntity {
  const ProviderModel({
    required super.id,
    required super.name,
    required super.speciality,
    required super.type,
    super.types,
    required super.address,
    required super.phoneNumber,
    required super.area,
    super.latitude,
    super.longitude,
    required super.discountPercent,
    required super.rating,
    required super.isActive,
    required super.isInNetwork,
    required super.imageUrl,
    required super.services,
    required super.workingHours,
    super.website,
    required super.createdAt,
  });

  factory ProviderModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProviderModel(
      id: id,
      name: data['name'] ?? '',
      speciality: data['speciality'] ?? '',
      type: data['type'] ?? 'clinic',
      types:
          (data['types'] as List?)
              ?.whereType<String>()
              .where((value) => value.isNotEmpty)
              .toSet()
              .toList() ??
          const [],
      address: data['address'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      area: data['area'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      discountPercent: data['discountPercent'] ?? 0,
      rating: (data['rating'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
      isInNetwork: data['isInNetwork'] ?? false,
      imageUrl: data['imageUrl'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      workingHours: data['workingHours'] ?? '',
      website: data['website'],
      createdAt: reportDateString(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'speciality': speciality,
    'type': type,
    'types': providerTypes,
    'address': address,
    'phoneNumber': phoneNumber,
    'area': area,
    'latitude': latitude,
    'longitude': longitude,
    'discountPercent': discountPercent,
    'rating': rating,
    'isActive': isActive,
    'isInNetwork': isInNetwork,
    'imageUrl': imageUrl,
    'services': services,
    'workingHours': workingHours,
    'website': website,
    'createdAt': createdAt.isNotEmpty
        ? createdAt
        : DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory ProviderModel.empty() => ProviderModel(
    id: const Uuid().v4(),
    name: '',
    speciality: '',
    type: 'clinic',
    address: '',
    phoneNumber: '',
    area: 'Accra',
    latitude: null,
    longitude: null,
    discountPercent: 20,
    rating: 4.0,
    isActive: true,
    isInNetwork: true,
    imageUrl: '',
    services: [],
    workingHours: 'Mon - Fri: 9:00 AM - 6:00 PM',
    createdAt: DateTime.now().toIso8601String(),
  );

  ProviderModel copyWithFields({
    String? name,
    String? speciality,
    String? type,
    List<String>? types,
    String? address,
    String? phoneNumber,
    String? area,
    bool clearCoordinates = false,
    double? latitude,
    double? longitude,
    int? discountPercent,
    double? rating,
    bool? isActive,
    bool? isInNetwork,
    String? imageUrl,
    List<String>? services,
    String? workingHours,
    String? website,
  }) {
    return ProviderModel(
      id: id,
      name: name ?? this.name,
      speciality: speciality ?? this.speciality,
      type: type ?? this.type,
      types: types ?? this.types,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      area: area ?? this.area,
      latitude: clearCoordinates ? null : latitude ?? this.latitude,
      longitude: clearCoordinates ? null : longitude ?? this.longitude,
      discountPercent: discountPercent ?? this.discountPercent,
      rating: rating ?? this.rating,
      isActive: isActive ?? this.isActive,
      isInNetwork: isInNetwork ?? this.isInNetwork,
      imageUrl: imageUrl ?? this.imageUrl,
      services: services ?? this.services,
      workingHours: workingHours ?? this.workingHours,
      website: website ?? this.website,
      createdAt: createdAt,
    );
  }
}
