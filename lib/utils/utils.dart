// ignore_for_file: unnecessary_null_comparison, unused_element, deprecated_member_use, avoid_print

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:pavli_text/start.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final messengerKey = GlobalKey<ScaffoldMessengerState>();

printY(String text) {
  print('\x1B[33m$text\x1B[0m');
}

class Utils {
  static showSnackBar(String? text) {
    if (text == null) return;

    final snackBar = SnackBar(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      dismissDirection: DismissDirection.horizontal,
      content: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      backgroundColor: Colors.blue,
    );

    messengerKey.currentState!
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  /*
  static StreamTransformer transformer<T>(
          T Function(Map<String, dynamic> json) fromJson) =>
      StreamTransformer<QuerySnapshot, List<T>>.fromHandlers(
        handleData: (QuerySnapshot data, EventSink<List<T>> sink) {
          final snaps = data.docs.map((doc) => doc.data()).toList();
          final users = snaps.map((json) => fromJson(json)).toList();

          sink.add(users);
        },
      );
  */
  static DateTime toDateTime(Timestamp value) {
    return value.toDate();
  }

  static dynamic fromDateTimeToJson(DateTime date) {
    if (date == null) return null;

    return date.toUtc();
  }

  static WillPopScope loadingScaffold() {
    return WillPopScope(
        onWillPop: () {
          const StartPage();
          return Future(() => false);
        },
        child: const Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(),
              Row(
                children: [
                  Spacer(),
                  CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                  /*Text(
                    "Loading...",
                    style: TextStyle(
                        color: Colors.blue, fontWeight: FontWeight.bold),
                  ),*/
                  Spacer()
                ],
              ),
              Spacer(),
              Text(
                "If the page doesnt load try restarting the application or check your intrenet connection.",
                style: TextStyle(fontSize: 10),
              )
            ],
          ),
        ));
  }

  static Scaffold outdatedVersionScaffold() {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(),
          Row(
            children: [
              Spacer(),
              Text(
                "Update the app.",
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
              Spacer()
            ],
          ),
          Spacer(),
        ],
      ),
    );
  }

  static Future<bool> onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit an App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }
}

class LoadingIndicatorFb1 extends StatelessWidget {
  const LoadingIndicatorFb1({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator();
  }
}

dynamic isLightMode(BuildContext context, {dynamic lWidget, dynamic dWidget}) {
  if (AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light) {
    return lWidget;
  }
  return dWidget;
}

void unFocusKeyboard() {
  FocusManager.instance.primaryFocus?.unfocus();
}
