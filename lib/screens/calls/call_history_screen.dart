import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/call_provider.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';

class CallHistoryScreen extends ConsumerWidget {
  const CallHistoryScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callsAsync = ref.watch(callHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Calls')),
      body: callsAsync.when(
        data: (calls) => ListView.builder(
          itemCount: calls.length,
          itemBuilder: (context, index) {
            final call = calls[index];
            return ListTile(
              leading: Icon(call.type == 'video' ? Icons.videocam : Icons.phone, color: call.status == 'missed' ? Colors.red : Colors.green),
              title: Text(call.caller?.displayName ?? 'Unknown'),
              subtitle: Text(call.status ?? ''),
              trailing: Text(call.duration != null ? '${call.duration}s' : ''),
              onTap: () => context.push('/call/${call.id}'),
            );
          },
        ),
        loading: () => const LoadingWidget(),
        error: (err, stack) => const ErrorWidget('Failed to load calls'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/call/new'),
        child: const Icon(Icons.call),
      ),
    );
  }
}