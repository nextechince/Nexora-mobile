import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../services/i18n_service.dart';

part 'i18n_provider.g.dart';

@riverpod
I18nService i18nService(Ref ref) {
  return I18nService();
}

@riverpod
class CurrentLanguage extends _$CurrentLanguage {
  @override
  String build() {
    return ref.watch(i18nServiceProvider).currentLanguage;
  }
}