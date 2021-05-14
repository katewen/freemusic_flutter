import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:freemusic_flutter/networkManager.dart';
import 'package:freemusic_flutter/playManager.dart';
import 'dart:math' as math;
import 'dart:ui';

PlayWidget sharedPlay = PlayWidget();

class PlayWidget extends StatefulWidget {
  MusicModel model;
  List musicList;
  @override
  _PlayWidgetState createState() => _PlayWidgetState();
}

class _PlayWidgetState extends State<PlayWidget> {
  String musicName = '测试音乐';
  String artistStr = '';
  List musicList = sharedPlay.musicList;
  MusicModel model = sharedPlay.model;
  String picUrl = '';
  String musicTotalTime = '00:00';
  String musicCurrentTime = '00:00';

  int totalTime = 0;
  int currentTime = 0;
  @override
  void initState() {
    super.initState();
    refreshMusicInfo();
    PlayerManger().player.onPlayerCompletion.listen((event) {
      playNex();
    });
  }

  void refreshMusicInfo() {
    model = PlayerManger().isPlaying
        ? PlayerManger().playMusicList[PlayerManger().playingIndex]
        : null;
    if (model != null) {
      getPicUrl();
      artistStr = "";
      musicName = "";
      for (var artist in model.artist) {
        artistStr = artistStr + artist + ',';
      }
      artistStr =
          artistStr.replaceRange(artistStr.length - 1, artistStr.length, '');
      musicName = model.name;
    }
    if (artistStr == null) {
      artistStr = '';
    }

    PlayerManger().player.onAudioPositionChanged.listen((event) {
      musicCurrentTime = transformToTime(event.inMilliseconds);
      currentTime = event.inMilliseconds;
      if (mounted) {
        setState(() {});
      }
    });
  }

  void getPicUrl() async {
    picUrl =
        await NetworkManager().requestPicUrlWithId(int.parse(model.pic_id));
    musicTotalTime =
        transformToTime((await PlayerManger().player.getDuration()));
    totalTime = await PlayerManger().player.getDuration();
    musicCurrentTime =
        transformToTime((await PlayerManger().player.getCurrentPosition()));
    currentTime = await PlayerManger().player.getCurrentPosition();
    setState(() {});
  }

  String transformToTime(int time) {
    var duration = Duration(milliseconds: time);
    List<String> parts = duration.toString().split(':');
    String minteStr = parts[2].toString().substring(0, 2);
    return '${parts[1]}:${minteStr}';
  }

  void playCrycle() {}

  void playPrevious() {
    PlayerManger().playPrevious();
    refreshState();
  }

  void playPauseAndPlay() {
    PlayerManger().playAndPause();
    refreshState();
  }

  void playNex() {
    PlayerManger().playNext();
    refreshState();
  }

  void playMusicList() async {
    int selectIndex = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: Column(
              children: [
                Align(
                  child: ListTile(
                    title: Text("播放列表"),
                    trailing: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          '关闭',
                          style: TextStyle(color: Colors.grey),
                        )),
                  ),
                  alignment: Alignment.bottomCenter,
                ),
                Expanded(
                    child: ListView.builder(
                  itemBuilder: (context, index) {
                    MusicModel currentModel =
                        PlayerManger().playMusicList[index];
                    String currentArtists = '';
                    String currentMusicName = '';
                    for (var artist in currentModel.artist) {
                      currentArtists = currentArtists + artist + '、';
                    }
                    currentArtists = currentArtists.replaceRange(
                        currentArtists.length - 1, currentArtists.length, '');
                    currentMusicName = currentModel.name;
                    return Align(
                      child: ListTile(
                          title: Text(
                            currentMusicName + ' - ' + currentArtists,
                            textAlign: TextAlign.left,
                          ),
                          trailing: index == PlayerManger().playingIndex
                              ? Image.asset('images/list_play.png')
                              : null,
                          onTap: () => Navigator.of(context).pop(index)),
                    );
                  },
                  itemCount: PlayerManger().playMusicList.length,
                ))
              ],
            ),
          );
        });
    if (selectIndex != null && selectIndex != PlayerManger().playingIndex) {
      String musicUrl = await NetworkManager()
          .requestMusicUrlWithId(PlayerManger().playMusicList[selectIndex].id);
      model = PlayerManger().playMusicList[selectIndex];
      PlayerManger().reloadPlayDataWithUrl(musicUrl);
      PlayerManger().playingIndex = selectIndex;
      refreshMusicInfo();
    }
  }

  void refreshState() {
    refreshMusicInfo();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '播放',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 20,
            child: Text(
              musicName,
              style: TextStyle(fontSize: 18, color: Colors.black),
            ),
          ),
          Positioned(
            top: 60,
            child: Text(
              artistStr,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
          Positioned(
            child: DecoratedBox(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(150),
                  color: Colors.grey,
                  image: DecorationImage(
                      image: picUrl != ''
                          ? NetworkImage(picUrl)
                          : AssetImage('images/music.png'))),
              child: Transform.rotate(
                angle: 0.02,
              ),
            ),
            height: 300,
            width: 300,
            top: 110,
          ),
          Positioned(
            child: Text(musicCurrentTime),
            bottom: 114,
            left: 10,
          ),
          Positioned(
            child: SizedBox(
              height: 5,
              child: LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(Colors.blue),
                value: totalTime == 0 ? 0 : currentTime / totalTime,
              ),
            ),
            bottom: 120,
            left: 50,
            right: 50,
          ),
          Positioned(
              child: Text(
                musicTotalTime,
                textDirection: TextDirection.rtl,
              ),
              right: 10,
              bottom: 114),
          Positioned(
            height: 100,
            child: Row(
              children: [
                SizedBox(width: 20, height: 20),
                SizedBox(
                  width: 30,
                ),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: TextButton(
                      onPressed: playPrevious,
                      child: Image.asset('images/play_previous.png')),
                ),
                SizedBox(
                  width: 30,
                ),
                SizedBox(
                  width: 70,
                  height: 70,
                  child: TextButton(
                      onPressed: playPauseAndPlay,
                      child: Image.asset(PlayerManger().isPlaying
                          ? 'images/play_play.png'
                          : 'images/play_pause.png')),
                ),
                SizedBox(
                  width: 30,
                ),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: TextButton(
                      onPressed: playNex,
                      child: Image.asset('images/play_next.png')),
                ),
                SizedBox(
                  width: 30,
                ),
                SizedBox(
                  width: 30,
                  height: 30,
                  child: TextButton(
                      onPressed: playMusicList,
                      child: Image.asset('images/play_list.png')),
                ),
              ],
            ),
            bottom: 20,
          )
        ],
      ),
    );
  }
}
