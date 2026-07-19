import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;
  final List<Map<String, String>> _pages = [
    {'title': 'Welcome to NEXORA CHQT', 'description': 'The most premium messaging experience.', 'image': 'assets/images/onboarding1.png'},
    {'title': 'Chat, Call, Share', 'description': 'Private chats, groups, channels, and stories.', 'image': 'assets/images/onboarding2.png'},
    {'title': 'Premium Features', 'description': 'Unlock exclusive themes, stickers, and more.', 'image': 'assets/images/onboarding3.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                final page = _pages[index];
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(page['image']!, height: 300),
                      const SizedBox(height: 40),
                      Text(page['title']!, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(page['description']!, style: const TextStyle(fontSize: 16, color: Colors.white70), textAlign: TextAlign.center),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(onPressed: () => context.go('/auth/login'), child: const Text('Skip', style: TextStyle(color: Colors.white70))),
                Row(
                  children: List.generate(_pages.length, (index) {
                    return Container(margin: const EdgeInsets.symmetric(horizontal: 4), width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: _currentPage == index ? Colors.blue : Colors.white24));
                  }),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) context.go('/auth/login');
                    else _controller.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                  child: Text(_currentPage == _pages.length - 1 ? 'Get Started' : 'Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}