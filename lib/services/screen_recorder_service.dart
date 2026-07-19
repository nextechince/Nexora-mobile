import 'dart:io';
import 'package:screen_recorder/screen_recorder.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:path_provider/path_provider.dart';

class ScreenRecorderService {
  final FlutterFFmpeg _ffmpeg = FlutterFFmpeg();
  String? _currentRecordingPath;
  bool _isRecording = false;

  Future<String> startRecording() async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    _currentRecordingPath = '${directory.path}/recording_$timestamp.mp4';
    await ScreenRecorder.startRecording(
      outputPath: _currentRecordingPath!,
      quality: RecordingQuality.high,
    );
    _isRecording = true;
    return _currentRecordingPath!;
  }

  Future<String> stopRecording() async {
    if (!_isRecording) throw Exception('No recording in progress');
    await ScreenRecorder.stopRecording();
    _isRecording = false;
    return _currentRecordingPath!;
  }

  Future<String> editVideo({
    required String inputPath,
    int? startTime,
    int? duration,
    int? cropWidth,
    int? cropHeight,
    String? filter,
    String? outputPath,
  }) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    outputPath ??= '${directory.path}/edited_$timestamp.mp4';

    List<String> commands = ['-i', inputPath];
    if (startTime != null) commands.addAll(['-ss', startTime.toString()]);
    if (duration != null) commands.addAll(['-t', duration.toString()]);
    if (cropWidth != null && cropHeight != null) {
      commands.addAll(['-vf', 'crop=$cropWidth:$cropHeight']);
    }
    if (filter != null) commands.addAll(['-vf', filter]);
    commands.add(outputPath);

    await _ffmpeg.executeWithArguments(commands);
    return outputPath;
  }

  Future<String> addAudioOverlay({
    required String videoPath,
    required String audioPath,
    double volume = 0.5,
  }) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/audio_overlay_$timestamp.mp4';

    final commands = [
      '-i', videoPath,
      '-i', audioPath,
      '-filter_complex', '[1:a]adelay=0|0,volume=$volume[a1];[0:a][a1]amix=inputs=2:duration=first',
      '-c:v', 'copy',
      outputPath,
    ];

    await _ffmpeg.executeWithArguments(commands);
    return outputPath;
  }

  Future<String> addTextOverlay({
    required String videoPath,
    required String text,
    String fontColor = 'white',
    int fontSize = 24,
    int x = 10,
    int y = 10,
  }) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/text_overlay_$timestamp.mp4';

    final commands = [
      '-i', videoPath,
      '-vf', 'drawtext=text=\'$text\':fontcolor=$fontColor:fontsize=$fontSize:x=$x:y=$y',
      '-c:a', 'copy',
      outputPath,
    ];

    await _ffmpeg.executeWithArguments(commands);
    return outputPath;
  }

  Future<String> compressVideo(String inputPath) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/compressed_$timestamp.mp4';

    final commands = [
      '-i', inputPath,
      '-vcodec', 'libx264',
      '-crf', '28',
      '-preset', 'fast',
      '-acodec', 'copy',
      outputPath,
    ];

    await _ffmpeg.executeWithArguments(commands);
    return outputPath;
  }

  Future<String> generateThumbnail(String videoPath, int time) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final outputPath = '${directory.path}/thumbnail_$timestamp.jpg';

    final commands = [
      '-i', videoPath,
      '-ss', time.toString(),
      '-vframes', '1',
      outputPath,
    ];

    await _ffmpeg.executeWithArguments(commands);
    return outputPath;
  }

  Future<Map<String, dynamic>> getVideoInfo(String videoPath) async {
    final info = await _ffmpeg.getMediaInformation(videoPath);
    return {
      'duration': info['duration'] ?? 0,
      'width': info['streams']?[0]['width'] ?? 0,
      'height': info['streams']?[0]['height'] ?? 0,
      'size': File(videoPath).lengthSync(),
    };
  }
}