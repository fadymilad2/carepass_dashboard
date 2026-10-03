import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/dashboard_theme.dart';
import 'core/router/dashboard_router.dart';
import 'core/di/injection.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupDI();
  runApp(const CarePassDashboard());
}

class CarePassDashboard extends StatelessWidget {
  const CarePassDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (_) => sl<AuthBloc>())],
      child: MaterialApp.router(
        title: 'CarePass Admin',
        debugShowCheckedModeBanner: false,
        theme: DashboardTheme.theme,
        routerConfig: dashboardRouter,
      ),
    );
  }
}
