import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freemusic_flutter/codeManager.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:freemusic_flutter/weView.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkManager {
  static String _host = "http://www.musictool.top";
  static String _customeUA = "Mozilla/5.0 (Linux; Android 6.0; Nexus 5 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.80 Mobile Safari/537.36";

  static HttpClient httpClient = new HttpClient();
  Dio dio = Dio();
  HttpClientRequest request;

  void Function(bool show) showVerCallback;

  static final NetworkManager _manger = new NetworkManager.internal();

  factory NetworkManager() => _manger;

  NetworkManager.internal();

  // AudioPlayer get player {
  //   if (_player != null) return _player;
  //   _player = initPlayer();
  //   return _player;
  // }

  // initPlayer() {
  //   AudioPlayer audioPlayer = AudioPlayer();
  //   return audioPlayer;
  // }


  Future<void> requestCode() async {
    Response response = await Dio().getUri(Uri.parse("http://8.210.77.223:5000/"));
    Map dataMap = await response.data;
    // Map data = jsonDecode(dataString);
    CodeManager().netCode = dataMap['code'].toString();
  }

  Future<bool> isShouldVer() async {
    Response response = await Dio().getUri(Uri.parse(_host));
    String dataString = await response.data;
    if (dataString.contains('验证码')) {
      if (showVerCallback != null) {
        showVerCallback(true);
      }
    } else {
      if (showVerCallback != null) {
        showVerCallback(false);
      }
    }
  }

  Future<List> requestListWithName(
      String musicName, int page, String source) async {
    httpClient.findProxy = (url) {
      return HttpClient.findProxyFromEnvironment(url, environment: {"http_proxy": 'http://192.168.31.49:8888',});
    };
    if (CodeManager().isShowAlert() == true) {
      // 展示弹窗
    }
    String referer = _host + '/?name=' + Uri.encodeComponent(musicName) + '&type=' + source;
    Map<String,dynamic> jsonMap = {
      "input":musicName,
      "filter": "name",
      "type": source,
      "page": page.toString()
    };
    // Uri url = Uri.http('musictool.top','',jsonMap);
    // request.add(utf8.encode(json.encode(jsonMap)));
    BaseOptions options = BaseOptions();
    options.headers["referer"] = referer;
    options.headers["content-type"] = "application/x-www-form-urlencoded; charset=UTF-8";
    options.headers["origin"] = _host;
    options.headers["X-Requested-With"] = "XMLHttpRequest";
    options.headers["User-Agent"] = _customeUA;
    options.headers["accept-encoding"] = "gzip, deflate";
    dio = Dio(options);

    Response response = await dio.post(_host,data: jsonMap);
    
    // httpClient.postUrl(Uri.parse(_host));
    

    // request.headers.set("referer", referer);
    // request.headers.set("content-type", 'application/x-www-form-urlencoded; charset=UTF-8');
    // request.headers.set("origin", _host);
    // request.headers.set("X-Requested-With", 'XMLHttpRequest');
    // request.headers.set("User-Agent", _customeUA);
    // request.headers.set('accept-encoding', 'gzip, deflate');
    // request.headers.set('accept-language', 'zh-CN,zh;q=0.9');
    
    // request.write(jsonMap);

    Map map = Map();
    map['input'] = musicName;
    map['filter'] = 'name';
    map['type'] = source;
    map['page'] = page.toString();

    // request.add(utf8.encode(json.encode(map)));

    // HttpClientResponse response = await request.close();
    String dataString = await response.data;
    print('获取到数据====' + dataString);
    Map dataMap = jsonDecode(dataString);
    if (!dataMap.containsKey("data")) {
      return [];
    }
    List data = dataMap["data"];
    if (data.length == 0) {
      return [];
    }

    return data;
  }

  Future<String> requestMusicUrlWithId(MusicModel model) async {
    return model.url;
  }

  Future<String> requestPicUrlWithId(MusicModel model) async {
    
    return model.pic;
  }

  Future<String> requestLyricWithId(MusicModel model)async {
    return model.lrc;
  }

  void downloadMusicWith(MusicModel model) async {
    bool status = await Permission.storage.isGranted;
    if (!status) {
      await Permission.storage.request();
      status = await Permission.storage.isGranted;
    }
    if (status) {
      Dio dio = Dio();
      //    dio.options.baseUrl = "https://123.sogou.com";
      //设置连接超时时间
      dio.options.connectTimeout = 10000;
      //设置数据接收超时时间
      dio.options.receiveTimeout = 10000;
      String musicUrl =
          await NetworkManager().requestMusicUrlWithId(model);
      String artistStr = model.author;
      String name = "";
      // for (var artist in model.artist) {
      //   artistStr = artistStr + artist + '、';
      // }
      // artistStr =
      //     artistStr.replaceRange(artistStr.length - 1, artistStr.length, '');
      name = model.title;
      String fileName = name + " - " + artistStr + ".mp3";
      var path = Directory("storage/emulated/0/MyMusics");
      path = await getExternalStorageDirectory();
      path = Directory(path.path + "/DownloadedMusics");
      if (!(await path.exists())) {
        await path.create();
      }
      Fluttertoast.showToast(
        msg: "正在下载歌曲",
      );
      Response response =
          await dio.download(musicUrl, path.path + "/" + fileName);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(
          msg: "已下载到" + path.path,
        );
      }
    }
  }
}
