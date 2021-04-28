import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

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
}
