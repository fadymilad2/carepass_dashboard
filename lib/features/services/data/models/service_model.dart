import '../../../../core/utils/reporting.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/service_entity.dart';

class ServiceModel extends ServiceEntity {
  const ServiceModel({
    required super.id,
    required super.name,
    required super.category,
    required super.providerId,
    required super.providerName,
    required super.discountPercent,
    required super.isAvailable,
    required super.createdAt,
    super.description,
    super.imageUrl,
  });

  factory ServiceModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ServiceModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'consultation',
      providerId: data['providerId'] ?? '',
      providerName: data['providerName'] ?? '',
      discountPercent: data['discountPercent'] ?? 0,
      isAvailable: data['isAvailable'] ?? true,
      createdAt: reportDateString(data['createdAt']),
      description: data['description'],
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'category': category,
    'providerId': providerId,
    'providerName': providerName,
    'discountPercent': discountPercent,
    'isAvailable': isAvailable,
    'description': description,
    'imageUrl': imageUrl,
    'createdAt': createdAt.isNotEmpty
        ? createdAt
        : DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory ServiceModel.empty() => ServiceModel(
    id: const Uuid().v4(),
    name: '',
    category: 'consultation',
    providerId: '',
    providerName: '',
    discountPercent: 20,
    isAvailable: true,
    createdAt: DateTime.now().toIso8601String(),
  );

  ServiceModel copyWithFields({
    String? name,
    String? category,
    String? providerId,
    String? providerName,
    int? discountPercent,
    bool? isAvailable,
    String? description,
    String? imageUrl,
    bool clearImageUrl = false,
  }) {
    return ServiceModel(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      discountPercent: discountPercent ?? this.discountPercent,
      isAvailable: isAvailable ?? this.isAvailable,
      description: description ?? this.description,
      imageUrl: clearImageUrl ? null : (imageUrl ?? this.imageUrl),
      createdAt: createdAt,
    );
  }
}
