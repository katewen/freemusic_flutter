import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "关于我们",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "images/music.png",
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              "享乐音乐",
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "本软件仅供学习交流使用，请勿传播商用，如果软件内容侵犯了您的合法权益，请联系我们删除",
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            Text(
              "QQ：773522733",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            )
          ],
        ),
      ),
    );
  }
}
