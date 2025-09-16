import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kParamsKey = 'app_params';

final parametrosProvider =
    StateNotifierProvider<ParametrosNotifier, Map<String, dynamic>>(
  (ref) => ParametrosNotifier(),
);

class ParametrosNotifier extends StateNotifier<Map<String, dynamic>> {
  ParametrosNotifier() : super({});

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final jsonStr = sp.getString(_kParamsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      final decoded = jsonDecode(jsonStr);
      state = Map<String, dynamic>.from(decoded);
    } else {
      state = {};
    }
  }

  Future<void> _persist() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kParamsKey, jsonEncode(state));
  }

  Future<void> setParam(String key, dynamic value) async {
    state = {...state, key: value};
    await _persist();
  }

  Future<void> removeParam(String key) async {
    final newState = {...state};
    newState.remove(key);
    state = newState;
    await _persist();
  }

  Future<void> clear() async {
    state = {};
    await _persist();
  }
}
