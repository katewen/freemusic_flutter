import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:freemusic_flutter/networkManager.dart';

class SearchWidght extends StatelessWidget {
  TextEditingController _editingController = TextEditingController();
  List musicList;
  Future<void> _searchMusic(String musicName) async {
    NetworkManager networkManager = new NetworkManager();
    musicList =
        (await networkManager.requestListWithName(musicName)) as List<dynamic>;
    print(musicList);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '搜索',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            TextField(
              style: TextStyle(fontSize: 14),
              autofocus: true,
              controller: _editingController,
              decoration: InputDecoration(
                  hintText: "输入音乐名，专辑或歌手名",
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
              onSubmitted: _searchMusic,
            ),
          ],
        ),
      ),
    );
  }
}
