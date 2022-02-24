import 'package:flutter/material.dart';
import 'package:freemusic_flutter/About/about.dart';
import 'package:freemusic_flutter/About/publicAcount.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 38.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ClipOval(
                      child: Image.asset(
                        "images/logo.jpg",
                        width: 80,
                        height: 80,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Text(
                    "享乐音乐",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('使用码获取'),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return PublicAcount();
                      }));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('关于软件'),
                    onTap: () {
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return About();
                      }));
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
