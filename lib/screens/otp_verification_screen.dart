import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/pin_code_field.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});
  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _phone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _phone = ModalRoute.of(context)?.settings.arguments as String?;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.go('/auth/login'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Verification', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Enter the 6-digit code sent to $_phone', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            PinCodeField(controller: _otpController, length: 6, onCompleted: (code) => _verifyOTP(code)),
            const SizedBox(height: 20),
            TextButton(onPressed: () {}, child: const Text('Resend Code', style: TextStyle(color: Colors.blue))),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _verifyOTP(_otpController.text),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _verifyOTP(String otp) async {
    if (otp.length != 6 || _phone == null) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).verifyOTP(_phone!, otp);
      if (mounted) context.go('/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP: $e')));
    } finally { setState(() => _isLoading = false); }
  }
}