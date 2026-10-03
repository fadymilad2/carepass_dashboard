import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/admin_user_model.dart';
import '../../domain/entities/admin_user_entity.dart';

abstract class AdminUsersDataSource {
  Future<List<AdminUserModel>> getAdminUsers();

  Future<void> createAdminUser({
    required String name,
    required String email,
    required String password,
    required AdminRole role,
    required List<String> permissions,
  });

  Future<void> updateAdminRole({
    required String adminId,
    required AdminRole newRole,
  });

  Future<void> updateAdminPermissions({
    required String adminId,
    required List<String> permissions,
    required AdminRole role,
  });

  Future<void> toggleAdminStatus({
    required String adminId,
    required bool isActive,
  });

  Future<void> deleteAdminUser(String adminId);
}

class AdminUsersDataSourceImpl implements AdminUsersDataSource {
  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  AdminUsersDataSourceImpl({
    required FirebaseFirestore db,
    required FirebaseAuth auth,
  }) : _db = db,
       _auth = auth;

  @override
  Future<List<AdminUserModel>> getAdminUsers() async {
    final snap = await _db.collection(DConstants.adminUsers).get();

    return snap.docs
        .map((doc) => AdminUserModel.fromFirestore(doc.data(), doc.id))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<void> createAdminUser({
    required String name,
    required String email,
    required String password,
    required AdminRole role,
    required List<String> permissions,
  }) async {
    final app = await Firebase.initializeApp(
      name: 'adminCreate_${const Uuid().v4()}',
      options: Firebase.app().options,
    );
    final auth = FirebaseAuth.instanceFor(app: app);
    User? createdUser;
    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      createdUser = credential.user!;
      final model = AdminUserModel(
        id: createdUser.uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        permissions: permissions,
        isActive: true,
        createdAt: DateTime.now().toUtc().toIso8601String(),
      );
      try {
        await _db
            .collection(DConstants.adminUsers)
            .doc(createdUser.uid)
            .set(model.toFirestore());
      } catch (error) {
        // Roll back the new login if its administrator profile was rejected.
        try {
          await createdUser.delete();
        } catch (_) {
          throw StateError(
            'Admin profile could not be saved and login cleanup '
            'failed. Remove the new login in Firebase Authentication before '
            'retrying. Original error: $error',
          );
        }
        rethrow;
      }
    } finally {
      try {
        await auth.signOut();
      } finally {
        await app.delete();
      }
    }
  }

  void _preventSelfChange(String adminId) {
    if (_auth.currentUser?.uid == adminId) {
      throw StateError('Ask another administrator to change your own access.');
    }
  }

  @override
  Future<void> updateAdminRole({
    required String adminId,
    required AdminRole newRole,
  }) async {
    _preventSelfChange(adminId);
    await _db.collection(DConstants.adminUsers).doc(adminId).update({
      'role': newRole.key,
      'permissions': newRole.permissions,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> updateAdminPermissions({
    required String adminId,
    required List<String> permissions,
    required AdminRole role,
  }) async {
    _preventSelfChange(adminId);
    await _db.collection(DConstants.adminUsers).doc(adminId).update({
      'role': role.key,
      'permissions': permissions,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> toggleAdminStatus({
    required String adminId,
    required bool isActive,
  }) async {
    _preventSelfChange(adminId);
    await _db.collection(DConstants.adminUsers).doc(adminId).update({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> deleteAdminUser(String adminId) async {
    _preventSelfChange(adminId);
    await _db.collection(DConstants.adminUsers).doc(adminId).delete();
  }
}
