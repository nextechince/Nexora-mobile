import 'package:permission_handler/permission_handler.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class ContactService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<User>> getAppContacts() async {
    final status = await Permission.contacts.request();
    if (!status.isGranted) return [];

    final Iterable<Contact> contacts = await ContactsService.getContacts(
      withThumbnails: false,
    );

    final List<String> phones = [];
    for (var contact in contacts) {
      for (var item in contact.phones ?? []) {
        final phone = item.value?.replaceAll(RegExp(r'\s+'), '') ?? '';
        if (phone.isNotEmpty) phones.add(phone);
      }
    }

    if (phones.isEmpty) return [];

    final data = await _supabase
        .from('users')
        .select()
        .in_('phone', phones)
        .order('display_name', ascending: true);

    return data.map((json) => User.fromJson(json)).toList();
  }
}