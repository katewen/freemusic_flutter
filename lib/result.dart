import 'package:flutter/material.dart';
import 'package:freemusic_flutter/dataManager.dart';
import 'package:freemusic_flutter/listItem.dart';
import 'package:freemusic_flutter/musicModel.dart';
import 'package:freemusic_flutter/networkManager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SearchResult extends StatefulWidget {
  SearchResult({Key key, this.searchWord, this.source}) : super(key: key);
  String searchWord;
  String source;

  _SearchResultState createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  List<MusicModel> resultList = [];
  List musicList = [];
  int pages = 1;
  void initState() {
    super.initState();
    _requestResultList();
    _queryAllMusicList();
  }

  Future<void> _requestResultList() async {
    NetworkManager networkManager = new NetworkManager();
    Future<List> modelList = networkManager.requestListWithName(
        widget.searchWord, pages, widget.source);
    for (var json in await modelList) {
      MusicModel model = MusicModel.fromJson(json);
      resultList.insert(resultList.length, model);
    }
    // setState(() async {});
    setState(() {});
  }

  void _queryAllMusicList() async {
    var list = await DataManager().queryAllTableFromDB();
    musicList = [];
    for (var map in list) {
      if (map["name"] != "sqlite_sequence" &&
          map["name"] != "android_metedata") {
        musicList.add(map);
      }
    }
    setState(() {});
  }

  void _showMusicListAlert(int musicIndex) async {
    int selectIndex = await showDialog(
        context: context,
        builder: (BuildContext context) {
          var child = Column(
            children: [
              Align(
                  child: ListTile(
                    title: Text('请选择歌单'),
                    trailing: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          '取消',
                          style: TextStyle(color: Colors.grey),
                        )),
                  ),
                  alignment: Alignment.bottomCenter),
              Expanded(
                  child: ListView.builder(
                      itemBuilder: (context, index) {
                        return Align(
                            alignment: Alignment.center,
                            child: ListTile(
                                title: Text(
                                  musicList[index]['name'],
                                  textAlign: TextAlign.center,
                                ),
                                onTap: () => Navigator.of(context).pop(index)));
                      },
                      itemCount: musicList.length))
            ],
          );
          return Dialog(
            child: child,
          );
        });
    if (selectIndex != null) {
      DataManager().insertModelToTable(
          resultList[musicIndex], musicList[selectIndex]['name']);
      Fluttertoast.showToast(
        msg: "添加到歌单成功",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.searchWord),
      ),
      body: Center(
        child: ListView.separated(
          itemBuilder: (context, index) {
            if (index == resultList.length - 1) {
              pages += 1;
              _requestResultList();
              //加载时显示loading
              return Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(strokeWidth: 2.0)),
              );
            }
            var listIem = ListItem(model: resultList[index]);
            listIem.onFavorited = () {
              _showMusicListAlert(index);
            };
            return listIem;
          },
          itemCount: resultList.length,
          separatorBuilder: (context, index) {
            return Divider(color: Colors.grey);
          },
        ),
      ),
    );
  }
}
