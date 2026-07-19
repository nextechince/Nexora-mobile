import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }
  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      final isLoggedIn = ref.read(isLoggedInProvider);
      if (isLoggedIn) context.go('/home');
      else context.go('/onboarding');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.blue.shade900.withOpacity(0.5), blurRadius: 120, spreadRadius: 60)],
              ),
            ),
            Image.asset('assets/images/nexora_logo.png', width: 200, height: 200)
            const Positioned(
              bottom: 80,
              child: Text('NEXORA CHQT', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4, shadows: [Shadow(color: Colors.blue, blurRadius: 20)])),
            ),
          ],
        ),
      ),
    );
  }
}