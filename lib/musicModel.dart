import 'package:flutter/material.dart';

class MusicModel {
  final int id;
  final String name;
  final List<dynamic> artist;
  final String album;
  final String pic_id;
  final int url_id;
  final int lyric_id;
  final String source;

  MusicModel(this.id, this.name, this.artist, this.album, this.pic_id,
      this.url_id, this.lyric_id, this.source);

  MusicModel.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        id = json['id'],
        artist = json['artist'],
        album = json['album'],
        pic_id = json['pic_id'],
        url_id = json['url_id'],
        lyric_id = json['lyric_id'],
        source = json['source'];

  MusicModel.fromData(Map<String, dynamic> json)
      : name = json['name'],
        id = int.parse(json['musicId']),
        artist = [json['artist']],
        album = json['album'],
        pic_id = json['pic_id'],
        url_id = int.parse(json['url_id']),
        lyric_id = int.parse(json['lyric_id']),
        source = json['source'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'id': id,
        'artist': artist,
        'album': album,
        'pic_id': pic_id,
        'lyric_id': lyric_id,
        'url_id': url_id,
        'source': source
      };
}
