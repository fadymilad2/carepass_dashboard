import '../../../../core/utils/reporting.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/banner_entity.dart';

class BannerModel extends BannerEntity {
  const BannerModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.imageUrl,
    required super.type,
    super.providerId,
    super.providerName,
    super.discountPercent,
    required super.areas,
    required super.isActive,
    required super.order,
    super.actionUrl,
    required super.createdAt,
  });

  factory BannerModel.fromFirestore(Map<String, dynamic> data, String id) {
    return BannerModel(
      id: id,
      title: data['title'] ?? '',
      subtitle: data['subtitle'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      type: data['type'] ?? 'general',
      providerId: data['providerId'],
      providerName: data['providerName'],
      discountPercent: data['discountPercent'],
      areas: List<String>.from(data['areas'] ?? []),
      isActive: data['isActive'] ?? true,
      order: data['order'] ?? 0,
      actionUrl: data['actionUrl'],
      createdAt: reportDateString(data['createdAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title,
    'subtitle': subtitle,
    'imageUrl': imageUrl,
    'type': type,
    'providerId': providerId,
    'providerName': providerName,
    'discountPercent': discountPercent,
    'areas': areas,
    'isActive': isActive,
    'order': order,
    'actionUrl': actionUrl,
    'createdAt': createdAt.isNotEmpty
        ? createdAt
        : DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory BannerModel.empty() => BannerModel(
    id: const Uuid().v4(),
    title: '',
    subtitle: '',
    imageUrl: '',
    type: 'general',
    areas: [],
    isActive: true,
    order: 0,
    createdAt: DateTime.now().toIso8601String(),
  );

  BannerModel copyWithFields({
    String? title,
    String? subtitle,
    String? imageUrl,
    String? type,
    String? providerId,
    String? providerName,
    int? discountPercent,
    List<String>? areas,
    bool? isActive,
    int? order,
    String? actionUrl,
  }) {
    return BannerModel(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      type: type ?? this.type,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      discountPercent: discountPercent ?? this.discountPercent,
      areas: areas ?? this.areas,
      isActive: isActive ?? this.isActive,
      order: order ?? this.order,
      actionUrl: actionUrl ?? this.actionUrl,
      createdAt: createdAt,
    );
  }
}
