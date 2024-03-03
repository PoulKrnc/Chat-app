import 'package:flutter/material.dart';

class Dropdown1Page extends StatefulWidget {
  const Dropdown1Page({super.key});

  @override
  _Dropdown1PageState createState() => _Dropdown1PageState();
}

class _Dropdown1PageState extends State<Dropdown1Page>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 450));
    slideAnimation = Tween<Offset>(begin: const Offset(0.0, -4.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.decelerate));
    controller.addListener(() {
      setState(() {});
    });
    controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
        position: slideAnimation,
        child: Scaffold(
            backgroundColor: Colors.transparent,
            //appBar:AppBar(.......)
            body: Container(
                padding: const EdgeInsets.all(13.0),
                height: MediaQuery.of(context).size.height / 2.7,
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                child: const Column(
                  children: [Text("hello word")],
                ))));
  }
}
