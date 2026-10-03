import 'package:carepass_dashboard/features/admin_users/presentation/bloc/admin_users_bloc.dart';
import 'package:carepass_dashboard/features/banners/presentation/bloc/banners_bloc.dart';
import 'package:carepass_dashboard/features/discount_codes/presentation/bloc/discount_bloc.dart';
import 'package:carepass_dashboard/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:carepass_dashboard/features/payments/presentation/bloc/payments_bloc.dart';
import 'package:carepass_dashboard/features/plans/presentation/bloc/plans_bloc.dart';
import 'package:carepass_dashboard/features/providers/presentation/bloc/providers_bloc.dart';
import 'package:carepass_dashboard/features/services/presentation/bloc/services_bloc.dart';
import 'package:carepass_dashboard/features/users/presentation/bloc/users_bloc.dart';
import 'package:carepass_dashboard/features/overview/presentation/bloc/overview_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../di/injection.dart';

/// Owns feature caches only while an administrator session is verified.
class DashboardFeatureScope extends StatelessWidget {
  final Widget child;
  const DashboardFeatureScope({super.key, required this.child});
  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<OverviewBloc>()),
      BlocProvider(create: (_) => sl<UsersBloc>()),
      BlocProvider(create: (_) => sl<ProvidersBloc>()),
      BlocProvider(create: (_) => sl<PaymentsBloc>()),
      BlocProvider(create: (_) => sl<BannersBloc>()),
      BlocProvider(create: (_) => sl<NotificationsBloc>()),
      BlocProvider(create: (_) => sl<DiscountBloc>()),
      BlocProvider(create: (_) => sl<AdminUsersBloc>()),
      BlocProvider(create: (_) => sl<ServicesBloc>()),
      BlocProvider(create: (_) => sl<PlansBloc>()),
    ],
    child: child,
  );
}
