
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:freemusic_flutter/dataManager.dart';
import 'package:freemusic_flutter/drawer.dart';
import 'package:freemusic_flutter/myList.dart';
import 'package:freemusic_flutter/networkManager.dart';
import 'package:freemusic_flutter/play.dart';
import 'package:freemusic_flutter/playManager.dart';
import 'package:freemusic_flutter/search.dart';
import 'package:freemusic_flutter/textButton.dart';
import 'package:freemusic_flutter/weView.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:freemusic_flutter/home.dart';

Future<void> main() async {
  PlayerManger().registerAudioService();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyAppPageState createState() => _MyAppPageState();
}

class _MyAppPageState extends State<MyApp> {
  
  bool isFinishLoad = false;
  double webProgress = 0.0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    
    NetworkManager().isShouldVer();
    NetworkManager().showVerCallback = (bool show){
      refreshState(show);
    };
    WebMain().flutterWebViewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      if (mounted) {
        print("weview"+state.type.toString());
        print("weview" + state.url.toString());
        if (state.type == WebViewState.shouldStart) {
          isFinishLoad = true;
          WebMain().flutterWebViewPlugin.hide();
          isFinishLoad = false;
          NetworkManager().isShouldVer();
        }
        setState(() {
        
        });
      }
    });
    WebMain().flutterWebViewPlugin.onProgressChanged.listen((double progress) {
      print("weview"+progress.toString());
      if (isFinishLoad) {
        // isShowVer = false;
        WebMain().flutterWebViewPlugin.hide();
        isFinishLoad = false;
        NetworkManager().isShouldVer();
      }
      
    });


  }


  bool isShowVer =false;

  void refreshState(bool show) {
    if (show) {
      isShowVer = true;
      if (WebMain().flutterWebViewPlugin != null ) {
        WebMain().flutterWebViewPlugin.show();
      } 
    } else {
      isShowVer = false;
    }
    
    setState(() {
      
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // routes: {
      //   "/weview": (_) => new WebMain()
      // },
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
      home: !isShowVer  ? MyHomePage(title: '享乐音乐') : WebMain(),
    );
  }
}




