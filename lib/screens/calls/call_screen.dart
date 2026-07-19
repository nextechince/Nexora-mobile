import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/call_service.dart';
import '../../widgets/loading_widget.dart';

class CallScreen extends ConsumerStatefulWidget {
  final String callId;
  const CallScreen({super.key, required this.callId});
  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  bool _isMuted = false;
  bool _isVideoOn = false;
  bool _isSpeakerOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const CircleAvatar(radius: 60, child: Icon(Icons.person, size: 60)),
            const SizedBox(height: 16),
            const Text('Calling...', style: TextStyle(fontSize: 24, color: Colors.white)),
            const SizedBox(height: 8),
            const Text('User Name', style: TextStyle(fontSize: 18, color: Colors.white70)),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.mic_off, 'Mute', () => setState(() => _isMuted = !_isMuted), _isMuted ? Colors.red : Colors.white),
                _buildActionButton(Icons.volume_up, 'Speaker', () => setState(() => _isSpeakerOn = !_isSpeakerOn), _isSpeakerOn ? Colors.blue : Colors.white),
                _buildActionButton(Icons.videocam_off, 'Video', () => setState(() => _isVideoOn = !_isVideoOn), _isVideoOn ? Colors.white : Colors.red),
                _buildActionButton(Icons.call_end, 'End', () => context.pop(), Colors.red),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap, Color color) {
    return Column(
      children: [
        IconButton(icon: Icon(icon, color: color), onPressed: onTap, iconSize: 32),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ],
    );
  }
}