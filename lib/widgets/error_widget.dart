import 'package:flutter/material.dart';

class ErrorWidget extends StatelessWidget {
  final String message;
  const ErrorWidget(this.message, {super.key});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 12),
          Text('Something went wrong', style: TextStyle(color: Colors.white70, fontSize: 18)),
          Text(message, style: TextStyle(color: Colors.white54, fontSize: 14), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: () {}, child: const Text('Retry')),
        ],
      ),
    );
  }
}