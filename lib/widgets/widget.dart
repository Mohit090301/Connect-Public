import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context)
{
  return  AppBar(
    centerTitle: true,
    backgroundColor: Colors.teal[900],
    title: Text(
      "Let's Connect",
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w500,
        color: Colors.white70
      ),
    ),
    brightness: Brightness.dark,
  );
}

InputDecoration textFieldInputDecoration(String hint)
{
  return InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 10),
    hintText: hint,
    hintStyle: TextStyle(
      color: Colors.white54,
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
      ),
    ),
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(
        color: Colors.white,
      ),
    ),
  );
}

TextStyle simpleTextStyle(){
  return TextStyle(
    color: Colors.white,
    fontSize: 14,
  );
}

TextStyle mediumTextStyle(){
  return TextStyle(
    color: Colors.white,
    fontSize: 16,
  );
}