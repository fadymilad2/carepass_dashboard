import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/provider_model.dart';

abstract class ProvidersDataSource {
  Future<List<ProviderModel>> getProviders();
  Future<void> addProvider(ProviderModel provider);
  Future<void> updateProvider(ProviderModel provider);
  Future<void> toggleStatus(String id, bool isActive);
  Future<void> deleteProvider(String id);
}

class ProvidersDataSourceImpl implements ProvidersDataSource {
  final FirebaseFirestore _db;
  ProvidersDataSourceImpl(this._db);

  @override
  Future<List<ProviderModel>> getProviders() async {
    final snap = await _db.collection(DConstants.providers).get();

    return snap.docs
        .map((doc) => ProviderModel.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addProvider(ProviderModel provider) async {
    await _db
        .collection(DConstants.providers)
        .doc(provider.id)
        .set(provider.toFirestore());
  }

  @override
  Future<void> updateProvider(ProviderModel provider) async {
    await _db
        .collection(DConstants.providers)
        .doc(provider.id)
        .update(provider.toFirestore());
  }

  @override
  Future<void> toggleStatus(String id, bool isActive) async {
    await _db.collection(DConstants.providers).doc(id).update({
      'isActive': isActive,
    });
  }

  @override
  Future<void> deleteProvider(String id) async {
    await _db.collection(DConstants.providers).doc(id).delete();
  }
}
