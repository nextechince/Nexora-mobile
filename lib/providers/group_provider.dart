import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/group_service.dart';
import '../models/group_model.dart';

part 'group_provider.g.dart';

@riverpod
Future<List<Group>> groupList(Ref ref) async {
  final service = ref.watch(groupServiceProvider);
  return service.getGroups();
}

@riverpod
Future<Group> groupDetail(Ref ref, String groupId) async {
  final service = ref.watch(groupServiceProvider);
  return service.getGroup(groupId);
}

@riverpod
Future<List<Map<String, dynamic>>> groupMembers(Ref ref, String groupId) async {
  final service = ref.watch(groupServiceProvider);
  return service.getGroupMembers(groupId);
}

@riverpod
class CreateGroup extends _$CreateGroup {
  @override
  Future<void> build() async {}

  Future<Group> create({
    required String title,
    List<String>? memberIds,
    String? photoUrl,
  }) async {
    final service = ref.watch(groupServiceProvider);
    return service.createGroup(
      title: title,
      memberIds: memberIds,
      photoUrl: photoUrl,
    );
  }
}