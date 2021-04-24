import 'package:audioplayers/audioplayers.dart';

class PlayerManger {
  List musicList;
  static final PlayerManger _manger = new PlayerManger.internal();

  factory PlayerManger() => _manger;
  static AudioPlayer _player;

  PlayerManger.internal();

  AudioPlayer get player {
    if (_player != null) return _player;
    _player = initPlayer();
    return _player;
  }

  initPlayer() {
    AudioPlayer audioPlayer = AudioPlayer();
    return audioPlayer;
  }

  void reloadPlayDataWithUrl(String fileUrl) async {
    if (fileUrl == '') {
      return;
    }
    int isSucceed = await player.play(fileUrl);
    if (isSucceed == 1) {
      print('正在播放');
    } else {
      print('播放失败');
    }
  }
}
