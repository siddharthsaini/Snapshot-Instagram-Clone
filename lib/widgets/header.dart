import 'package:flutter/material.dart';

Widget buildBar(context, {String title, FontWeight weight, bool removeBack = false}) { //(BuildContext context)
  return new AppBar(
    title: new Text(
      title,
      style: TextStyle(
        fontWeight: weight,
      ),
    ),
    centerTitle: true,
    automaticallyImplyLeading: removeBack ? false : true,
  );
}
