// ignore_for_file: prefer_typing_uninitialized_variables, avoid_unnecessary_containers, curly_braces_in_flow_control_structures, avoid_print, unnecessary_null_comparison, non_constant_identifier_names

import 'dart:developer';

import 'package:pavli_text/utils/utils.dart';
import 'package:pavli_text/widget_classes/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_functions/cloud_functions.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  int _selectedIndex = 1;
  String appVersion = "1.27";
  bool versionSync = true;

  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;
  var userData;
  List<dynamic> contactsList = [];
  String str1 = "";
  String imageUrl = "";

  bool contactsAreReady = false;
  bool isReady = false;
  bool setupsReady = false;
  Map<String, dynamic> setupsList = {};

  void setups() async {
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

  Future messaging() async {
    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print("User granted premission");
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print("Provisional premision");
    } else {
      print("No premision");
    }
    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }
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
    });

    if (kDebugMode) {
      //print('Registration Token=$token');
    }
  }

  late FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();

  void notificationInfo() async {
    await messaging();
    var androidInitialize =
        const AndroidInitializationSettings("@mipmap/ic_launcher");
    //var iOSInitialize = IOSInitializationSetting();
    var initializationSettings =
        InitializationSettings(android: androidInitialize);
    fln.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: ((payload) async {
        log("sumthing");
        log(payload.input.toString());
      }),
      onDidReceiveBackgroundNotificationResponse: (details) async {
        log("123");
        log(details.input.toString());
      },
    );

    FirebaseMessaging.onMessage.listen((message) async {
      //log("_____________________onMessage______________________");
      log("onMessage: ${message.notification?.title}/${message.notification?.body}");
      var bigTextStyleInformation = BigTextStyleInformation(
          message.notification!.body.toString(),
          htmlFormatBigText: true,
          contentTitle: message.notification!.title.toString(),
          htmlFormatContentTitle: true);
      List l = message.notification!.body.toString().codeUnits;
      int r = 0;
      for (int n in l) {
        r += n;
      }
      setState(() {
        _selectedIndex = 0;
      });
      var androidNotificationDetails = AndroidNotificationDetails(
          message.notification!.body.toString(), "app_notification",
          groupKey: message.notification!.body.toString(),
          importance: Importance.max,
          styleInformation: bigTextStyleInformation,
          priority: Priority.max,
          playSound: true,
          color: Colors.blue,
          actions: [
            const AndroidNotificationAction(
              "markasread",
              "Mark as read",
            ),
            const AndroidNotificationAction("answer", "Answer", inputs: [
              AndroidNotificationActionInput(label: "Input message")
            ])
          ]);

      var platformChannelSpecifics =
          NotificationDetails(android: androidNotificationDetails);

      /*await fln.show(r, message.notification?.title, message.notification?.body,
          platformChannelSpecifics,
          payload: message.data["title"]);
      log((await fln.getActiveNotifications()).toString());
      var aflns = await fln.getActiveNotifications();
      log(aflns.length.toString());
      ActiveNotification fln1 = aflns[0];
      log("${fln1.title} : ${fln1.body} : ${fln1.channelId} : ");*/
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
    messaging();
    Map<String, dynamic> parameters = {"text": "test", "push": true};
    /*mFunc.httpsCallable("sayHi").call().then((value) {
      log(value.data.toString());
    });*/
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
