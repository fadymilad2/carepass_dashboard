import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

abstract class ServicesDataSource {
  Future<List<ServiceModel>> getServices({String? providerId});
  Future<void> addService(ServiceModel service);
  Future<void> updateService(ServiceModel service);
  Future<void> toggleService(String id, bool isAvailable);
  Future<void> deleteService(String id);
}

class ServicesDataSourceImpl implements ServicesDataSource {
  final FirebaseFirestore _db;
  ServicesDataSourceImpl(this._db);

  @override
  Future<List<ServiceModel>> getServices({String? providerId}) async {
    Query<Map<String, dynamic>> query = _db.collection('services');

    if (providerId != null && providerId.isNotEmpty) {
      query = query.where('providerId', isEqualTo: providerId);
    }

    final snap = await query.get();

    return snap.docs
        .map((doc) => ServiceModel.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> addService(ServiceModel service) async {
    await _db.collection('services').doc(service.id).set(service.toFirestore());
  }

  @override
  Future<void> updateService(ServiceModel service) async {
    await _db
        .collection('services')
        .doc(service.id)
        .update(service.toFirestore());
  }

  @override
  Future<void> toggleService(String id, bool isAvailable) async {
    await _db.collection('services').doc(id).update({
      'isAvailable': isAvailable,
    });
  }

  @override
  Future<void> deleteService(String id) async {
    await _db.collection('services').doc(id).delete();
  }
}
