import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/story_model.dart';

class StoryViewer extends StatefulWidget {
  final List<Story> stories;
  final int initialIndex;
  const StoryViewer({super.key, required this.stories, required this.initialIndex});
  @override
  State<StoryViewer> createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  late PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.stories.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final story = widget.stories[index];
          return Stack(
            children: [
              Center(
                child: story.type == 'video'
                    ? const Icon(Icons.play_circle_filled, size: 80, color: Colors.white)
                    : CachedNetworkImage(imageUrl: story.mediaUrl, fit: BoxFit.contain),
              ),
              Positioned(
                top: 40,
                left: 16,
                right: 16,
                child: Row(
                  children: [
                    CircleAvatar(radius: 20, backgroundImage: story.user?.avatarUrl != null ? NetworkImage(story.user!.avatarUrl!) : null),
                    const SizedBox(width: 8),
                    Text(story.user?.displayName ?? 'User', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${story.viewCount ?? 0} views', style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
                    const SizedBox(width: 16),
                    IconButton(icon: const Icon(Icons.send, color: Colors.white), onPressed: () {}),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}