import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/banner_model.dart';

abstract class BannersDataSource {
  Future<List<BannerModel>> getBanners();
  Future<void> addBanner(BannerModel banner);
  Future<void> updateBanner(BannerModel banner);
  Future<void> toggleStatus(String id, bool isActive);
  Future<void> deleteBanner(String id);
  Future<void> reorderBanners(List<String> orderedIds);
}

class BannersDataSourceImpl implements BannersDataSource {
  final FirebaseFirestore _db;
  BannersDataSourceImpl(this._db);

  @override
  Future<List<BannerModel>> getBanners() async {
    final snap = await _db.collection(DConstants.banners).get();

    return snap.docs
        .map((doc) => BannerModel.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  @override
  Future<void> addBanner(BannerModel banner) async {
    // Get max order
    final snap = await _db
        .collection(DConstants.banners)
        .orderBy('order', descending: true)
        .limit(1)
        .get();

    final maxOrder = snap.docs.isEmpty
        ? 0
        : (snap.docs.first.data()['order'] ?? 0) + 1;

    await _db
        .collection(DConstants.banners)
        .doc(banner.id)
        .set(banner.copyWithFields(order: maxOrder).toFirestore());
  }

  @override
  Future<void> updateBanner(BannerModel banner) async {
    await _db
        .collection(DConstants.banners)
        .doc(banner.id)
        .update(banner.toFirestore());
  }

  @override
  Future<void> toggleStatus(String id, bool isActive) async {
    await _db.collection(DConstants.banners).doc(id).update({
      'isActive': isActive,
    });
  }

  @override
  Future<void> deleteBanner(String id) async {
    await _db.collection(DConstants.banners).doc(id).delete();
  }

  @override
  Future<void> reorderBanners(List<String> orderedIds) async {
    final batch = _db.batch();
    for (int i = 0; i < orderedIds.length; i++) {
      batch.update(_db.collection(DConstants.banners).doc(orderedIds[i]), {
        'order': i,
      });
    }
    await batch.commit();
  }
}
