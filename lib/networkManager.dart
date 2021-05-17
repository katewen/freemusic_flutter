import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkManager {
  static HttpClient httpClient = new HttpClient();
  // ignore: close_sinks
  HttpClientRequest request;

  Future<List> requestListWithName(String musicName, int page) async {
    Uri url = Uri.http('y.webzcz.cn', '/api.php', {
      "types": "search",
      "count": "20",
      "source": "netease",
      "pages": page.toString(),
      "name": musicName
    });
    request = await httpClient.getUrl(url);
    HttpClientResponse response = await request.close();
    String dataString = await response.transform(utf8.decoder).join();
    List data = jsonDecode(dataString);
    return data;
  }

  Future<String> requestMusicUrlWithId(int musicId) async {
    Uri url = Uri.http('y.webzcz.cn', '/api.php',
        {"types": "url", "source": "netease", "id": musicId.toString()});
    request = await httpClient.getUrl(url);
    HttpClientResponse response = await request.close();
    String dataString = await response.transform(utf8.decoder).join();
    Map data = jsonDecode(dataString);
    return data['url'];
  }

  Future<String> requestPicUrlWithId(int picId) async {
    Uri url = Uri.http('y.webzcz.cn', '/api.php',
        {"types": "pic", "source": "netease", "id": picId.toString()});
    request = await httpClient.getUrl(url);
    HttpClientResponse response = await request.close();
    String dataString = await response.transform(utf8.decoder).join();
    Map data = jsonDecode(dataString);
    return data['url'];
  }

  Future<String> requestLyricWithId(int lyridId) async {
    Uri url = Uri.http('y.webzcz.cn', '/api.php',
        {"types": "lyric", "source": "netease", "id": lyridId});
    request = await httpClient.getUrl(url);
    HttpClientResponse response = await request.close();
    String dataString = await response.transform(utf8.decoder).join();
    Map data = jsonDecode(dataString);
    return data['lyric'];
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
      String musicUrl = await NetworkManager().requestMusicUrlWithId(model.id);
      String artistStr = "";
      String name = "";
      for (var artist in model.artist) {
        artistStr = artistStr + artist + '、';
      }
      artistStr =
          artistStr.replaceRange(artistStr.length - 1, artistStr.length, '');
      name = model.name;
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
