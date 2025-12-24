import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Service for voice input using speech-to-text
class VoiceInputService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _isInitialized = false;

  /// Initialize speech recognition
  static Future<bool> initialize() async {
    if (!_isInitialized) {
      _isInitialized = await _speech.initialize();
    }
    return _isInitialized;
  }

  /// Start listening to voice input
  static Future<String?> listen() async {
    if (!_isInitialized) {
      await initialize();
    }

    String? result;

    await _speech.listen(
      onResult: (val) {
        result = val.recognizedWords;
      },
    );

    await Future.delayed(const Duration(seconds: 3));
    await _speech.stop();

    return result;
  }
}
