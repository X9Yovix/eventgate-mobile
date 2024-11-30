import 'package:cloud_firestore/cloud_firestore.dart';
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
    } else if (state == 'info') {
      toastification.show(
        context: context,
        title: Text(message),
        type: ToastificationType.info,
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

  static void navigateWithFade(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  static void navigateWithFadeAndClearStack(
      BuildContext context, Widget homePage) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => homePage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
      (Route<dynamic> route) => false,
    );
  }

  static void navigateWithSlideAndClearStack(
      BuildContext context, Widget homePage) {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => homePage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (Route<dynamic> route) => false,
    );
  }

  static String formatStringDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return formatDateWithDay(date);
  }

  /* static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')} "
        "${_monthToString(date.month)} "
        "${date.year}";
  } */

  static String _monthToString(int month) {
    switch (month) {
      case 1:
        return "January";
      case 2:
        return "February";
      case 3:
        return "March";
      case 4:
        return "April";
      case 5:
        return "May";
      case 6:
        return "June";
      case 7:
        return "July";
      case 8:
        return "August";
      case 9:
        return "September";
      case 10:
        return "October";
      case 11:
        return "November";
      case 12:
        return "December";
      default:
        return "";
    }
  }

  static String _dayOfWeekToString(int day) {
    switch (day) {
      case DateTime.monday:
        return "Monday";
      case DateTime.tuesday:
        return "Tuesday";
      case DateTime.wednesday:
        return "Wednesday";
      case DateTime.thursday:
        return "Thursday";
      case DateTime.friday:
        return "Friday";
      case DateTime.saturday:
        return "Saturday";
      case DateTime.sunday:
        return "Sunday";
      default:
        return "";
    }
  }

  static String formatDateWithDay(DateTime date) {
    return "${_dayOfWeekToString(date.weekday)}, "
        "${date.day.toString().padLeft(2, '0')} "
        "${_monthToString(date.month)} "
        "${date.year}";
  }

  static void navigateWithFadeAndArgs(BuildContext context, Widget page,
      {Object? arguments}) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        settings: RouteSettings(arguments: arguments),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  static String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final dateTime = timestamp.toDate();
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    switch (dateTime.weekday) {
      case 1:
        return 'Monday $hours:$minutes [${dateTime.day}-${dateTime.month}-${dateTime.year}]';
      case 2:
        return 'Tuesday $hours:$minutes [${dateTime.day}-${dateTime.month}-${dateTime.year}]';
      case 3:
        return 'Wednesday $hours:$minutes [${dateTime.day}-${dateTime.month}-${dateTime.year}]';
      case 4:
        return 'Thursday $hours:$minutes [${dateTime.day}-${dateTime.month}-${dateTime.year}]';
      case 5:
        return 'Friday $hours:$minutes [${dateTime.day}-${dateTime.month}-${dateTime.year}]';
      case 6:
        return 'Saturday $hours:$minutes [${dateTime.day}-${dateTime.month}-${dateTime.year}]';
      case 7:
        return 'Sunday $hours:$minutes [${dateTime.day}-${dateTime.month}-${dateTime.year}]';

      default:
        return 'N/A';
    }
  }
}
