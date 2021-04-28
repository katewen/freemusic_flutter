import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:freemusic_flutter/networkManager.dart';
import 'package:freemusic_flutter/playManager.dart';
import 'dart:math' as math;

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
    if (model != null) {
      getPicUrl();
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
      setState(() {});
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
                PlayerManger().player.state == AudioPlayerState.PLAYING
                    ? musicTotalTime
                    : '00:00',
                textDirection: TextDirection.rtl,
              ),
              right: 10,
              bottom: 114),
          Positioned(
            height: 100,
            child: Row(
              children: [
                Text('循环'),
                SizedBox(
                  width: 30,
                ),
                Text('上一个'),
                SizedBox(
                  width: 30,
                ),
                Text('播放'),
                SizedBox(
                  width: 30,
                ),
                Text('下一个'),
                SizedBox(
                  width: 30,
                ),
                Text('列表')
              ],
            ),
            bottom: 20,
          )
        ],
      ),
    );
  }
}
