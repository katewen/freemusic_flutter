
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:freemusic_flutter/networkManager.dart';
import 'package:freemusic_flutter/playManager.dart';
import 'dart:math' as math;
import 'dart:ui';
import 'package:freemusic_flutter/main.dart';
import 'package:rxdart/rxdart.dart';
import 'package:freemusic_flutter/common.dart';
import 'playManager.dart';

PlayWidget sharedPlay = PlayWidget();

class PlayWidget extends StatefulWidget {
  MusicModel model;
  List musicList;
  @override
  _PlayWidgetState createState() => _PlayWidgetState();
}

class _PlayWidgetState extends State<PlayWidget> {
  String musicName = '';
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
    // PlayerManger().player.stop.listen((event){
    //     if (PlayerManger().player.)
    // });
    // PlayerManger().player.onPlayerCompletion.listen((event) {
    //   playNex();
    // });
  }

  void refreshMusicInfo() {
    model = PlayerManger().isPlaying
        ? PlayerManger().playMusicList[PlayerManger().playingIndex]
        : null;
    if (model != null) {
      picUrl = model.pic;
      getPicUrl();
      artistStr = model.author;
      musicName = model.title;
    }
    if (artistStr == null) {
      artistStr = '';
    }
    setState(() {
      
    });
    // PlayerManger().player.durationStream.
    // PlayerManger().player.onAudioPositionChanged.listen((event) {
    //   musicCurrentTime = transformToTime(event.inMilliseconds);
    //   currentTime = event.inMilliseconds;
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
  }

  void getPicUrl() async {
    
    // print(PlayerManger().player.duration);
    // //musicTotalTime =
    //     //transformToTime((PlayerManger().player.duration.inSeconds));
    // //totalTime = PlayerManger().player.duration.inSeconds;
    // musicCurrentTime =
    //     transformToTime((PlayerManger().player.duration.inSeconds ));
    // currentTime = PlayerManger().player.duration.inSeconds;
    picUrl = model.pic;
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
    if (PlayerManger().isPlaying) 
      PlayerManger().pause();
    else
      PlayerManger().play();
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
                    String currentArtists = currentModel.author;
                    String currentMusicName = '';
                    // for (var artist in currentModel.artist) {
                    //   currentArtists = currentArtists + artist + '、';
                    // }
                    // currentArtists = currentArtists.replaceRange(
                    //     currentArtists.length - 1, currentArtists.length, '');
                    currentMusicName = currentModel.title;
                    return Align(
                      child: ListTile(
                          title: Text(
                            currentMusicName + ' - ' + currentArtists,
                            textAlign: TextAlign.left,
                          ),
                          leading: index == PlayerManger().playingIndex
                              ? SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: Image.asset('images/list_play.png'))
                              : SizedBox(
                                  width: 25,
                                  height: 25,
                                ),
                          // trailing: index == PlayerManger().playingIndex
                          //     ? Image.asset('images/list_play.png')
                          //     : null,
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
      PlayerManger().playingIndex = selectIndex;
      model = PlayerManger().playMusicList[selectIndex];
      String musicUrl = await NetworkManager().requestMusicUrlWithId(
          PlayerManger().playMusicList[selectIndex]);
      PlayerManger().reloadPlayDataWithIndex(selectIndex);
      refreshMusicInfo();
    }
  }

  void refreshState() {
    refreshMusicInfo();
    setState(() {});
  }

  Stream<Duration> get _bufferedPositionStream => PlayerManger().audioHandler.playbackState
      .map((state) => state.bufferedPosition)
      .distinct();
  Stream<bool> get _playbackStream => PlayerManger().audioHandler.playbackState
      .map((state) => state.playing).distinct();

  Stream<MediaItem> get _playingItemStream => PlayerManger().audioHandler.mediaItem.map((item) => item).distinct();

  Stream<Duration> get _durationStream =>
      PlayerManger().audioHandler.mediaItem.map((item) => item.duration).distinct();
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration, PositionData>(
          AudioService.position,
          _bufferedPositionStream,
          _durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));
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
          StreamBuilder<MediaItem>(
              stream: _playingItemStream,
              builder: (context, snapshot) {
                final item = snapshot.data ?? null;
                return Positioned(
                          top: 20,
                          child: Text(
                            item != null ? item.title : "",
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          ),
                        );
              }
          ),
          StreamBuilder<MediaItem>(
              stream: _playingItemStream,
              builder: (context, snapshot) {
                final item = snapshot.data ?? null;
                return Positioned(
                          top: 60,
                          child: Text(
                            item != null ? item.artist : "",
                            style: TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        );
              }
          ),
          StreamBuilder<MediaItem>(
              stream: _playingItemStream,
              builder: (context, snapshot) {
                final item = snapshot.data ?? null;
                return Positioned(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(150),
                              color: Colors.grey,
                              image: DecorationImage(
                                  image: item != null
                                      ? NetworkImage(item.artUri.toString())
                                      : AssetImage('images/music.png'),
                                      fit: BoxFit.fill
                              )
                            ),
                          child: Transform.rotate(
                            angle: 0.02,
                          ),
                        ),
                        height: 300,
                        width: 300,
                        top: 110,
                      );
              }
          ),
          // Positioned(
          //   child: Text(musicCurrentTime),
          //   bottom: 114,
          //   left: 10,
          // ),
          StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data ??
                    PositionData(Duration.zero, Duration.zero, Duration.zero);
                return Positioned(
                  child: SeekBar(
                            duration: positionData.duration,
                            position: positionData.position,
                            onChangeEnd: (newPosition) {
                              PlayerManger().audioHandler.seek(newPosition);
                            },
                          ),
                  bottom: 120,
                  left: 50,
                  right: 50,
                );
              },
            ),
          
          // Positioned(
          //     child: Text(
          //       musicTotalTime,
          //       textDirection: TextDirection.rtl,
          //     ),
          //     right: 10,
          //     bottom: 114),
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
                StreamBuilder<bool>(
                  stream: _playbackStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data ?? false;
                    return SizedBox(
                        width: 70,
                        height: 70,
                        child: TextButton(
                            onPressed: playPauseAndPlay,
                            child: Image.asset(playing
                                ? 'images/play_play.png'
                                : 'images/play_pause.png')),
                      );
                  },
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
