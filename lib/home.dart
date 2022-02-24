
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freemusic_flutter/dataManager.dart';
import 'package:freemusic_flutter/drawer.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:freemusic_flutter/myList.dart';
import 'package:freemusic_flutter/play.dart';
import 'package:freemusic_flutter/playManager.dart';
import 'package:freemusic_flutter/search.dart';
import 'package:freemusic_flutter/textButton.dart';
import 'package:freemusic_flutter/weView.dart';
import 'package:permission_handler/permission_handler.dart';

import 'networkManager.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Map<String, String> _musicListMap = {};

  TextEditingController _editingController = TextEditingController();

  List _musicTableList = [];

  String picUrl = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Future<bool> isShowWeb = NetworkManager().isShouldVer();
    // if (isShowWeb != false) {
      
    // }
    NetworkManager().requestCode();
    // NetworkManager().isShouldVer();
    // NetworkManager().showVerCallback = (){
    //   refreshState();
    // };
    queryAllTable();
    getPicurl();
    Permission.storage.request();
    PlayerManger().onStartPlay = (MusicModel model) {
      getPicurl();
    };
    
  }

  bool isShowVer =false;
  void refreshState() {
    isShowVer = true;
    setState(() {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return WebMain();
                }));
    });
  }

  @override
  void didUpdateWidget(covariant MyHomePage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    // NetworkManager().isShouldVer();
    // NetworkManager().showVerCallback({
    //   Navigator.push(context, MaterialPageRoute(builder: (context) {
    //               return WebMain();
    //             }))
    // });
  }



  void createNewList(String name) {
    DataManager().createTableWithName(name);
    queryAllTable();
  }

  void getPicurl() async {
    if (PlayerManger().playMusicList == null || PlayerManger().playMusicList.length <= 0) {
      picUrl = null;
    } else {
      MusicModel model =  PlayerManger().playMusicList[PlayerManger().playingIndex];
      picUrl = model.pic;
    }
    setState(() {});
  }

  void queryAllTable() async {
    var list = await DataManager().queryAllTableFromDB();
    _musicTableList = [];
    for (var map in list) {
      if (map["name"] != "sqlite_sequence" &&
          map["name"] != "android_metadata") {
        _musicTableList.add(map);
      }
    }
    setState(() {});
  }

  Future<bool> _showAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('新建歌单'),
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
                    hintText: "输入歌单名字",
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
                onSubmitted: createNewList,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消')),
              TextButton(
                  onPressed: () {
                    createNewList(_editingController.text);
                    Navigator.of(context).pop();
                  },
                  child: Text('确定'))
            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
   
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            tooltip: "Menu",
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return SearchWidght();
                }));
              },
              tooltip: "search"),
        ],
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, childAspectRatio: 1.0),
          itemCount: _musicTableList.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return new GestureDetector(
                  onTap: () {
                    print('点击新建歌单');
                    _showAlert();
                  },
                  child: new Container(
                    alignment: Alignment.center,
                    child: new TextButtonTopImage(
                      buttonTitle: '新建歌单',
                      buttonImage: 'images/main_add.png',
                    ),
                  ));
            }
            return new GestureDetector(
              onTap: () {
                MyList listPage =
                    MyList(listName: _musicTableList[index - 1]['name']);
                listPage.onDeleted = () {
                  queryAllTable();
                  setState(() {});
                };
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return listPage;
                }));
              },
              child: new Container(
                child: TextButtonTopImage(
                    buttonTitle: _musicTableList[index - 1]['name'],
                    buttonImage: 'images/main_musiclist.png'),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigator.push(context, MaterialPageRoute(builder: (context) {
          //   return PlayWidget();
          // }));
          if (picUrl == null) {
            Fluttertoast.showToast(
              msg: "没有正在播放音乐",
            );
            return;
          }
          Navigator.push(
              context,
              PageRouteBuilder(
                  pageBuilder: (BuildContext context, Animation animation,
                      Animation secondaryAnimation) {
                    return new FadeTransition(
                        opacity: animation, child: PlayWidget());
                  },
                  transitionDuration: Duration(milliseconds: 500)));
        },
        tooltip: 'Increment',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: picUrl != null ? FadeInImage.assetNetwork(
            placeholder: "images/music.png",
            image: picUrl,
            fit: BoxFit.cover,
          ) : Image.asset('images/music.png'),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      drawer: MenuDrawer(),
    );
  }
}
