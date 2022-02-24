import 'dart:io';

import 'package:flutter/material.dart';

class PublicAcount extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "使用码",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Image(image: AssetImage("images/public.png")),
            // Image.asset(
            //   "images/public.png",
            //   color: Colors.grey,
            // ),
            SizedBox(height: 20),
            Text(
              "搞机分享汇",
              style: TextStyle(color: Colors.black, fontSize: 17),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "本软件需要从该公众号回复’享乐‘获取使用码，使用码有效期48小时，失效后需要重新获取",
              style: TextStyle(color: Colors.grey,fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
