import 'package:flutter/material.dart';
import 'package:pavli_text/main.dart';

class Testing extends StatefulWidget {
  const Testing({Key? key}) : super(key: key);

  @override
  _TestingState createState() => _TestingState();
}

class _TestingState extends State<Testing> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: GestureDetector(
          onTap: () {
            MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil(
              '/',
              (route) => (route.settings.name != '/') || route.isFirst,
            );
          },
          child: Text("Back"),
        ),
      )),
    );
  }
}
