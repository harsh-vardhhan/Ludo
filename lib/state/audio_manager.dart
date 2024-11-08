import 'package:flame_audio/flame_audio.dart';

class AudioManager {
  static AudioPool? _diceSoundPool;

  static Future<void> initialize() async {
    if (_diceSoundPool == null) {
      _diceSoundPool = await AudioPool.createFromAsset(
        path: 'audio/dice.mp3',
        maxPlayers: 3,
      );
    }
  }

  static Future<StopFunction> playDiceSound({double volume = 1.0}) async {
    // This will start playing the sound and return a stop function for control.
    return await _diceSoundPool!.start(volume: volume);
  }

  static Future<void> dispose() async {
    await _diceSoundPool?.dispose();
    _diceSoundPool = null;
  }
}
