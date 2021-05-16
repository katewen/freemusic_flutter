import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:freemusic_flutter/dataManager.dart';
import 'package:freemusic_flutter/drawer.dart';
import 'package:freemusic_flutter/myList.dart';
import 'package:freemusic_flutter/play.dart';
import 'package:freemusic_flutter/search.dart';
import 'package:freemusic_flutter/textButton.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '享乐',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '音乐'),
    );
  }
}

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    queryAllTable();
    Permission.storage.request();
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
    });
  }

  void createNewList(String name) {
    DataManager().createTableWithName(name);
    queryAllTable();
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
                      buttonImage: 'images/music.png',
                    ),
                  ));
            }
            return new GestureDetector(
              onTap: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return MyList(listName: _musicTableList[index - 1]['name']);
                }));
              },
              child: new Container(
                child: TextButtonTopImage(
                    buttonTitle: _musicTableList[index - 1]['name'],
                    buttonImage: 'images/music.png'),
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
        child: Image(image: AssetImage("images/music.png")),
      ), // This trailing comma makes auto-formatting nicer for build methods.
      drawer: MenuDrawer(),
    );
  }
}
