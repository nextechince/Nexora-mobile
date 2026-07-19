import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/story_service.dart';
import '../models/story_model.dart';

part 'story_provider.g.dart';

@riverpod
Future<List<Story>> stories(Ref ref) async {
  final service = ref.watch(storyServiceProvider);
  return service.getStories();
}

@riverpod
class CreateStory extends _$CreateStory {
  @override
  Future<void> build() async {}

  Future<Story> create({
    required String mediaUrl,
    required String type,
    String? caption,
    int? duration,
  }) async {
    final service = ref.watch(storyServiceProvider);
    return service.createStory(
      mediaUrl: mediaUrl,
      type: type,
      caption: caption,
      duration: duration,
    );
  }
}