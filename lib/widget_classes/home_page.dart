import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pavli_text/widget_classes/game_page.dart';
import 'contacts_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> setupsList;
  final int index;
  const HomePage(
      {super.key,
      required this.data,
      required this.setupsList,
      required this.index});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1;
  var db = FirebaseFirestore.instance;
  var data1;
  PageController _pageController = PageController(initialPage: 1);
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    userData = widget.data;
    setState(() {
      _selectedIndex = widget.index;
      _pageController = PageController(initialPage: widget.index);
    });
  }

  void setData() async {
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .get()
        .then((value) {
      setState(() {
        userData = value.data()!;
      });
    });
  }

  String str1 = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: <Widget>[
            GamePage(
              data: userData,
              setupsList: widget.setupsList,
            ),
            ContactsPage(
              data: userData,
              setupsList: widget.setupsList,
            ),
            ProfilePage(
                data: userData, setupsList: widget.setupsList, setData: setData)
          ],
        ),
        bottomNavigationBar: _bottomNavigationBar());
  }

  ClipRRect _bottomNavigationBar() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.gamepad), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
        backgroundColor: Colors.blue,
        unselectedFontSize: 0,
        selectedFontSize: 1,
        unselectedIconTheme: const IconThemeData(
          size: 24,
        ),
        selectedIconTheme: const IconThemeData(size: 30, shadows: <Shadow>[
          Shadow(offset: Offset(3, 3), blurRadius: 1.5, color: Colors.black54)
        ]),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(index,
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
