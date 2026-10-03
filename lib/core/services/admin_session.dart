import 'dart:async';
import '../utils/reporting.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AdminSession extends ChangeNotifier {
  // ── Singleton ──────────────────────────────────────────────────────────
  static final AdminSession instance = AdminSession(
    auth: FirebaseAuth.instance,
    db: FirebaseFirestore.instance,
  );
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;
  StreamSubscription<User?>? _authSubscription;
  bool _disposed = false;
  AdminSession({required FirebaseAuth auth, required FirebaseFirestore db})
    : _auth = auth,
      _db = db {
    _listenToAuth();
  }

  // ── State ───────────────────────────────────────────────────────────────
  String _role = '';
  String _name = '';
  String _email = '';
  List<String> _permissions = [];
  bool _isLoaded = false;
  bool _isValidAdmin = false;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _adminSubscription;
  int _generation = 0;

  // ── Getters ─────────────────────────────────────────────────────────────
  String get role => _role;
  String get name => _name;
  String get email => _email;
  List<String> get permissions => List.unmodifiable(_permissions);
  bool get isLoaded => _isLoaded;
  bool get isValidAdmin => _isValidAdmin;
  bool get isSuperAdmin => _role == 'super_admin';

  String get avatarLetter => _name.isNotEmpty ? _name[0].toUpperCase() : 'A';

  String get roleLabel {
    switch (_role) {
      case 'super_admin':
        return 'Super Admin';
      case 'support':
        return 'Support';
      case 'marketer':
        return 'Marketer';
      case 'custom':
        return 'Custom';
      default:
        return 'Admin';
    }
  }

  // ── Permission Checks ───────────────────────────────────────────────────
  /// Returns true if admin has this permission OR is super_admin
  bool hasPermission(String permission) {
    if (!_isLoaded || !_isValidAdmin) return false;
    if (isSuperAdmin) return true;
    return _permissions.contains(permission);
  }

  /// Returns true if admin has ANY of these permissions OR is super_admin
  bool hasAnyPermission(List<String> perms) {
    if (!_isLoaded || !_isValidAdmin) return false;
    if (isSuperAdmin) return true;
    return perms.any((p) => _permissions.contains(p));
  }

  // ── Auth Listener ───────────────────────────────────────────────────────
  void _listenToAuth() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      final generation = ++_generation;
      _adminSubscription?.cancel();
      _clear();
      if (user == null) return;
      _adminSubscription = _db
          .collection('admin_users')
          .doc(user.uid)
          .snapshots(includeMetadataChanges: true)
          .listen((snap) {
            if (_disposed || generation != _generation) return;
            if (snap.metadata.isFromCache) return;
            if (!isActiveAdminRecord(snap.data())) {
              _reject(generation);
              return;
            }
            try {
              _applyData(snap.data()!);
            } catch (_) {
              _reject(generation);
              return;
            }
            _isValidAdmin = true;
            _isLoaded = true;
            notifyListeners();
          }, onError: (Object error) => _reject(generation));
    });
  }

  void _reject(int generation) {
    if (_disposed || generation != _generation) return;
    _clear();
    _isLoaded = true;
    notifyListeners();
    unawaited(
      _auth.signOut().catchError((Object error) {
        debugPrint('Sign out after session rejection failed: $error');
      }),
    );
  }

  void _applyData(Map<String, dynamic> data) {
    _name = data['name'] as String? ?? '';
    _email = data['email'] as String? ?? '';
    _role = data['role'] as String? ?? '';
    _permissions = List<String>.from(data['permissions'] as List? ?? []);
  }

  // ── Clear ───────────────────────────────────────────────────────────────
  void _clear() {
    _role = '';
    _name = '';
    _email = '';
    _permissions = [];
    _isLoaded = false;
    _isValidAdmin = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_generation;
    _authSubscription?.cancel();
    _adminSubscription?.cancel();
    super.dispose();
  }
}
