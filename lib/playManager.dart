import 'package:audioplayers/audioplayers.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'networkManager.dart';

class PlayerManger {
  List playMusicList;
  int playingIndex;
  bool isPlaying = false;
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

  void playNext() {
    if (playingIndex == playMusicList.length - 1) {
      playingIndex = 0;
    } else {
      playingIndex++;
    }
    reloadPlayDataWithIndex();
  }

  void playPrevious() {
    if (playingIndex == 0) {
      playingIndex = playMusicList.length - 1;
    } else {
      playingIndex--;
    }
    reloadPlayDataWithIndex();
  }

  void play() {
    player.resume();
    isPlaying = true;
  }

  void pause() {
    player.pause();
    isPlaying = false;
  }

  void playAndPause() {
    if (_player.state == AudioPlayerState.PAUSED) {
      play();
    } else {
      pause();
    }
  }

  void reloadPlayDataWithIndex() async {
    MusicModel model = playMusicList[playingIndex];
    String musicUrl = await NetworkManager().requestMusicUrlWithId(model.id);
    reloadPlayDataWithUrl(musicUrl);
  }

  void reloadPlayDataWithUrl(String fileUrl) async {
    if (fileUrl == '') {
      isPlaying = false;
      return;
    }
    int isSucceed = await player.play(fileUrl);
    if (isSucceed == 1) {
      isPlaying = true;
      print('正在播放');
    } else {
      isPlaying = false;
      print('播放失败');
    }
  }
}
