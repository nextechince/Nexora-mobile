import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/call_model.dart';
import '../config/env.dart';

class CallService {
  final SupabaseClient _supabase = Supabase.instance.client;
  late RtcEngine _engine;
  bool _isJoined = false;

  Future<void> initAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(appId: Env.agoraAppId),
    );
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        _isJoined = true;
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        // handle remote user
      },
      onUserOffline: (connection, remoteUid, reason) {
        // handle offline
      },
    ));
  }

  Future<void> startCall({
    required String channelName,
    required String calleeId,
    required String type,
  }) async {
    await _engine.enableVideo();
    await _engine.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
    final user = _supabase.auth.currentUser!;
    await _supabase.from('calls').insert({
      'caller_id': user.id,
      'callee_id': calleeId,
      'type': type,
      'status': 'initiated',
      'started_at': DateTime.now().toIso8601String(),
      'call_sid': channelName,
    });
  }

  Future<void> endCall() async {
    await _engine.leaveChannel();
    _isJoined = false;
  }

  Future<void> toggleMute() async {
    await _engine.muteLocalAudioStream(!_engine.isLocalAudioMuted());
  }

  Future<void> toggleCamera() async {
    await _engine.muteLocalVideoStream(!_engine.isLocalVideoMuted());
  }

  Future<List<Call>> getCallHistory() async {
    final user = _supabase.auth.currentUser!;
    final data = await _supabase
        .from('calls')
        .select('*, users!caller_id(*), users!callee_id(*)')
        .or('caller_id.eq.$user.id,callee_id.eq.$user.id')
        .order('started_at', ascending: false);
    return data.map((json) => Call.fromJson(json)).toList();
  }
}