import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebMain extends StatelessWidget {

  static final WebMain _manger = new WebMain.internal();

  factory WebMain() => _manger;

  final flutterWebViewPlugin = FlutterWebviewPlugin();

  // void Function(MusicModel model) onStartPlay;

  WebMain.internal();

  static String _customeUA = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.80 Mobile Safari/537.36";
  final webviewScaffold =  WebviewScaffold(
      url:"http://www.musictool.top",
      // 登录的URL
      appBar: new AppBar(
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [],
        ),
        iconTheme: new IconThemeData(color: Colors.white),
      ),
      withZoom: true,
      // 允许网页缩放
      withLocalStorage: true,
      // 允许LocalStorage
      withJavascript: true,
      // userAgent: _customeUA, // 允许执行js代码
    );

  @override
  Widget build(BuildContext context) {
    List<Widget> titleContent = [];
    titleContent.add(new Text(
      "访问验证",
      style: new TextStyle(color: Colors.white),
      textAlign: TextAlign.center,
    ));
    titleContent.add(new Container(width: 50.0));
    
    return webviewScaffold;
  }
}