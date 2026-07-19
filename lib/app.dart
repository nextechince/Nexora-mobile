import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';

class NexoraApp extends ConsumerStatefulWidget {
  const NexoraApp({super.key});
  @override
  ConsumerState<NexoraApp> createState() => _NexoraAppState();
}

class _NexoraAppState extends ConsumerState<NexoraApp> {
  late final GoRouter _router;
  @override
  void initState() {
    super.initState();
    _router = AppRouter.router(ref);
  }
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'NEXORA CHQT',
      theme: ThemeData.dark().copyWith(extensions: [AppTheme.darkTheme]),
      darkTheme: ThemeData.dark().copyWith(extensions: [AppTheme.darkTheme]),
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}