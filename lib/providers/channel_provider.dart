import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/channel_service.dart';
import '../models/channel_model.dart';

part 'channel_provider.g.dart';

@riverpod
Future<List<Channel>> channelList(Ref ref) async {
  final service = ref.watch(channelServiceProvider);
  return service.getChannels();
}

@riverpod
Future<Channel> channelDetail(Ref ref, String channelId) async {
  final service = ref.watch(channelServiceProvider);
  return service.getChannel(channelId);
}

@riverpod
class CreateChannel extends _$CreateChannel {
  @override
  Future<void> build() async {}

  Future<Channel> create({
    required String title,
    required bool isPublic,
    String? description,
    String? photoUrl,
  }) async {
    final service = ref.watch(channelServiceProvider);
    return service.createChannel(
      title: title,
      isPublic: isPublic,
      description: description,
      photoUrl: photoUrl,
    );
  }
}