import 'package:equatable/equatable.dart';

class DiscountCodeEntity extends Equatable {
  final String id;
  final String code;
  final double discountValue;
  final String discountType;
  final int maxUses;
  final int usedCount;
  final bool isActive;
  final String expiryDate;
  final String organization;
  final String createdAt;
  final List<String> usedByUserIds;
  final String? description;

  const DiscountCodeEntity({
    required this.id,
    required this.code,
    required this.discountValue,
    required this.discountType,
    required this.maxUses,
    required this.usedCount,
    required this.isActive,
    required this.expiryDate,
    required this.organization,
    required this.createdAt,
    required this.usedByUserIds,
    this.description,
  });

  bool get isPercent => discountType == 'percent';
  bool get isUnlimited => maxUses == 0;
  bool get isExpired {
    if (expiryDate.isEmpty) return false;
    try {
      return DateTime.parse(expiryDate).isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  bool get isBulk => organization.isNotEmpty;

  int get remaining =>
      maxUses == 0 ? -1 : (maxUses - usedCount).clamp(0, maxUses);

  String get discountLabel => isPercent
      ? '${discountValue.toStringAsFixed(0)}% off'
      : 'GHS ${discountValue.toStringAsFixed(2)} off';

  String get usageLabel =>
      isUnlimited ? '$usedCount / ∞' : '$usedCount / $maxUses';

  String get statusDisplay {
    if (!isActive) return 'inactive';
    if (isExpired) return 'expired';
    if (!isUnlimited && remaining <= 0) return 'exhausted';
    return 'active';
  }

  @override
  List<Object?> get props => [
    id,
    code,
    discountValue,
    discountType,
    maxUses,
    usedCount,
    isActive,
    expiryDate,
    organization,
    createdAt,
    usedByUserIds,
    description,
  ];
}
