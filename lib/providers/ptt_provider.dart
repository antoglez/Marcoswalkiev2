import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../models/ptt_profile.dart';

class PTTProvider with ChangeNotifier {
  List<PTTProfile> _profiles = [];
  String? _selectedProfileId;
  bool _isTransmitting = false;
  int? _globalStartKeyCode;
  int? _globalStopKeyCode;

  List<PTTProfile> get profiles => _profiles;
  PTTProfile? get selectedProfile => _profiles.isEmpty 
      ? null 
      : _profiles.firstWhere((p) => p.id == _selectedProfileId, orElse: () => _profiles.first);
  bool get isTransmitting => _isTransmitting;
  int? get globalStartKeyCode => _globalStartKeyCode;
  int? get globalStopKeyCode => _globalStopKeyCode;

  PTTProvider() {
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? profilesJson = prefs.getString('ptt_profiles');
    if (profilesJson != null) {
      final List<dynamic> decoded = jsonDecode(profilesJson);
      _profiles = decoded.map((item) => PTTProfile.fromMap(item)).toList();
    } else {
      // Default sample profiles for testing
      _profiles = [
        PTTProfile(
          id: 'default_walkie',
          name: 'Walkie App (Ejemplo)',
          startAction: 'com.example.PTT_START',
          stopAction: 'com.example.PTT_STOP',
        ),
        PTTProfile(
          id: 'test_browser',
          name: 'Prueba: Abrir Navegador Web',
          startAction: 'android.intent.action.WEB_SEARCH',
          stopAction: 'android.intent.action.WEB_SEARCH',
        ),
        PTTProfile(
          id: 'test_camera',
          name: 'Prueba: Abrir Cámara',
          startAction: 'android.media.action.IMAGE_CAPTURE',
          stopAction: 'android.media.action.IMAGE_CAPTURE',
        ),
        PTTProfile(
          id: 'test_wifi',
          name: 'Prueba: Ajustes Wi-Fi',
          startAction: 'android.settings.WIFI_SETTINGS',
          stopAction: 'android.settings.WIFI_SETTINGS',
        ),
        PTTProfile(
          id: 'test_volume',
          name: 'Prueba: Subir/Bajar Volumen (Pulsador)',
          startAction: 'METHOD_CHANNEL_VOLUME_UP', 
          stopAction: 'METHOD_CHANNEL_VOLUME_DOWN',
        )
      ];
    }
    _selectedProfileId = prefs.getString('selected_profile_id') ?? (_profiles.isNotEmpty ? _profiles.first.id : null);
    _globalStartKeyCode = prefs.getInt('global_start_key_code');
    _globalStopKeyCode = prefs.getInt('global_stop_key_code');
    notifyListeners();
  }

  Future<void> saveProfiles() async {
    final prefs = await SharedPreferences.getInstance();
    final String profilesJson = jsonEncode(_profiles.map((p) => p.toMap()).toList());
    await prefs.setString('ptt_profiles', profilesJson);
    if (_selectedProfileId != null) {
      await prefs.setString('selected_profile_id', _selectedProfileId!);
    }
    if (_globalStartKeyCode != null) {
      await prefs.setInt('global_start_key_code', _globalStartKeyCode!);
    } else {
      await prefs.remove('global_start_key_code');
    }
    if (_globalStopKeyCode != null) {
      await prefs.setInt('global_stop_key_code', _globalStopKeyCode!);
    } else {
      await prefs.remove('global_stop_key_code');
    }
  }

  void selectProfile(String id) {
    _selectedProfileId = id;
    saveProfiles();
    notifyListeners();
  }

  Future<void> addProfile(PTTProfile profile) async {
    _profiles.add(profile);
    await saveProfiles();
    notifyListeners();
  }

  Future<void> updateProfile(PTTProfile updatedProfile) async {
    final index = _profiles.indexWhere((p) => p.id == updatedProfile.id);
    if (index != -1) {
      _profiles[index] = updatedProfile;
      await saveProfiles();
      notifyListeners();
    }
  }

  Future<void> deleteProfile(String id) async {
    _profiles.removeWhere((p) => p.id == id);
    if (_selectedProfileId == id) {
      _selectedProfileId = _profiles.isNotEmpty ? _profiles.first.id : null;
    }
    await saveProfiles();
    notifyListeners();
  }

  Future<void> startTransmission() async {
    if (selectedProfile == null || _isTransmitting) return;
    _isTransmitting = true;
    notifyListeners();
    
    if (selectedProfile!.startAction == 'METHOD_CHANNEL_VOLUME_UP') {
      const channel = MethodChannel('com.pedroia.marcoswalkie/volume');
      try { await channel.invokeMethod('volumeUp'); } catch (_) {}
      return;
    }

    final intent = AndroidIntent(
      action: selectedProfile!.startAction,
      arguments: selectedProfile!.extras,
    );
    try { await intent.launch(); } catch (_) {}
    try { await intent.sendBroadcast(); } catch (_) {}
  }

  Future<void> stopTransmission() async {
    if (selectedProfile == null || !_isTransmitting) return;
    _isTransmitting = false;
    notifyListeners();

    if (selectedProfile!.stopAction == 'METHOD_CHANNEL_VOLUME_DOWN') {
      const channel = MethodChannel('com.pedroia.marcoswalkie/volume');
      try { await channel.invokeMethod('volumeDown'); } catch (_) {}
      return;
    }

    final intent = AndroidIntent(
      action: selectedProfile!.stopAction,
      arguments: selectedProfile!.extras,
    );
    try { await intent.launch(); } catch (_) {}
    try { await intent.sendBroadcast(); } catch (_) {}
  }

  Future<void> setGlobalKeyCodes(int? start, int? stop) async {
    _globalStartKeyCode = start;
    _globalStopKeyCode = stop;
    await saveProfiles();
    notifyListeners();
  }
}
