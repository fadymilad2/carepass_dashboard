import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/overview/data/datasources/overview_datasource.dart';
import '../../features/overview/data/repositories/overview_repository_impl.dart';
import '../../features/overview/domain/repositories/overview_repository.dart';
import '../../features/overview/domain/usecases/get_overview.dart';
import '../../features/overview/presentation/bloc/overview_bloc.dart';
import '../../features/users/data/datasources/users_datasource.dart';
import '../../features/users/data/repositories/users_repository_impl.dart';
import '../../features/users/domain/repositories/users_repository.dart';
import '../../features/users/domain/usecases/users_usecases.dart';
import '../../features/users/presentation/bloc/users_bloc.dart';
import '../../features/providers/data/datasources/providers_datasource.dart';
import '../../features/providers/data/repositories/providers_repository_impl.dart';
import '../../features/providers/domain/repositories/providers_repository.dart';
import '../../features/providers/domain/usecases/providers_usecases.dart';
import '../../features/providers/presentation/bloc/providers_bloc.dart';
import '../../features/payments/data/datasources/payments_datasource.dart';
import '../../features/payments/data/repositories/payments_repository_impl.dart';
import '../../features/payments/domain/repositories/payments_repository.dart';
import '../../features/payments/domain/usecases/payments_usecases.dart';
import '../../features/payments/presentation/bloc/payments_bloc.dart';
import '../../features/banners/data/datasources/banners_datasource.dart';
import '../../features/banners/data/repositories/banners_repository_impl.dart';
import '../../features/banners/domain/repositories/banners_repository.dart';
import '../../features/banners/domain/usecases/banners_usecases.dart';
import '../../features/banners/presentation/bloc/banners_bloc.dart';
import '../../features/notifications/data/datasources/notifications_datasource.dart';
import '../../features/notifications/data/repositories/notifications_repository_impl.dart';
import '../../features/notifications/domain/repositories/notifications_repository.dart';
import '../../features/notifications/domain/usecases/notifications_usecases.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/discount_codes/data/datasources/discount_datasource.dart';
import '../../features/discount_codes/data/repositories/discount_repository_impl.dart';
import '../../features/discount_codes/domain/repositories/discount_repository.dart';
import '../../features/discount_codes/domain/usecases/discount_usecases.dart';
import '../../features/discount_codes/presentation/bloc/discount_bloc.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../features/admin_users/data/datasources/admin_users_datasource.dart';
import '../../features/admin_users/data/repositories/admin_users_repository_impl.dart';
import '../../features/admin_users/domain/repositories/admin_users_repository.dart';
import '../../features/admin_users/domain/usecases/admin_users_usecases.dart';
import '../../features/admin_users/presentation/bloc/admin_users_bloc.dart';
import '../../features/services/data/datasources/services_datasource.dart';
import '../../features/services/data/repositories/services_repository_impl.dart';
import '../../features/services/domain/repositories/services_repository.dart';
import '../../features/services/domain/usecases/services_usecases.dart';
import '../../features/services/presentation/bloc/services_bloc.dart';
import '../../features/plans/data/datasources/plans_datasource.dart';
import '../../features/plans/data/repositories/plans_repository_impl.dart';
import '../../features/plans/domain/repositories/plans_repository.dart';
import '../../features/plans/domain/usecases/plans_usecases.dart';
import '../../features/plans/presentation/bloc/plans_bloc.dart';

final sl = GetIt.instance;

Future<void> setupDI() async {
  // ── Firebase ────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);

  // ── Auth ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthDataSourceImpl(auth: sl(), db: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton(() => SignInAdmin(sl()));
  sl.registerLazySingleton(() => GetCurrentAdmin(sl()));
  sl.registerLazySingleton(() => SignOutAdmin(sl()));

  sl.registerFactory(
    () => AuthBloc(signIn: sl(), getAdmin: sl(), signOut: sl()),
  );

  // ── Overview ────────────────────────────────────────────────────────
  sl.registerLazySingleton<OverviewDataSource>(
    () => OverviewDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<OverviewRepository>(
    () => OverviewRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetOverviewData(sl()));

  sl.registerFactory(() => OverviewBloc(getOverview: sl()));
  // ── Users ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<UsersDataSource>(() => UsersDataSourceImpl(sl()));
  sl.registerLazySingleton<UsersRepository>(() => UsersRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetUsers(sl()));
  sl.registerLazySingleton(() => UpdateUserStatus(sl()));
  sl.registerLazySingleton(() => ExtendSubscription(sl()));

  sl.registerFactory(
    () => UsersBloc(getUsers: sl(), updateStatus: sl(), extendSub: sl()),
  );

  // ── Providers ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ProvidersDataSource>(
    () => ProvidersDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ProvidersRepository>(
    () => ProvidersRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetProviders(sl()));
  sl.registerLazySingleton(() => AddProvider(sl()));
  sl.registerLazySingleton(() => UpdateProvider(sl()));
  sl.registerLazySingleton(() => ToggleProviderStatus(sl()));
  sl.registerLazySingleton(() => DeleteProvider(sl()));

  sl.registerFactory(
    () => ProvidersBloc(
      get: sl(),
      add: sl(),
      update: sl(),
      toggle: sl(),
      delete: sl(),
    ),
  );
  // ── Payments ────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PaymentsDataSource>(
    () => PaymentsDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<PaymentsRepository>(
    () => PaymentsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetPayments(sl()));
  sl.registerLazySingleton(() => GetPaymentSummary(sl()));
  sl.registerLazySingleton(() => SearchPayments(sl()));
  sl.registerLazySingleton(() => ExportPaymentsCsv(sl()));

  sl.registerFactory(
    () => PaymentsBloc(get: sl(), getSummary: sl(), search: sl(), export: sl()),
  );

  // ── Banners ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<BannersDataSource>(
    () => BannersDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<BannersRepository>(
    () => BannersRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetBanners(sl()));
  sl.registerLazySingleton(() => AddBanner(sl()));
  sl.registerLazySingleton(() => UpdateBanner(sl()));
  sl.registerLazySingleton(() => ToggleBannerStatus(sl()));
  sl.registerLazySingleton(() => DeleteBanner(sl()));
  sl.registerLazySingleton(() => ReorderBanners(sl()));

  sl.registerFactory(
    () => BannersBloc(
      reorder: sl(),
      get: sl(),
      add: sl(),
      update: sl(),
      toggle: sl(),
      delete: sl(),
    ),
  );
  // Firebase Functions
  sl.registerLazySingleton(() => FirebaseFunctions.instance);

  // ── Notifications ──────────────────────────────────────────────────────
  sl.registerLazySingleton<NotificationsDataSource>(
    () => NotificationsDataSourceImpl(db: sl(), functions: sl()),
  );
  sl.registerLazySingleton<NotificationsRepository>(
    () => NotificationsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetNotificationHistory(sl()));
  sl.registerLazySingleton(() => SendNotification(sl()));
  sl.registerLazySingleton(() => SendExpiryReminders(sl()));
  sl.registerLazySingleton(() => DeleteNotification(sl()));
  sl.registerLazySingleton(() => ClearAllNotifications(sl()));

  sl.registerFactory(
    () => NotificationsBloc(
      getHistory: sl(),
      send: sl(),
      sendExpiry: sl(),
      delete: sl(),
      clearAll: sl(),
    ),
  );

  // ── Discount Codes ─────────────────────────────────────────────────────
  sl.registerLazySingleton<DiscountDataSource>(
    () => DiscountDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<DiscountRepository>(
    () => DiscountRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetDiscountCodes(sl()));
  sl.registerLazySingleton(() => CreateDiscountCode(sl()));
  sl.registerLazySingleton(() => UpdateDiscountCode(sl()));
  sl.registerLazySingleton(() => ToggleDiscountCode(sl()));
  sl.registerLazySingleton(() => DeleteDiscountCode(sl()));

  sl.registerFactory(
    () => DiscountBloc(get: sl(), create: sl(), toggle: sl(), delete: sl()),
  );
  // ============================================
  // Admin Users Feature
  // ============================================
  sl.registerLazySingleton<AdminUsersDataSource>(
    () => AdminUsersDataSourceImpl(db: sl(), auth: sl()),
  );

  sl.registerLazySingleton<AdminUsersRepository>(
    () => AdminUsersRepositoryImpl(sl()),
  );

  sl.registerFactory(() => GetAdminUsers(sl()));
  sl.registerFactory(() => CreateAdminUser(sl()));
  sl.registerFactory(() => UpdateAdminRole(sl()));
  sl.registerFactory(() => UpdateAdminPermissions(sl())); // ✅ New
  sl.registerFactory(() => ToggleAdminStatus(sl()));
  sl.registerFactory(() => DeleteAdminUser(sl()));

  sl.registerFactory(
    () => AdminUsersBloc(
      get: sl(),
      create: sl(),
      updateRole: sl(),
      updatePermissions: sl(), // ✅ New
      toggle: sl(),
      delete: sl(),
    ),
  );
  // ── Services ──────────────────────────────────────────────────────────
  sl.registerLazySingleton<ServicesDataSource>(
    () => ServicesDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ServicesRepository>(
    () => ServicesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetServices(sl()));
  sl.registerLazySingleton(() => AddService(sl()));
  sl.registerLazySingleton(() => UpdateService(sl()));
  sl.registerLazySingleton(() => ToggleService(sl()));
  sl.registerLazySingleton(() => DeleteService(sl()));

  sl.registerFactory(
    () => ServicesBloc(
      get: sl(),
      add: sl(),
      update: sl(),
      toggle: sl(),
      delete: sl(),
    ),
  );

  // ── Plans ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton<PlansDataSource>(() => PlansDataSourceImpl(sl()));
  sl.registerLazySingleton<PlansRepository>(() => PlansRepositoryImpl(sl()));
  sl.registerLazySingleton(() => GetPlansAdmin(sl()));
  sl.registerLazySingleton(() => AddPlan(sl()));
  sl.registerLazySingleton(() => UpdatePlan(sl()));
  sl.registerLazySingleton(() => TogglePlan(sl()));
  sl.registerLazySingleton(() => DeletePlan(sl()));

  sl.registerFactory(
    () => PlansBloc(
      get: sl(),
      add: sl(),
      update: sl(),
      toggle: sl(),
      delete: sl(),
    ),
  );
}
