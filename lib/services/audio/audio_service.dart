import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized service managing reliable sound effects and ambient soundtrack.
class AudioService with WidgetsBindingObserver {
  AudioService({
    this.enableNativePlayback = true,
  }) {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  /// Whether actual platform audio playback is enabled (false in headless tests).
  final bool enableNativePlayback;

  static const String _prefSfxEnabled = 'audio_sfx_enabled';
  static const String _prefMusicEnabled = 'audio_music_enabled';
  static const String _prefSfxVolume = 'audio_sfx_volume';
  static const String _prefMusicVolume = 'audio_music_volume';

  // SFX Player Pool to avoid dropped/interrupted sounds during rapid taps
  static const int _sfxPoolSize = 4;
  final List<AudioPlayer> _sfxPool = [];
  int _sfxPoolIndex = 0;

  AudioPlayer? _musicPlayer;
  bool _sfxEnabled = true;
  bool _musicEnabled = false;
  double _sfxVolume = 0.7;
  double _musicVolume = 0.5;
  bool _isMusicPlaying = false;
  bool _appInBackground = false;
  bool _initialized = false;

  bool get sfxEnabled => _sfxEnabled;
  bool get musicEnabled => _musicEnabled;
  double get sfxVolume => _sfxVolume;
  double get musicVolume => _musicVolume;
  bool get isMusicPlaying => _isMusicPlaying;
  bool get isInitialized => _initialized;

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

      if (enableNativePlayback) {
        _initSfxPool();
        if (_musicEnabled && !_appInBackground) {
          await _startMusic();
        }
      }
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AudioService init error: $e');
      }
    }
  }

  void _initSfxPool() {
    if (!enableNativePlayback) return;
    try {
      for (int i = 0; i < _sfxPoolSize; i++) {
        final p = AudioPlayer();
        p.setVolume(_sfxVolume).catchError((_) {});
        p.setReleaseMode(ReleaseMode.stop).catchError((_) {});
        // Avoid requesting exclusive audio focus for sound effects on Android
        p
            .setAudioContext(
              AudioContext(
                android: AudioContextAndroid(
                  isSpeakerphoneOn: true,
                  stayAwake: false,
                  contentType: AndroidContentType.sonification,
                  usageType: AndroidUsageType.assistanceSonification,
                  audioFocus: AndroidAudioFocus.none,
                ),
              ),
            )
            .catchError((_) {});
        _sfxPool.add(p);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SFX pool creation error: $e');
      }
    }
  }

  Future<void> setSfxEnabled(bool enabled) async {
    _sfxEnabled = enabled;
    sfxEnabledNotifier.value = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefSfxEnabled, enabled);
    } catch (_) {}
  }

  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    musicEnabledNotifier.value = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefMusicEnabled, enabled);
    } catch (_) {}

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

    if (enableNativePlayback) {
      for (final p in _sfxPool) {
        try {
          await p.setVolume(_sfxVolume);
        } catch (_) {}
      }
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefSfxVolume, _sfxVolume);
    } catch (_) {}
  }

  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    musicVolumeNotifier.value = _musicVolume;

    if (enableNativePlayback && _musicPlayer != null) {
      try {
        await _musicPlayer!.setVolume(_musicVolume);
      } catch (_) {}
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefMusicVolume, _musicVolume);
    } catch (_) {}
  }

  AudioPlayer get musicPlayer => _musicPlayer ??= AudioPlayer();

  Future<void> _startMusic() async {
    if (!enableNativePlayback || !_musicEnabled || _appInBackground) return;
    try {
      final p = musicPlayer;
      await p.setVolume(_musicVolume);
      await p.setReleaseMode(ReleaseMode.loop);
      await p.play(AssetSource('audio/ambient_loop.wav'));
      _isMusicPlaying = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Music play error: $e');
      }
    }
  }

  Future<void> _stopMusic() async {
    if (!enableNativePlayback || _musicPlayer == null) return;
    try {
      await _musicPlayer!.stop();
      _isMusicPlaying = false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Music stop error: $e');
      }
    }
  }

  /// Plays a short sound effect from the rotating player pool without blocking.
  void _playSfx(String assetPath) {
    if (!enableNativePlayback || !_sfxEnabled) return;

    if (_sfxPool.isEmpty) {
      _initSfxPool();
      if (_sfxPool.isEmpty) return;
    }

    try {
      final player = _sfxPool[_sfxPoolIndex];
      _sfxPoolIndex = (_sfxPoolIndex + 1) % _sfxPool.length;

      // Reset and play asynchronously without awaiting or blocking UI
      player.stop().then((_) {
        player
            .play(AssetSource(assetPath), mode: PlayerMode.lowLatency)
            .catchError((e) {
          if (kDebugMode) {
            debugPrint('SFX play error ($assetPath): $e');
          }
        });
      }).catchError((e) {
        if (kDebugMode) {
          debugPrint('SFX stop error ($assetPath): $e');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SFX dispatch error ($assetPath): $e');
      }
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
    for (final p in _sfxPool) {
      p.dispose();
    }
    _sfxPool.clear();
    _musicPlayer?.dispose();
    sfxEnabledNotifier.dispose();
    musicEnabledNotifier.dispose();
    sfxVolumeNotifier.dispose();
    musicVolumeNotifier.dispose();
  }
}
