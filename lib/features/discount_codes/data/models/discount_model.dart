import '../../../../core/utils/reporting.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/discount_entity.dart';

class DiscountCodeModel extends DiscountCodeEntity {
  const DiscountCodeModel({
    required super.id,
    required super.code,
    required super.discountValue,
    required super.discountType,
    required super.maxUses,
    required super.usedCount,
    required super.isActive,
    required super.expiryDate,
    required super.organization,
    required super.createdAt,
    required super.usedByUserIds,
    super.description,
  });

  factory DiscountCodeModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return DiscountCodeModel(
      id: id,
      code: data['code'] ?? '',
      discountValue: (data['discount'] ?? 0).toDouble(),
      discountType: data['type'] ?? 'percent',
      maxUses: data['maxUses'] ?? 0,
      usedCount: data['currentUses'] ?? 0,
      isActive: data['isActive'] ?? true,
      expiryDate: reportDateString(data['expiryDate']),
      organization: data['organization'] ?? '',
      createdAt: reportDateString(data['createdAt']),
      description: data['description'],
      usedByUserIds: List<String>.from(data['usedByUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'code': code,
    'discount': discountValue,
    'type': discountType,
    'maxUses': maxUses,
    'isActive': isActive,
    'expiryDate': expiryDate,
    'organization': organization,
    'description': description,
    'usedByUserIds': usedByUserIds,
    'createdAt': createdAt.isNotEmpty
        ? createdAt
        : DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory DiscountCodeModel.empty() => DiscountCodeModel(
    id: const Uuid().v4(),
    code: '',
    discountValue: 20,
    discountType: 'percent',
    maxUses: 0,
    usedCount: 0,
    isActive: true,
    expiryDate: '',
    organization: '',
    createdAt: DateTime.now().toIso8601String(),
    usedByUserIds: [],
  );

  DiscountCodeModel copyWithFields({
    String? code,
    double? discountValue,
    String? discountType,
    int? maxUses,
    bool? isActive,
    String? expiryDate,
    String? organization,
    String? description,
  }) {
    return DiscountCodeModel(
      id: id,
      code: code ?? this.code,
      discountValue: discountValue ?? this.discountValue,
      discountType: discountType ?? this.discountType,
      maxUses: maxUses ?? this.maxUses,
      usedCount: usedCount,
      isActive: isActive ?? this.isActive,
      expiryDate: expiryDate ?? this.expiryDate,
      organization: organization ?? this.organization,
      description: description ?? this.description,
      createdAt: createdAt,
      usedByUserIds: usedByUserIds,
    );
  }
}
