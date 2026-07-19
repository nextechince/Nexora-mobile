import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class PhoneLoginScreen extends ConsumerStatefulWidget {
  const PhoneLoginScreen({super.key});
  @override
  ConsumerState<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends ConsumerState<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+1';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.go('/onboarding'))),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter your phone number', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('We will send you a verification code', style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            Row(
              children: [
                CountryCodePicker(onChanged: (country) { _countryCode = country.dialCode!; }, initialSelection: 'US', showCountryOnly: false, showOnlyCountryWhenClosed: false, alignLeft: false),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(hintText: 'Phone number', hintStyle: TextStyle(color: Colors.white54), border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24))),
                  ),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendOTP,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOTP() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) return;
    final fullNumber = '$_countryCode$phone';
    setState(() => _isLoading = true);
    try {
      await ref.read(authStateProvider.notifier).signInWithPhone(fullNumber);
      if (mounted) context.go('/auth/otp', extra: fullNumber);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally { setState(() => _isLoading = false); }
  }
}