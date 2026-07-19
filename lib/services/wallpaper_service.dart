import 'package:hive_flutter/hive_flutter.dart';

class WallpaperService {
  late Box _wallpaperBox;

  Future<void> init() async {
    _wallpaperBox = await Hive.openBox('wallpapers');
  }

  String? getChatWallpaper(String chatId) {
    return _wallpaperBox.get(chatId);
  }

  Future<void> setChatWallpaper(String chatId, String wallpaperUrl) async {
    await _wallpaperBox.put(chatId, wallpaperUrl);
  }

  List<Map<String, dynamic>> getDefaultWallpapers() {
    return [
      {'name': 'Ocean Blue', 'color': '#1a237e', 'gradient': true},
      {'name': 'Midnight', 'color': '#0d0d0d', 'gradient': false},
      {'name': 'Sunset', 'color': '#ff6f00', 'gradient': true},
      {'name': 'Forest Green', 'color': '#1b5e20', 'gradient': true},
      {'name': 'Purple Haze', 'color': '#4a148c', 'gradient': true},
      {'name': 'Red Alert', 'color': '#b71c1c', 'gradient': true},
      {'name': 'Pure Black', 'color': '#000000', 'gradient': false},
      {'name': 'White Clean', 'color': '#ffffff', 'gradient': false},
    ];
  }

  List<Map<String, dynamic>> getPremiumWallpapers() {
    return [
      {'name': 'Animated Galaxy', 'type': 'animated', 'asset': 'assets/wallpapers/galaxy.json'},
      {'name': 'Neon City', 'type': 'animated', 'asset': 'assets/wallpapers/neon.json'},
      {'name': 'Waterfall', 'type': 'video', 'asset': 'assets/wallpapers/waterfall.mp4'},
      {'name': 'Fireworks', 'type': 'animated', 'asset': 'assets/wallpapers/fireworks.json'},
    ];
  }

  List<Color> generateGradient(int index) {
    final gradients = [
      [Colors.blue.shade900, Colors.purple.shade900],
      [Colors.orange.shade900, Colors.red.shade900],
      [Colors.green.shade900, Colors.teal.shade900],
      [Colors.pink.shade900, Colors.purple.shade900],
      [Colors.amber.shade900, Colors.orange.shade900],
    ];
    final gradient = gradients[index % gradients.length];
    return gradient;
  }
}