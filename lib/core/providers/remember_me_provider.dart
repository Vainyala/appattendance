import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rememberMeProvider = StateNotifierProvider<RememberMeNotifier, bool>((
  ref,
) {
  return RememberMeNotifier();
});

final savedEmailProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('saved_email');
});

class RememberMeNotifier extends StateNotifier<bool> {
  RememberMeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('remember_me') ?? false;
  }

  Future<void> setRememberMe(bool value, String? email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', value);
    if (value && email != null) {
      await prefs.setString('saved_email', email);
    } else {
      await prefs.remove('saved_email');
    }
    state = value;
  }
}
