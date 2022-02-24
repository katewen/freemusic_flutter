import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freemusic_flutter/codeManager.dart';
import 'package:freemusic_flutter/networkManager.dart';
import 'package:freemusic_flutter/result.dart';
import 'package:freemusic_flutter/weView.dart';

class SearchWidght extends StatefulWidget {
  SearchWidghtState createState() => SearchWidghtState();
}

class SearchWidghtState extends State<SearchWidght> {

  bool isFinishLoad = false;

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
      if (WebMain().flutterWebViewPlugin != null) {
        WebMain().flutterWebViewPlugin.show();
      } 
    } else {
      isShowVer = false;
    }
    
    setState(() {
      
    });
  }

  TextEditingController _editingController = TextEditingController();
  List musicList;

  // 默认网易云
  String selectedPlatform = 'netease';


  Future<void> _searchMusic(String musicName) async {
    // NetworkManager networkManager = new NetworkManager();
    // musicList =
    //     (await networkManager.requestListWithName(musicName,1)) as List<dynamic>;
    // print(musicList);
  }

  TextEditingController _editingCodeController = TextEditingController();

  void verCode(String code) {
    CodeManager().isCodeValid(code);
  }

  Future<bool> _showCodeAlert() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('输入使用码'),
            content: Container(
              height: 40,
              width: 150,
              child: TextField(
                style: TextStyle(
                  fontSize: 14,
                ),
                autofocus: true,
                controller: _editingCodeController,
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.zero,
                    hintText: "输入使用码",
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
                onSubmitted: verCode,
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('取消')),
              TextButton(
                  onPressed: () async {
                    if (await CodeManager().isCodeValid(_editingCodeController.text)) {
                      Fluttertoast.showToast(
                        msg: "使用码正确请开始使用吧",
                      );
                      Navigator.of(context).pop();
                    } else {
                      Fluttertoast.showToast(
                        msg: "使用码不正确",
                      );
                    }
                  },
                  child: Text('确定'))
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return isShowVer ? WebMain() : Scaffold(
      appBar: AppBar(
        title: Text(
          '搜索',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
                height: 60,
                width: MediaQuery.of(context).size.width - 40,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TextField(
                      style: TextStyle(fontSize: 14),
                      autofocus: true,
                      controller: _editingController,
                      decoration: InputDecoration(
                          hintText: "输入音乐名，专辑或歌手名",
                          prefixIcon: Icon(Icons.search),
                          contentPadding: EdgeInsets.zero,
                          disabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(color: Colors.grey)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(color: Colors.grey)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                              borderSide: BorderSide(color: Colors.grey))),
                      maxLines: 1,
                      onSubmitted: (String content) async {
                        if (await CodeManager().isShowAlert()) {
                          _showCodeAlert();
                          return;
                        }
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return SearchResult(
                            searchWord: content,
                            source: selectedPlatform,
                          );
                        }));
                      }),
                )),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Checkbox(
                    value:selectedPlatform=='netease',
                    onChanged: (bool newValue) {
                      if (newValue) {
                        selectedPlatform = 'netease';
                      }
                      setState(() {
                        
                      });
                    }),
                Text(
                  '芸',
                  style: TextStyle(
                      color: selectedPlatform != 'netease' ? Colors.grey : Colors.blue),
                  textAlign: TextAlign.left,
                ),
                // TextButton(
                //     onPressed: () {},
                //     child: Text(
                //       '网易云',
                //       style: TextStyle(color: Colors.grey),
                //       textAlign: TextAlign.left,
                //     )),
                Checkbox(
                    value:selectedPlatform=='kugou',
                    onChanged: (bool newValue) {
                      if (newValue) {
                        selectedPlatform = 'kugou';
                      }
                      setState(() {
                        
                      });
                    }),
                Text(
                  '豿',
                  style: TextStyle(
                      color: selectedPlatform != 'kugou' ? Colors.grey : Colors.blue),
                  textAlign: TextAlign.left,
                ),
                // TextButton(
                //     onPressed: () {},
                //     child: Text(
                //       '酷狗',
                //       style: TextStyle(color: Colors.grey),
                //       textAlign: TextAlign.left,
                //     )),
                Checkbox(
                    value:selectedPlatform=='kuwo',
                    onChanged: (bool newValue) {
                      if (newValue) {
                        selectedPlatform = 'kuwo';
                      }
                      setState(() {
                        
                      });
                    }),
                Text(
                  '渥',
                  style: TextStyle(
                      color: selectedPlatform != 'kuwo' ?  Colors.grey : Colors.blue),
                  textAlign: TextAlign.left,
                ),
                Checkbox(
                    value:selectedPlatform=='baidu',
                    onChanged: (bool newValue) {
                      if (newValue) {
                        selectedPlatform = 'baidu';
                      }
                      setState(() {
                        
                      });
                    }),
                Text(
                  '荰',
                  style: TextStyle(
                      color: selectedPlatform != 'baidu' ? Colors.grey : Colors.blue),
                  textAlign: TextAlign.left,
                ),
                Checkbox(
                    value:selectedPlatform=='migu',
                    onChanged: (bool newValue) {
                      if (newValue) {
                        selectedPlatform = 'migu';
                      }
                      setState(() {
                        
                      });
                    }),
                Text(
                  '沽',
                  style: TextStyle(
                      color: selectedPlatform != 'migu' ? Colors.grey : Colors.blue),
                  textAlign: TextAlign.left,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
