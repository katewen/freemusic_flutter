import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:freemusic_flutter/musicModel.dart';

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

  // factory _PlayWidgetState() => _getInstance();

  // static _PlayWidgetState get instance => _getInstance();

  // _PlayWidgetState.internal();

  // static _PlayWidgetState _instance;

  // static _PlayWidgetState _getInstance() {
  //   if (_instance == null) {
  //     _instance = _PlayWidgetState.internal();
  //   }
  //   return _instance;
  // }
  //
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (model != null) {
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
                color: Colors.black,
              ),
              child: Image.asset('images/music.png'),
            ),
            height: 300,
            width: 300,
          ),
          Positioned(
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
            bottom: 50,
          )
        ],
      ),
    );
  }
}
