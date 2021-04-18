import 'package:flutter/material.dart';

class PlayWidget extends StatefulWidget {
  @override
  _PlayWidgetState createState() => _PlayWidgetState();
}

class _PlayWidgetState extends State<PlayWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '播放',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
