import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TextButtonTopImage extends StatelessWidget {
  TextButtonTopImage({Key key, this.buttonTitle, this.buttonImage})
      : super(key: key);

  final String buttonTitle;
  final String buttonImage;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: Column(
        children: [
          ImageIcon(
            AssetImage(this.buttonImage),
            size: 50.0,
          ),
          Text(this.buttonTitle)
        ],
      ),
    );
  }
}
