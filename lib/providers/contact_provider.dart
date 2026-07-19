import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/contact_service.dart';
import '../models/user_model.dart';

part 'contact_provider.g.dart';

@riverpod
Future<List<User>> contacts(Ref ref) async {
  final service = ref.watch(contactServiceProvider);
  return service.getAppContacts();
}