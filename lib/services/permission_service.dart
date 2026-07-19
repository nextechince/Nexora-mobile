import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isRestricted) {
      final images = await Permission.photos.request();
      final videos = await Permission.videos.request();
      final audio = await Permission.audio.request();
      return images.isGranted || videos.isGranted || audio.isGranted;
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  Future<bool> checkStoragePermission() async {
    if (await Permission.storage.isRestricted) {
      final images = await Permission.photos.status;
      final videos = await Permission.videos.status;
      final audio = await Permission.audio.status;
      return images.isGranted || videos.isGranted || audio.isGranted;
    } else {
      final status = await Permission.storage.status;
      return status.isGranted;
    }
  }

  Future<bool> requestContactsPermission() async {
    final status = await Permission.contacts.request();
    return status.isGranted;
  }

  Future<bool> checkContactsPermission() async {
    final status = await Permission.contacts.status;
    return status.isGranted;
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> checkLocationPermission() async {
    final status = await Permission.locationWhenInUse.status;
    return status.isGranted;
  }

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> checkNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  Future<bool> requestAllPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
      Permission.contacts,
      Permission.locationWhenInUse,
      Permission.notification,
    ];
    final results = await permissions.request();
    return results.values.every((status) => status.isGranted);
  }

  Future<void> openAppSettings() async {
    await openAppSettings();
  }

  Future<bool> showPermissionRationale(
    BuildContext context,
    String title,
    String message,
  ) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    ) ?? false;
  }
}