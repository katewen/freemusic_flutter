import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:freemusic_flutter/codeManager.dart';
import 'package:freemusic_flutter/dataManager.dart';
import 'package:freemusic_flutter/listItem.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:freemusic_flutter/playManager.dart';
import 'networkManager.dart';
import 'package:freemusic_flutter/play.dart';
import 'package:freemusic_flutter/playManager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyList extends StatefulWidget {
  MyList({Key key, this.listName, this.source, this.onDeleted})
      : super(key: key);
  final String listName;
  final String source;
  void Function() onDeleted;

  MyListState createState() =>
      MyListState(name: listName, source: source, onDeleted: onDeleted);
}

class MyListState extends State<MyList> {
  MyListState({this.name, this.source, this.onDeleted}) : super();
  final String name;
  final String source;
  void Function() onDeleted;
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
    CodeManager().isShowAlert();
    CodeManager().showCodeAlertCallBack = () {
      _showCodeAlert();
    };
  }

  void deleteMusicList() async {
    await DataManager().deleteMusicListFromData(name);
    onDeleted();
    Navigator.pop(context);
  }

  void verCode(String code) {
    CodeManager().isCodeValid(code);
  }

  Future<bool> _showAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('确定删除该歌单'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消')),
              TextButton(
                  onPressed: () {
                    deleteMusicList();
                    Navigator.of(context).pop();
                  },
                  child: Text('确定'))
            ],
          );
        });
  }

  TextEditingController _editingController = TextEditingController();

  Future<bool> _showCodeAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('输入使用码'),
            content: Container(
              height: 40,
              width: 150,
              child: TextField(
                style: TextStyle(
                  fontSize: 14,
                ),
                autofocus: true,
                controller: _editingController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: "输入使用码",
                    prefixIcon: Icon(Icons.search),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(color: Colors.grey)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(color: Colors.grey)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(color: Colors.grey))),
                maxLines: 1,
                onSubmitted: verCode,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消')),
              TextButton(
                  onPressed: () async {
                    if (await CodeManager().isCodeValid(_editingController.text)) {
                      Fluttertoast.showToast(
                        msg: "使用码正确请开始使用吧",
                      );
                      Navigator.of(context).pop();
                    } else {
                      Fluttertoast.showToast(
                        msg: "使用码不正确",
                      );
                    }
                  },
                  child: Text('确定'))
            ],
          );
        });
  }

  

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
          actions: [
            IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _showAlert();
                },
                tooltip: "delete"),
          ],
          title: Text(
            name,
            style: TextStyle(color: Colors.white),
          )),
      body: Center(
        child: ListView.builder(
            itemBuilder: (context, index) {
              String listTitle =
                  musicList[index].title + ' - ' + musicList[index].author;
              return ListTile(
                title: Text(listTitle),
                contentPadding: EdgeInsets.only(top: 0, bottom: 0, left: 10),
                minLeadingWidth: 30,
                leading: Container(
                  height: 30,
                  width: 30,
                  alignment: Alignment.center,
                  child: Image.asset('images/list_music.png'),
                ),
                focusColor: Colors.grey,
                selectedTileColor: Colors.grey,
                onTap: () async {
                  if (await CodeManager().isShowAlert()) {
                    _showCodeAlert();
                    return;
                  }
                  Fluttertoast.showToast(
                    msg: "正在获取" + listTitle + "音乐链接",
                  );
                  // String musicUrl = await NetworkManager()
                  //     .requestMusicUrlWithId(
                  //         musicList[index]);
                  Fluttertoast.showToast(
                    msg: "获取成功，正在播放" + listTitle,
                  );
                  PlayerManger().playMusicList = musicList;
                  PlayerManger().playingIndex = index;
                  PlayerManger().addPlayQueue(musicList, index);
                  sharedPlay.musicList = musicList;
                  sharedPlay.model = musicList[index];
                },
              );
            },
            itemCount: musicList.length),
      ),
    );
  }
}
