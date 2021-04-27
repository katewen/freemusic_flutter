import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:freemusic_flutter/dataManager.dart';
import 'package:freemusic_flutter/listItem.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:freemusic_flutter/playManager.dart';
import 'networkManager.dart';

class MyList extends StatefulWidget {
  MyList({Key key, this.listName}) : super(key: key);
  final String listName;

  MyListState createState() => MyListState(name: listName);
}

class MyListState extends State<MyList> {
  MyListState({this.name}) : super();
  final String name;
  List<MusicModel> musicList = [];
  void _queryListWithName() async {
    musicList = await DataManager().queryAllModelFromTable(name);
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _queryListWithName();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          title: Text(
        name,
        style: TextStyle(color: Colors.white),
      )),
      body: Center(
        child: ListView.builder(
            itemBuilder: (context, index) {
              String listTitle =
                  musicList[index].name + ' - ' + musicList[index].artist[0];
              return Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: ListTile(
                    title: Text(listTitle),
                    leading: Container(
                      height: 30,
                      width: 30,
                      alignment: Alignment.topCenter,
                      child: Image.asset('images/list_music.png'),
                    ),
                    focusColor: Colors.grey,
                    selectedTileColor: Colors.grey,
                    onTap: () async {
                      String musicUrl = await NetworkManager()
                          .requestMusicUrlWithId(musicList[index].id);
                      PlayerManger().reloadPlayDataWithUrl(musicUrl);
                      PlayerManger().playMusicList = musicList;
                      PlayerManger().playingIndex = index;
                    },
                  ));
            },
            itemCount: musicList.length),
      ),
    );
  }
}
