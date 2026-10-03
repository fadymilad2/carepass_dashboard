import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/reporting.dart';
import '../models/admin_model.dart';

abstract class AuthDataSource {
  Future<AdminModel> signIn({required String email, required String password});
  Future<AdminModel?> getCurrentAdmin();
  Future<void> signOut();
}

class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  AuthDataSourceImpl({
    required FirebaseAuth auth,
    required FirebaseFirestore db,
  }) : _auth = auth,
       _db = db;
  @override
  Future<AdminModel> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final admin = await getCurrentAdmin();
    if (admin == null) {
      throw Exception('An active administrator account is required.');
    }
    return admin;
  }

  @override
  Future<AdminModel?> getCurrentAdmin() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    try {
      final doc = await _db
          .collection('admin_users')
          .doc(uid)
          .get(const GetOptions(source: Source.server));
      if (_auth.currentUser?.uid != uid) return null;
      if (!isActiveAdminRecord(doc.data())) {
        await _auth.signOut();
        return null;
      }
      return AdminModel.fromFirestore(doc.data()!, doc.id);
    } catch (_) {
      if (_auth.currentUser?.uid == uid) await _auth.signOut();
      rethrow;
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
