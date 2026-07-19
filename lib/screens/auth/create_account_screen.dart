import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});
  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Display Name')),
            const SizedBox(height: 16),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username (optional)')),
            const SizedBox(height: 16),
            TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio (optional)'), maxLines: 2),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _createAccount,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  void _createAccount() async {
    setState(() => _isLoading = true);
    // Simulate creation – in real app, call Supabase to update profile.
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) context.go('/home');
    setState(() => _isLoading = false);
  }
}