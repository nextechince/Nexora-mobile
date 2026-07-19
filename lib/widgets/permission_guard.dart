import 'package:flutter/material.dart';
import '../services/permission_service.dart';

enum PermissionType { camera, microphone, storage, contacts, location, notification }

class PermissionGuard extends StatefulWidget {
  final Widget child; final PermissionType permission; final String title; final String message; final VoidCallback onGranted;
  const PermissionGuard({super.key, required this.child, required this.permission, required this.title, required this.message, required this.onGranted});
  @override State<PermissionGuard> createState() => _PermissionGuardState();
}

class _PermissionGuardState extends State<PermissionGuard> {
  final PermissionService _permService = PermissionService(); bool _hasPermission = false;
  @override void initState() { super.initState(); _checkPermission(); }
  Future<void> _checkPermission() async { bool granted; switch(widget.permission) { case PermissionType.camera: granted = await _permService.checkCameraPermission(); break; ... } setState(() => _hasPermission = granted); }
  Future<void> _requestPermission() async { bool granted; switch(widget.permission) { ... } setState(() => _hasPermission = granted); if (granted) widget.onGranted(); }
  @override Widget build(BuildContext context) { if (_hasPermission) return widget.child; return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.lock_outline, size: 64, color: Colors.grey.shade600), const SizedBox(height: 16), Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(widget.message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)), const SizedBox(height: 24), ElevatedButton.icon(onPressed: _requestPermission, icon: const Icon(Icons.check_circle), label: const Text('Grant Permission')), const SizedBox(height: 12), TextButton(onPressed: () => _permService.openAppSettings(), child: const Text('Open Settings'))])); }
}