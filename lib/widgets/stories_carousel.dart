import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/story_provider.dart';
import '../../screens/stories/story_viewer.dart';

class StoriesCarousel extends ConsumerWidget {
  const StoriesCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storiesAsync = ref.watch(storiesProvider);

    return storiesAsync.when(
      data: (stories) {
        if (stories.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryViewer(stories: stories, initialIndex: index),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundImage: NetworkImage(story.mediaUrl),
                    backgroundColor: Colors.grey.shade800,
                    child: story.type == 'video'
                        ? const Icon(Icons.play_arrow, color: Colors.white)
                        : null,
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}