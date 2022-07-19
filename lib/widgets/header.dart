import 'package:flutter/material.dart';

AppBar header(context, String titleText, double font, bool removeBackButton) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton,
    title: Text(
      titleText,
      style: TextStyle(
        color: Colors.white,
        fontSize: font,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).accentColor,
  );
}
