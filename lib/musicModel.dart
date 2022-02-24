import 'package:flutter/material.dart';

class MusicModel {
  final String type;
  final String link;
  final String songid;
  final String author;
  final String title;
  final String lrc;
  final String url;
  final String pic;

  MusicModel(this.type, this.link, this.songid, this.author, this.title,
      this.lrc,this.url, this.pic);

  MusicModel.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        link = json['link'].toString(),
        songid = json['songid'].toString(),
        author = json['author'],
        title = json['title'],
        lrc = json['lrc'].toString(),
        url = json['url'].toString(),
        pic = json['pic'];

  MusicModel.fromData(Map<String, dynamic> json)
      : type = json['type'],
        link = json['link'].toString(),
        songid = json['songid'],
        author = json['author'],
        title = json['title'],
        lrc = json['lrc'].toString(),
        url = json['url'].toString(),
        pic = json['pic'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'link': link,
        'songid': songid,
        'author': author,
        'title': title,
        'lrc': lrc,
        'url': url,
        'pic': pic
      };
}
