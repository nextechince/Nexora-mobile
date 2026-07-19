import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

class GroupVoiceService {
  final SupabaseClient _supabase = Supabase.instance.client;
  late RtcEngine _engine;
  bool _isInCall = false;
  List<int> _participants = [];
  bool _isMuted = false;

  Future<void> initAgora() async {
    _engine = createAgoraRtcEngine();
    await _engine.initialize(RtcEngineContext(appId: Env.agoraAppId));
    _engine.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        _isInCall = true;
        _updateVoiceChatStatus('active');
      },
      onUserJoined: (connection, remoteUid, elapsed) {
        _participants.add(remoteUid);
        _updateParticipants();
      },
      onUserOffline: (connection, remoteUid, reason) {
        _participants.remove(remoteUid);
        _updateParticipants();
      },
      onLeaveChannel: (connection, stats) {
        _isInCall = false;
        _participants.clear();
        _updateVoiceChatStatus('ended');
      },
    ));
  }

  Future<void> startVoiceChat({
    required String groupId,
    required String channelName,
  }) async {
    await _engine.enableAudio();
    await _engine.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
    final user = _supabase.auth.currentUser!;
    await _supabase.from('voice_chats').insert({
      'group_id': groupId,
      'channel_name': channelName,
      'started_by': user.id,
      'status': 'active',
      'started_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> endVoiceChat() async {
    await _engine.leaveChannel();
    _isInCall = false;
  }

  Future<void> toggleMute() async {
    _isMuted = !_isMuted;
    await _engine.muteLocalAudioStream(_isMuted);
  }

  Future<List<Map<String, dynamic>>> getActiveVoiceChats() async {
    final data = await _supabase
        .from('voice_chats')
        .select('*, groups(*), users!started_by(*)')
        .eq('status', 'active')
        .order('started_at', ascending: false);
    return data;
  }

  Future<void> joinVoiceChat(String channelName) async {
    await _engine.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: ChannelMediaOptions(),
    );
  }

  void _updateVoiceChatStatus(String status) {}
  void _updateParticipants() {}

  Stream<List<Map<String, dynamic>>> watchVoiceChat(String groupId) {
    return _supabase
        .from('voice_chats')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId);
  }
}