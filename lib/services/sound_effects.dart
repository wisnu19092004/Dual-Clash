import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Multiplatform Audio Effects Engine
/// Supports native Web Audio, Android, iOS, Windows, Mac, and Linux.
/// Generates compliant in-memory PCM WAV audio buffers so format errors never occur.
class SoundEffects {
  SoundEffects._();

  static AudioPlayer? _player;
  static Uint8List? _tapWavBytes;
  static Uint8List? _captureWavBytes;
  static bool _initialized = false;

  static void init() {
    if (!_initialized) {
      _initialized = true;
      try {
        _tapWavBytes = _generateWoodTapWav(frequency: 440, durationMs: 45);
        _captureWavBytes = _generateWoodTapWav(frequency: 280, durationMs: 80);
        _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      } catch (_) {}
    }
  }

  static Future<void> playButtonClick() async {
    // 1. Instant tactile feedback
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    // 2. Play Audio with graceful multi-tier fallbacks
    try {
      init();
      if (_tapWavBytes != null && _player != null) {
        await _player!.stop();
        await _player!.play(BytesSource(_tapWavBytes!, mimeType: 'audio/wav'), volume: 1.0);
        return;
      }
    } catch (e) {
      debugPrint('Audio playback handled: $e');
    }

    // Fallback: System sound click
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static Future<void> playMovePiece() async {
    await playButtonClick();
  }

  static Future<void> playCapturePiece() async {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    try {
      init();
      if (_captureWavBytes != null && _player != null) {
        await _player!.stop();
        await _player!.play(BytesSource(_captureWavBytes!, mimeType: 'audio/wav'), volume: 1.0);
        return;
      }
    } catch (e) {
      debugPrint('Capture audio handled: $e');
    }

    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  static void playCheck() {
    try {
      SystemSound.play(SystemSoundType.alert);
      HapticFeedback.vibrate();
    } catch (_) {}
  }

  /// Synthesizes a clean wood-tap click sound in uncompressed 16-bit 44.1kHz PCM WAV format.
  /// 100% compliant with HTML5 Web Audio and all native platform media decoders.
  static Uint8List _generateWoodTapWav({required double frequency, required int durationMs}) {
    const int sampleRate = 44100;
    const int numChannels = 1;
    const int bitsPerSample = 16;
    final int numSamples = (sampleRate * (durationMs / 1000.0)).toInt();
    final int dataSize = numSamples * numChannels * (bitsPerSample ~/ 8);
    final int fileSize = 36 + dataSize;

    final byteData = ByteData(44 + dataSize);

    // RIFF header
    byteData.setUint8(0, 0x52); // 'R'
    byteData.setUint8(1, 0x49); // 'I'
    byteData.setUint8(2, 0x46); // 'F'
    byteData.setUint8(3, 0x46); // 'F'
    byteData.setUint32(4, fileSize, Endian.little);
    byteData.setUint8(8, 0x57);  // 'W'
    byteData.setUint8(9, 0x41);  // 'A'
    byteData.setUint8(10, 0x56); // 'V'
    byteData.setUint8(11, 0x45); // 'E'

    // fmt subchunk
    byteData.setUint8(12, 0x66); // 'f'
    byteData.setUint8(13, 0x6D); // 'm'
    byteData.setUint8(14, 0x74); // 't'
    byteData.setUint8(15, 0x20); // ' '
    byteData.setUint32(16, 16, Endian.little); // Subchunk1Size (16 for PCM)
    byteData.setUint16(20, 1, Endian.little);  // AudioFormat (1 for PCM)
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * numChannels * (bitsPerSample ~/ 8), Endian.little); // ByteRate
    byteData.setUint16(32, numChannels * (bitsPerSample ~/ 8), Endian.little); // BlockAlign
    byteData.setUint16(34, bitsPerSample, Endian.little);

    // data subchunk
    byteData.setUint8(36, 0x64); // 'd'
    byteData.setUint8(37, 0x61); // 'a'
    byteData.setUint8(38, 0x74); // 't'
    byteData.setUint8(39, 0x61); // 'a'
    byteData.setUint32(40, dataSize, Endian.little);

    // Generate wood-tap click sine wave with exponential decay envelope
    for (int i = 0; i < numSamples; i++) {
      final double t = i / sampleRate;
      final double envelope = math.exp(-t * (1000.0 / (durationMs * 0.35)));
      final double sine = math.sin(2.0 * math.pi * frequency * t);
      // Double octave wood knock resonance
      final double subSine = 0.5 * math.sin(2.0 * math.pi * (frequency * 0.5) * t);
      final double sample = (sine + subSine) * envelope;

      final int sampleInt16 = (sample.clamp(-1.0, 1.0) * 32767.0).toInt();
      byteData.setInt16(44 + (i * 2), sampleInt16, Endian.little);
    }

    return byteData.buffer.asUint8List();
  }
}
