import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String? msg, FToast fToast,
    {Color toastColor = Colors.green,
      int seconds = 2,
      ToastGravity toastGravity = ToastGravity.BOTTOM,
      double fontSize = 15.0,
      Color bgColor = Colors.black54}) {

  if (msg != null) {
    final Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: bgColor,
      ),
      child: Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: toastColor,
          fontSize: fontSize,
          fontFamily: 'Lora',
          letterSpacing: 1.0,
          fontWeight: FontWeight.w400,
        ),
      ),
    );

    fToast.showToast(
      child: toast,
      gravity: toastGravity,
      toastDuration: Duration(seconds: seconds),
    );
  }
}