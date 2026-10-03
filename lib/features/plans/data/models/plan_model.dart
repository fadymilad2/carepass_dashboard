import 'package:uuid/uuid.dart';
import '../../domain/entities/plan_entity.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required super.id,
    required super.name,
    required super.price,
    required super.currency,
    required super.durationDays,
    required super.type,
    required super.features,
    required super.isActive,
    required super.isPopular,
    required super.order,
  });

  factory PlanModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PlanModel(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      currency: data['currency'] ?? 'GHS',
      durationDays: data['durationDays'] ?? 30,
      type: data['type'] ?? 'individual',
      features: List<String>.from(data['features'] ?? []),
      isActive: data['isActive'] ?? true,
      isPopular: data['isPopular'] ?? false,
      order: data['order'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'price': price,
    'currency': currency,
    'durationDays': durationDays,
    'type': type,
    'features': features,
    'isActive': isActive,
    'isPopular': isPopular,
    'order': order,
    'updatedAt': DateTime.now().toIso8601String(),
  };

  factory PlanModel.empty() => PlanModel(
    id: const Uuid().v4(),
    name: '',
    price: 0,
    currency: 'GHS',
    durationDays: 30,
    type: 'individual',
    features: [],
    isActive: true,
    isPopular: false,
    order: 0,
  );

  PlanModel copyWithFields({
    String? name,
    double? price,
    String? currency,
    int? durationDays,
    String? type,
    List<String>? features,
    bool? isActive,
    bool? isPopular,
    int? order,
  }) {
    return PlanModel(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      durationDays: durationDays ?? this.durationDays,
      type: type ?? this.type,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
      order: order ?? this.order,
    );
  }
}
