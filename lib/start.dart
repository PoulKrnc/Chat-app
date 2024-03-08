// ignore_for_file: prefer_typing_uninitialized_variables, avoid_unnecessary_containers, curly_braces_in_flow_control_structures, avoid_print, unnecessary_null_comparison, non_constant_identifier_names

import 'dart:developer';

import 'package:pavli_text/utils/utils.dart';
import 'package:pavli_text/widget_classes/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final int _selectedIndex = 1;
  String appVersion = "1.27";
  bool versionSync = true;
  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;
  var userData;
  List<dynamic> contactsList = [];
  bool isReady = false;
  bool setupsReady = false;
  Map<String, dynamic> setupsList = {};

  void setups() async {
    tokenSetup();
    await db.collection("utils").doc("version").get().then(
      (value) {
        setupsList["Version"] = value.data()!["version"];
        setState(() {
          if (value.data()!["version"] != appVersion) {
            versionSync = false;
          }
        });
      },
    );
    setState(() {
      setupsReady = true;
    });
  }

  void tokenSetup() async {
    final messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    var doc = db.collection("users").doc(user.email!);
    Map<String, dynamic> data = {};
    await doc
        .get()
        .then((DocumentSnapshot<Map<String, dynamic>> snapshot) async {
      data = snapshot.data()!;
      await FirebaseFirestore.instance
          .collection("nicknames")
          .doc(data["Nickname"])
          .update({"token": token});
    });
    await FirebaseFirestore.instance
        .collection("nicknames")
        .doc(data["Nickname"])
        .get()
        .then((value) async {
      List<dynamic> tokenList = [];

      try {
        tokenList = value.data()!["tokenList"];
      } catch (e) {
        log(e.toString());
      }
      if (!tokenList.contains(token)) {
        tokenList.add(token);
        await FirebaseFirestore.instance
            .collection("nicknames")
            .doc(data["Nickname"])
            .update({"tokenList": tokenList});
      }
      log(tokenList.toString());
    });
  }

//AAAAWCL3XpU:APA91bFxP_DGH1VXWWteQB9ov-KBLF3xzGmklUhlgQCMrw2H3laoTNAIeke6ccpPvxw7bQD9gYzTlzyy__55RKfjk6TuS3F8TnHwSwB_zJgaMhgUBmGA_5uSLkp8oAywzJd4Z74e6Yhk

  void setup() async {
    var doc = db.collection("users").doc(user.email!);
    doc.get().then((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      var data = snapshot.data();
      setState(() {
        userData = data;
        isReady = true;
      });
    });
  }

  final mFunc = FirebaseFunctions.instance;

  @override
  void initState() {
    super.initState();
    setups();
    setup();
  }

  @override
  Widget build(BuildContext context) {
    if (!versionSync) {
      return Utils.outdatedVersionScaffold();
    }
    if (!isReady || !setupsReady) {
      return Utils.loadingScaffold();
    }

    return HomePage(
      index: _selectedIndex,
      data: userData,
      setupsList: setupsList,
    );
  }
}

class User {
  String nickname;
  User({required this.nickname}) : super();
  var db = FirebaseFirestore.instance;
  String Date_born = "";
  String Mail = "";
  String Nickname = "";
  String ProfilePicUrl = "";
  String token = "";
  List tokenList = [];

  void initializeUser() {
    db.collection("nicknames").doc(nickname).get().then((value) {
      Map<String, dynamic> map = value.data()!;
      Date_born = map["Date_born"];
      Mail = map["Mail"];
      Nickname = map["Nickname"];
      ProfilePicUrl = map["ProfilePicUrl"];
      token = map["token"];
      tokenList = map["tokenList"];
    });
  }

  @override
  String toString() {
    return "$Date_born: $Mail: $Nickname: $ProfilePicUrl: $token: ";
  }
}
