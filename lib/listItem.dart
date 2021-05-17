import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:freemusic_flutter/networkManager.dart';
import 'package:freemusic_flutter/play.dart';
import 'package:freemusic_flutter/playManager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ListItem extends StatelessWidget {
  ListItem({Key key, this.model}) : super(key: key);
  String name;
  MusicModel model;
  List artistList;
  String artistStr = "";
  void Function() onPlayed;
  void Function() onFavorited;
  void Function() onDownload;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    for (var artist in model.artist) {
      artistStr = artistStr + artist + '、';
    }
    artistStr =
        artistStr.replaceRange(artistStr.length - 1, artistStr.length, '');
    name = model.name;
    return Container(
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            child: Image.asset('images/list_music.png'),
          ),
          Container(
            padding: EdgeInsets.only(left: 10),
            width: MediaQuery.of(context).size.width - 120,
            child: Text('$name - $artistStr'),
          ),
          GestureDetector(
            child: Container(
              height: 28,
              width: 28,
              padding: EdgeInsets.only(right: 5),
              child: Image.asset('images/list_play.png'),
            ),
            onTap: () async {
              String musicUrl =
                  await NetworkManager().requestMusicUrlWithId(model.id);
              PlayerManger().reloadPlayDataWithUrl(musicUrl);
              PlayerManger().playingIndex = 0;
              PlayerManger().playMusicList = [model];
              sharedPlay.musicList = [model];
              sharedPlay.model = model;
              Fluttertoast.showToast(
                msg: "正在播放" + name + artistStr,
              );
            },
          ),
          GestureDetector(
            child: Container(
              height: 30,
              width: 30,
              padding: EdgeInsets.only(right: 5),
              child: Image.asset('images/list_download.png'),
            ),
            onTap: () {
              NetworkManager().downloadMusicWith(model);
            },
          ),
          GestureDetector(
            child: Container(
              height: 30,
              width: 30,
              padding: EdgeInsets.only(right: 5),
              child: Image.asset('images/list_add.png'),
            ),
            onTap: onFavorited,
          )
        ],
      ),
    );
  }
}
