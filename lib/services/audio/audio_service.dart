import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing sound effects and optional ambient background music.
class AudioService with WidgetsBindingObserver {
  AudioService({
    AudioPlayer? sfxPlayer,
    AudioPlayer? musicPlayer,
    this.enableNativePlayback = true,
  }) {
    _sfxPlayer = sfxPlayer;
    _musicPlayer = musicPlayer;
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  /// Whether actual platform audio playback is enabled.
  /// Set to false in headless tests.
  final bool enableNativePlayback;

  static const String _prefSfxEnabled = 'audio_sfx_enabled';
  static const String _prefMusicEnabled = 'audio_music_enabled';
  static const String _prefSfxVolume = 'audio_sfx_volume';
  static const String _prefMusicVolume = 'audio_music_volume';

  AudioPlayer? _sfxPlayer;
  AudioPlayer? _musicPlayer;

  AudioPlayer get sfxPlayer => _sfxPlayer ??= AudioPlayer();
  AudioPlayer get musicPlayer => _musicPlayer ??= AudioPlayer();

  bool _sfxEnabled = true;
  bool _musicEnabled = false;
  double _sfxVolume = 0.7;
  double _musicVolume = 0.5;
  bool _isMusicPlaying = false;
  bool _appInBackground = false;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;

  final ValueNotifier<bool> sfxEnabledNotifier = ValueNotifier(true);
  final ValueNotifier<bool> musicEnabledNotifier = ValueNotifier(false);
  final ValueNotifier<double> sfxVolumeNotifier = ValueNotifier(0.7);
  final ValueNotifier<double> musicVolumeNotifier = ValueNotifier(0.5);

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _sfxEnabled = prefs.getBool(_prefSfxEnabled) ?? true;
      _musicEnabled = prefs.getBool(_prefMusicEnabled) ?? false;
      _sfxVolume = prefs.getDouble(_prefSfxVolume) ?? 0.7;
      _musicVolume = prefs.getDouble(_prefMusicVolume) ?? 0.5;

      sfxEnabledNotifier.value = _sfxEnabled;
      musicEnabledNotifier.value = _musicEnabled;
      sfxVolumeNotifier.value = _sfxVolume;
      musicVolumeNotifier.value = _musicVolume;

      if (enableNativePlayback && _musicEnabled && !_appInBackground) {
        await _startMusic();
      }
    } catch (e) {
      debugPrint('AudioService init error: $e');
    }
  }

  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    sfxEnabledNotifier.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefSfxEnabled, enabled);
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    musicEnabledNotifier.value = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefMusicEnabled, enabled);

    if (enabled) {
      if (!_appInBackground && !_isMusicPlaying) {
        await _startMusic();
      }
    } else {
      await _stopMusic();
    }
  }

  Future<void> setSfxVolume(double volume) async {
    _sfxVolume = volume.clamp(0.0, 1.0);
    sfxVolumeNotifier.value = _sfxVolume;
    if (enableNativePlayback && _sfxPlayer != null) {
      try {
        await _sfxPlayer!.setVolume(_sfxVolume);
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefSfxVolume, _sfxVolume);
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    musicVolumeNotifier.value = _musicVolume;
    if (enableNativePlayback && _musicPlayer != null) {
      try {
        await _musicPlayer!.setVolume(_musicVolume);
      } catch (_) {}
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_prefMusicVolume, _musicVolume);
  }

  Future<void> _startMusic() async {
    if (!enableNativePlayback || !_musicEnabled || _appInBackground) return;
    try {
      await musicPlayer.setVolume(_musicVolume);
      await musicPlayer.setReleaseMode(ReleaseMode.loop);
      await musicPlayer.play(AssetSource('audio/ambient_loop.wav'));
      _isMusicPlaying = true;
    } catch (e) {
      debugPrint('Music play error: $e');
    }
  }

  Future<void> _stopMusic() async {
    if (!enableNativePlayback || _musicPlayer == null) return;
    try {
      await _musicPlayer!.stop();
      _isMusicPlaying = false;
    } catch (e) {
      debugPrint('Music stop error: $e');
    }
  }

  Future<void> _playSfx(String assetPath) async {
    if (!enableNativePlayback || !_sfxEnabled) return;
    try {
      await sfxPlayer.setVolume(_sfxVolume);
      await sfxPlayer.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
    } catch (e) {
      debugPrint('SFX play error ($assetPath): $e');
    }
  }

  void playTap() => _playSfx('audio/button_tap.wav');
  void playVillageSwitch() => _playSfx('audio/village_switch.wav');
  void playUpgradeStart() => _playSfx('audio/upgrade_start.wav');
  void playUpgradeComplete() => _playSfx('audio/upgrade_complete.wav');
  void playItemAdd() => _playSfx('audio/item_add.wav');
  void playConfirm() => _playSfx('audio/confirm.wav');
  void playError() => _playSfx('audio/error.wav');

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _appInBackground = true;
      if (_isMusicPlaying && _musicPlayer != null) {
        _musicPlayer!.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      _appInBackground = false;
      if (_musicEnabled) {
        if (_isMusicPlaying && _musicPlayer != null) {
          _musicPlayer!.resume();
        } else {
          _startMusic();
        }
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sfxPlayer?.dispose();
    _musicPlayer?.dispose();
    sfxEnabledNotifier.dispose();
    musicEnabledNotifier.dispose();
    sfxVolumeNotifier.dispose();
    musicVolumeNotifier.dispose();
  }
}
