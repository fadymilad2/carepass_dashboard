import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/discount_model.dart';

abstract class DiscountDataSource {
  Future<List<DiscountCodeModel>> getCodes();
  Future<void> createCode(DiscountCodeModel code);
  Future<void> updateCode(DiscountCodeModel code);
  Future<void> toggleCode(String id, bool isActive);
  Future<void> deleteCode(String id);
  Future<DiscountCodeModel?> validateCode({
    required String code,
    required String userId,
  });
}

class DiscountDataSourceImpl implements DiscountDataSource {
  final FirebaseFirestore _db;
  DiscountDataSourceImpl(this._db);

  @override
  Future<List<DiscountCodeModel>> getCodes() async {
    final snap = await _db.collection(DConstants.discountCodes).get();

    return snap.docs
        .map((doc) => DiscountCodeModel.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> createCode(DiscountCodeModel code) async {
    _validate(code);
    // Ensure code is uppercase and unique
    final existing = await _db
        .collection(DConstants.discountCodes)
        .where('code', isEqualTo: code.code.trim().toUpperCase())
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Code "${code.code}" already exists');
    }

    await _db
        .collection(DConstants.discountCodes)
        .doc(code.id)
        .set(
          code
              .copyWithFields(code: code.code.trim().toUpperCase())
              .toFirestore()
            ..['currentUses'] = 0,
        );
  }

  @override
  Future<void> updateCode(DiscountCodeModel code) async {
    _validate(code);
    await _db
        .collection(DConstants.discountCodes)
        .doc(code.id)
        .update(code.toFirestore()..remove('usedByUserIds'));
  }

  @override
  Future<void> toggleCode(String id, bool isActive) async {
    await _db.collection(DConstants.discountCodes).doc(id).update({
      'isActive': isActive,
    });
  }

  @override
  Future<void> deleteCode(String id) async {
    await _db.collection(DConstants.discountCodes).doc(id).delete();
  }

  @override
  Future<DiscountCodeModel?> validateCode({
    required String code,
    required String userId,
  }) async {
    final snap = await _db
        .collection(DConstants.discountCodes)
        .where('code', isEqualTo: code.toUpperCase())
        .where('isActive', isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;

    final doc = snap.docs.first;
    final model = DiscountCodeModel.fromFirestore(doc.data(), doc.id);

    // Validate expiry
    if (model.isExpired) return null;

    // Validate max uses
    if (!model.isUnlimited && model.usedCount >= model.maxUses) {
      return null;
    }

    // Already used?
    if (model.usedByUserIds.contains(userId)) return null;

    return model;
  }

  void _validate(DiscountCodeModel code) {
    if (code.code.trim().isEmpty ||
        !code.discountValue.isFinite ||
        code.discountValue <= 0 ||
        code.maxUses < 0 ||
        !const ['percent', 'fixed'].contains(code.discountType) ||
        (code.isPercent && code.discountValue > 100)) {
      throw ArgumentError(
        'Enter a valid discount and a non-negative usage limit.',
      );
    }
  }
}
