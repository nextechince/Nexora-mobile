import 'dart:io';
import 'package:screen_recorder/screen_recorder.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:path_provider/path_provider.dart';

class ScreenShareService {
  static final ScreenShareService _instance = ScreenShareService._internal();
  factory ScreenShareService() => _instance;
  ScreenShareService._internal();

  bool _isSharing = false;
  String? _screenSharePath;
  RtcEngine? _agoraEngine;

  Future<void> initScreenShare(RtcEngine engine) async {
    _agoraEngine = engine;
    await _agoraEngine!.enableVideo();
    await _agoraEngine!.setVideoEncoderConfiguration(
      VideoEncoderConfiguration(
        dimensions: Size(1920, 1080),
        frameRate: 30,
        bitrate: 2000,
      ),
    );
  }

  Future<void> startScreenShare({
    required String channelName,
  }) async {
    if (_isSharing) return;

    try {
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _screenSharePath = '${directory.path}/screen_share_$timestamp.mp4';
      await ScreenRecorder.startRecording(
        outputPath: _screenSharePath!,
        quality: RecordingQuality.high,
        includeAudio: true,
      );
      await _agoraEngine?.joinChannel(
        token: '',
        channelId: channelName,
        uid: 0,
        options: ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          publishCameraTrack: false,
          publishScreenTrack: true,
          publishAudioTrack: true,
        ),
      );
      _isSharing = true;
    } catch (e) {
      throw Exception('Failed to start screen sharing: $e');
    }
  }

  Future<void> stopScreenShare() async {
    if (!_isSharing) return;
    try {
      await ScreenRecorder.stopRecording();
      await _agoraEngine?.leaveChannel();
      _isSharing = false;
      _screenSharePath = null;
    } catch (e) {
      throw Exception('Failed to stop screen sharing: $e');
    }
  }

  Future<void> pauseScreenShare() async {
    if (!_isSharing) return;
    await ScreenRecorder.pauseRecording();
  }

  Future<void> resumeScreenShare() async {
    if (!_isSharing) return;
    await ScreenRecorder.resumeRecording();
  }

  bool get isSharing => _isSharing;
  String? get screenSharePath => _screenSharePath;

  Future<List<Map<String, dynamic>>> getAvailableWindows() async {
    // Platform-specific implementation
    return [
      {'id': '1', 'name': 'Chrome', 'thumbnail': ''},
      {'id': '2', 'name': 'Visual Studio Code', 'thumbnail': ''},
      {'id': '3', 'name': 'NEXORA CHQT', 'thumbnail': ''},
    ];
  }
}