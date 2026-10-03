import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:carepass_dashboard/core/services/admin_session.dart';
import 'package:carepass_dashboard/features/admin_users/data/datasources/admin_users_datasource.dart';
import 'package:carepass_dashboard/features/admin_users/data/models/admin_user_model.dart';
import 'package:carepass_dashboard/features/admin_users/domain/entities/admin_user_entity.dart';
import 'package:carepass_dashboard/features/auth/data/datasources/auth_datasource.dart';
import 'package:carepass_dashboard/features/auth/domain/repositories/auth_repository.dart';
import 'package:carepass_dashboard/features/auth/domain/usecases/auth_usecases.dart';
import 'package:carepass_dashboard/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:carepass_dashboard/features/banners/data/datasources/banners_datasource.dart';
import 'package:carepass_dashboard/features/banners/data/models/banner_model.dart';
import 'package:carepass_dashboard/features/banners/data/repositories/banners_repository_impl.dart';
import 'package:carepass_dashboard/features/banners/domain/usecases/banners_usecases.dart';
import 'package:carepass_dashboard/features/banners/presentation/bloc/banners_bloc.dart';
import 'package:carepass_dashboard/features/discount_codes/data/datasources/discount_datasource.dart';
import 'package:carepass_dashboard/features/discount_codes/data/models/discount_model.dart';
import 'package:carepass_dashboard/features/plans/data/datasources/plans_datasource.dart';
import 'package:carepass_dashboard/features/plans/data/models/plan_model.dart';
import 'package:carepass_dashboard/features/providers/data/datasources/providers_datasource.dart';
import 'package:carepass_dashboard/features/providers/data/models/provider_model.dart';
import 'package:carepass_dashboard/features/providers/data/repositories/providers_repository_impl.dart';
import 'package:carepass_dashboard/features/providers/domain/usecases/providers_usecases.dart';
import 'package:carepass_dashboard/features/providers/presentation/bloc/providers_bloc.dart';
import 'package:carepass_dashboard/features/users/data/datasources/users_datasource.dart';
import 'package:carepass_dashboard/features/users/data/models/user_model.dart';
import 'package:carepass_dashboard/features/users/data/repositories/users_repository_impl.dart';
import 'package:carepass_dashboard/features/users/domain/entities/user_entity.dart';
import 'package:carepass_dashboard/features/users/domain/repositories/users_repository.dart';
import 'package:carepass_dashboard/features/users/domain/usecases/users_usecases.dart';
import 'package:carepass_dashboard/features/users/presentation/bloc/users_bloc.dart';

class _User extends Fake implements User {
  @override
  String get uid => 'admin';
}

class _Auth extends Fake implements FirebaseAuth {
  User? user = _User();
  final changes = StreamController<User?>.broadcast();
  @override
  User? get currentUser => user;
  @override
  Stream<User?> authStateChanges() => changes.stream;
  @override
  Future<void> signOut() async {
    user = null;
    changes.add(null);
  }
}

class _FailedSignOut extends Fake implements AuthRepository {
  @override
  Future<void> signOut() async => throw StateError('Offline');
}

class _DelayedUsers extends Fake implements UsersRepository {
  final firstRead = Completer<Either<String, List<UserEntity>>>();
  int reads = 0;
  @override
  Future<Either<String, List<UserEntity>>> getUsers() {
    reads++;
    return reads == 1
        ? firstRead.future
        : Future.value(Right([_member('New')]));
  }
}

UserModel _member(String name) => UserModel.fromFirestore({
  'username': name,
  'phoneNumber': '123',
  'email': 'member@example.com',
  'subscriptionStatus': 'active',
  'cardExpiryDate': '2099-01-01T00:00:00Z',
}, 'member');

UsersBloc _users(UsersRepository repo) => UsersBloc(
  getUsers: GetUsers(repo),
  updateStatus: UpdateUserStatus(repo),
  extendSub: ExtendSubscription(repo),
);

Future<T> _next<T>(Stream<Object?> stream) => stream
    .where((s) => s is T)
    .cast<T>()
    .first
    .timeout(const Duration(seconds: 5));

void main() {
  test(
    'custom admins can restore a session with their stored permissions',
    () async {
      final db = FakeFirebaseFirestore();
      final auth = _Auth();
      addTearDown(auth.changes.close);
      await db.collection('admin_users').doc('admin').set({
        'name': 'Custom',
        'role': 'custom',
        'isActive': true,
        'permissions': ['view_users'],
      });
      final admin = await AuthDataSourceImpl(
        auth: auth,
        db: db,
      ).getCurrentAdmin();
      expect(admin?.role, 'custom');
      expect(admin?.permissions, ['view_users']);
      expect(auth.currentUser, isNotNull);
    },
  );

  test(
    'admin models keep stored permissions and accept Firestore timestamps',
    () {
      final admin = AdminUserModel.fromFirestore({
        'role': 'support',
        'permissions': ['view_users'],
        'createdAt': Timestamp.fromDate(DateTime.utc(2026)),
      }, 'admin');
      expect(admin.permissions, ['view_users']);
      expect(admin.isActive, isFalse);
      expect(admin.createdAt, '2026-01-01T00:00:00.000Z');
      expect(AdminRole.fromString('unknown'), AdminRole.custom);
    },
  );

  test('admin lists include records without a creation date', () async {
    final db = FakeFirebaseFirestore();
    final auth = _Auth();
    addTearDown(auth.changes.close);
    await db.collection('admin_users').doc('legacy').set({'role': 'custom'});
    expect(
      await AdminUsersDataSourceImpl(db: db, auth: auth).getAdminUsers(),
      hasLength(1),
    );
  });

  test(
    'own administrator access cannot be changed by the dashboard source',
    () async {
      final auth = _Auth();
      addTearDown(auth.changes.close);
      final source = AdminUsersDataSourceImpl(
        db: FakeFirebaseFirestore(),
        auth: auth,
      );
      await expectLater(source.deleteAdminUser('admin'), throwsStateError);
      await expectLater(
        source.toggleAdminStatus(adminId: 'admin', isActive: false),
        throwsStateError,
      );
      await expectLater(
        source.updateAdminRole(adminId: 'admin', newRole: AdminRole.support),
        throwsStateError,
      );
      await expectLater(
        source.updateAdminPermissions(
          adminId: 'admin',
          permissions: [],
          role: AdminRole.custom,
        ),
        throwsStateError,
      );
    },
  );

  test(
    'session revocation clears permissions and disposal stops listeners',
    () async {
      final db = FakeFirebaseFirestore();
      final auth = _Auth();
      addTearDown(auth.changes.close);
      final ref = db.collection('admin_users').doc('admin');
      await ref.set({
        'role': 'custom',
        'isActive': true,
        'permissions': ['view_users'],
      });
      final session = AdminSession(auth: auth, db: db);
      final ready = Completer<void>();
      session.addListener(() {
        if (session.isValidAdmin && !ready.isCompleted) ready.complete();
      });
      auth.changes.add(auth.user);
      await ready.future.timeout(const Duration(seconds: 5));
      expect(session.hasAnyPermission(['view_users']), isTrue);
      expect(
        () => session.permissions.add('manage_users'),
        throwsUnsupportedError,
      );
      final revoked = Completer<void>();
      session.addListener(() {
        if (!session.isValidAdmin && !revoked.isCompleted) revoked.complete();
      });
      await ref.update({'isActive': false});
      await revoked.future.timeout(const Duration(seconds: 5));
      expect(session.hasPermission('view_users'), isFalse);
      expect(session.hasAnyPermission(['view_users']), isFalse);
      session.dispose();
      expect(auth.changes.hasListener, isFalse);
    },
  );

  test(
    'sign-out errors are reported instead of falsely marking signed out',
    () async {
      final repo = _FailedSignOut();
      final bloc = AuthBloc(
        signIn: SignInAdmin(repo),
        getAdmin: GetCurrentAdmin(repo),
        signOut: SignOutAdmin(repo),
      );
      addTearDown(bloc.close);
      final error = _next<AuthError>(bloc.stream);
      bloc.add(AuthSignOutRequested());
      expect((await error).message, contains('Sign out failed'));
      expect(bloc.state, isNot(isA<AuthUnauthenticated>()));
    },
  );

  test(
    'search, filter and another action work after updating a user',
    () async {
      final db = FakeFirebaseFirestore();
      await db.collection('users').doc('member').set({
        'username': 'Member',
        'email': 'member@example.com',
        'subscriptionStatus': 'active',
        'cardExpiryDate': '2099-01-01T00:00:00Z',
      });
      final bloc = _users(UsersRepositoryImpl(UsersDataSourceImpl(db)));
      addTearDown(bloc.close);
      var loaded = _next<UsersLoaded>(bloc.stream);
      bloc.add(UsersLoadRequested());
      await loaded;
      var success = _next<UsersActionSuccess>(bloc.stream);
      bloc.add(
        UserStatusUpdateRequested(userId: 'member', status: 'suspended'),
      );
      await success;
      success = _next<UsersActionSuccess>(bloc.stream);
      bloc.add(UserStatusUpdateRequested(userId: 'member', status: 'active'));
      await success;
      loaded = _next<UsersLoaded>(bloc.stream);
      bloc.add(UsersSearchChanged(' member@example.com '));
      expect((await loaded).filtered, hasLength(1));
      loaded = _next<UsersLoaded>(bloc.stream);
      bloc.add(UsersFilterChanged('suspended'));
      expect((await loaded).filtered, isEmpty);
      expect(
        (await db
                .collection('users')
                .doc('member')
                .collection('notifications')
                .get())
            .docs,
        hasLength(2),
      );
    },
  );

  test(
    'overlapping reloads finish in dispatch order and updated names emit',
    () async {
      final repo = _DelayedUsers();
      final bloc = _users(repo);
      addTearDown(bloc.close);
      final states = <UsersState>[];
      final sub = bloc.stream.listen(states.add);
      addTearDown(sub.cancel);
      final latest = bloc.stream.firstWhere(
        (s) => s is UsersLoaded && s.allUsers.single.username == 'New',
      );
      bloc.add(UsersLoadRequested());
      bloc.add(UsersLoadRequested());
      await Future<void>.delayed(Duration.zero);
      expect(repo.reads, 1);
      repo.firstRead.complete(Right([_member('Old')]));
      await latest.timeout(const Duration(seconds: 5));
      expect(
        states.whereType<UsersLoaded>().map((s) => s.allUsers.single.username),
        ['Old', 'New'],
      );
      expect(_member('Old'), isNot(_member('New')));
    },
  );

  test(
    'discount edits preserve redemptions recorded after form opened',
    () async {
      final db = FakeFirebaseFirestore();
      final source = DiscountDataSourceImpl(db);
      final code = DiscountCodeModel.empty().copyWithFields(code: 'HALF');
      await source.createCode(code);
      final opened = (await source.getCodes()).single;
      final ref = db.collection('discount_codes').doc(code.id);
      await ref.update({
        'currentUses': 1,
        'usedByUserIds': ['member'],
      });
      await source.updateCode(opened.copyWithFields(description: 'Updated'));
      final data = (await ref.get()).data()!;
      expect(data['usedByUserIds'], ['member']);
      expect(data['currentUses'], 1);
    },
  );

  test('plans with missing order remain visible', () async {
    final db = FakeFirebaseFirestore();
    await db.collection('subscription_plans').doc('legacy').set({
      'name': 'Legacy',
    });
    expect((await PlansDataSourceImpl(db).getPlans()).single.id, 'legacy');
  });

  test('provider status toggles preserve editable coordinates', () async {
    final db = FakeFirebaseFirestore();
    final source = ProvidersDataSourceImpl(db);
    final provider = ProviderModel.empty().copyWithFields(
      latitude: 5.6,
      longitude: -0.2,
    );
    await source.addProvider(provider);
    final repo = ProvidersRepositoryImpl(source);
    final bloc = ProvidersBloc(
      get: GetProviders(repo),
      add: AddProvider(repo),
      update: UpdateProvider(repo),
      toggle: ToggleProviderStatus(repo),
      delete: DeleteProvider(repo),
    );
    addTearDown(bloc.close);
    final loaded = _next<ProvidersLoaded>(bloc.stream);
    bloc.add(ProvidersLoadRequested());
    await loaded;
    final success = _next<ProvidersActionSuccess>(bloc.stream);
    bloc.add(
      ProviderToggleStatusRequested(providerId: provider.id, isActive: false),
    );
    final updated = (await success).all.single as ProviderModel;
    expect(updated.latitude, 5.6);
    expect(updated.longitude, -0.2);
    expect(updated.copyWithFields(clearCoordinates: true).hasLocation, isFalse);
  });

  test(
    'banner reordering persists and later edits keep the saved order',
    () async {
      final db = FakeFirebaseFirestore();
      final source = BannersDataSourceImpl(db);
      final first = BannerModel.empty().copyWithFields(title: 'First');
      final second = BannerModel.empty().copyWithFields(title: 'Second');
      await source.addBanner(first);
      await source.addBanner(second);
      final repo = BannersRepositoryImpl(source);
      final bloc = BannersBloc(
        get: GetBanners(repo),
        add: AddBanner(repo),
        update: UpdateBanner(repo),
        toggle: ToggleBannerStatus(repo),
        delete: DeleteBanner(repo),
        reorder: ReorderBanners(repo),
      );
      addTearDown(bloc.close);
      var loaded = _next<BannersLoaded>(bloc.stream);
      bloc.add(BannersLoadRequested());
      await loaded;
      loaded = _next<BannersLoaded>(bloc.stream);
      bloc.add(BannersReordered([second.id, first.id]));
      final reordered = await loaded;
      expect(reordered.banners.map((b) => b.id), [second.id, first.id]);
      expect((await source.getBanners()).map((b) => b.id), [
        second.id,
        first.id,
      ]);
      final edited = (reordered.banners.last as BannerModel).copyWithFields(
        title: 'Edited',
      );
      final success = _next<BannersActionSuccess>(bloc.stream);
      bloc.add(BannerUpdateRequested(edited));
      await success;
      expect((await source.getBanners()).last.order, 1);
      final error = _next<BannersError>(bloc.stream);
      bloc.add(BannersReordered([first.id, first.id]));
      await error;
      expect((await source.getBanners()).first.id, second.id);
    },
  );
  test('invalid prices and discounts are rejected without writes', () async {
    final db = FakeFirebaseFirestore();
    final plans = PlansDataSourceImpl(db);
    for (final price in [double.nan, double.infinity, -1.0]) {
      await expectLater(
        plans.addPlan(
          PlanModel.empty().copyWithFields(name: 'Invalid', price: price),
        ),
        throwsArgumentError,
      );
    }
    await expectLater(
      plans.addPlan(
        PlanModel.empty().copyWithFields(name: 'Invalid', durationDays: 0),
      ),
      throwsArgumentError,
    );
    final discounts = DiscountDataSourceImpl(db);
    await expectLater(
      discounts.createCode(
        DiscountCodeModel.empty().copyWithFields(
          code: 'BAD',
          discountValue: 101,
        ),
      ),
      throwsArgumentError,
    );
    expect((await db.collection('subscription_plans').get()).docs, isEmpty);
    expect((await db.collection('discount_codes').get()).docs, isEmpty);
  });
}
