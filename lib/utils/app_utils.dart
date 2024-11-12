import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class AppUtils {
  static void showToast(BuildContext context, String message, String state) {
    if (state == 'error') {
      toastification.show(
        context: context,
        title: Text(message),
        type: ToastificationType.error,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
      );
    } else if (state == 'success') {
      toastification.show(
        context: context,
        title: Text(message),
        type: ToastificationType.success,
        style: ToastificationStyle.fillColored,
        autoCloseDuration: const Duration(seconds: 3),
        alignment: Alignment.bottomCenter,
      );
    }
  }

  static void navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void navigateToAndClearStack(BuildContext context, Widget homePage) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => homePage),
      (Route<dynamic> route) => false,
    );
  }
}
