import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class StreamingService {
  final SupabaseClient _supabase = Supabase.instance.client;
  late RtcEngine _engine;
  bool _isStreaming = false;

  Future<void> initAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: Env.agoraAppId));
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        _isStreaming = true;
      },
      onUserJoined: (connection, remoteUid, elapsed) {},
      onUserOffline: (connection, remoteUid, reason) {},
    ));
  }

  Future<void> startStream({
    required String channelName,
    required String streamTitle,
  }) async {
    await _engine.enableVideo();
    await _engine.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
    final user = _supabase.auth.currentUser!;
    await _supabase.from('live_streams').insert({
      'user_id': user.id,
      'channel_name': channelName,
      'title': streamTitle,
      'status': 'live',
      'started_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> endStream() async {
    await _engine.leaveChannel();
    _isStreaming = false;
  }

  Future<void> toggleCamera() async {
    await _engine.muteLocalVideoStream(!_engine.isLocalVideoMuted());
  }

  Future<void> toggleMicrophone() async {
    await _engine.muteLocalAudioStream(!_engine.isLocalAudioMuted());
  }

  Future<void> switchCamera() async {
    await _engine.switchCamera();
  }
}