import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rental_mgr_mobile/core/config/api_url_store.dart';
import 'package:rental_mgr_mobile/core/routing/app_router.dart';
import 'package:rental_mgr_mobile/core/theme/app_theme.dart';
import 'package:rental_mgr_mobile/core/theme/theme_mode_provider.dart';
import 'package:rental_mgr_mobile/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (e, st) {
    debugPrint('Firebase.initializeApp failed: $e\n$st');
  }
  runApp(
    ProviderScope(
      overrides: [],
      child: const _BootstrapApp(),
    ),
  );
}

class _BootstrapApp extends ConsumerStatefulWidget {
  const _BootstrapApp();

  @override
  ConsumerState<_BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends ConsumerState<_BootstrapApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(apiUrlProvider.notifier).ensureLoaded();
      await ref.read(themeModeProvider.notifier).ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    return const RentalMgrApp();
  }
}

class RentalMgrApp extends ConsumerWidget {
  const RentalMgrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themePreference = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          title: 'RentDirect UG',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themePreference.themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
