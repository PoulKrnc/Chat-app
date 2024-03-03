import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pavli_text/start.dart' as start;
import 'package:pavli_text/testing.dart';
import 'package:pavli_text/utils/notification_controller.dart';
import 'package:pavli_text/utils/notification_send.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:pavli_text/auth/verify_email_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:pavli_text/auth/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'firebase_options.dart';
import 'package:adaptive_theme/adaptive_theme.dart';

//
//_________________________________MAIN FUNC____________________________________
//
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //
  // firebase initialization
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final savedThemeMode = await AdaptiveTheme.getThemeMode();

  await NotificationController.initializeLocalNotifications();
  await NotificationController.initializeIsolateReceivePort();

  // ignore: prefer_const_constructors
  runApp(MyApp(
    savedThemeMode: savedThemeMode,
  ));
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  final AdaptiveThemeMode? savedThemeMode;

  const MyApp({super.key, required this.savedThemeMode});

  @override
  // ignore: library_private_types_in_public_api
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();
  @pragma("vm:entry-point")
  static void notificationResponse(NotificationResponse payload) {
    log("sumthing");
    log(payload.notificationResponseType.name);
    MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/contacts-page',
        (route) => (route.settings.name != '/contacts-page') || route.isFirst,
        arguments: payload);
  }

  @override
  void initState() {
    //notificationInfo();
    NotificationController.startListeningNotificationEvents();
    awesomeNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      //light: ThemeData(),
      light: ThemeData.light(useMaterial3: false),
      dark: ThemeData.dark(useMaterial3: false),
      initial: widget.savedThemeMode ?? AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        scaffoldMessengerKey: messengerKey,
        title: 'App',
        theme: theme,
        darkTheme: darkTheme,
        initialRoute: "/",
        routes: {
          "/": ((context) => const MyMainPage(title: "App")),
          "/contacts-page": (context) => const start.StartPage(),
          "/test-page": (context) => const Testing()
        },
        /*home: MyMainPage(title: 'App'),*/
      ),
    );
  }

  void awesomeNotifications() async {
    FirebaseMessaging.onMessage.listen((message) async {
      log("_____________________onMessage______________________");
      log("onMessageBeta: ${message.notification?.title}/${message.notification?.body}");
      NotificationController.createNewNotification(RemoteMessage(
          notification: RemoteNotification(
              title: message.notification?.title,
              body: message.notification?.body)));
      //awesomeNotification(message);
    });
  }

  void notificationInfo() async {
    var androidInitialize = const AndroidInitializationSettings("ic_launcher");
    var initializationSettings =
        InitializationSettings(android: androidInitialize);
    fln.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: ((details) => notificationResponse),
      /*onDidReceiveBackgroundNotificationResponse: ((details) =>
          notificationBackgroundResponse),*/
    );
    Map<String, dynamic> map = {};
    log("message");
    FirebaseMessaging.onMessage.listen((message) async {
      //log("_____________________onMessage______________________");
      log("onMessageBeta: ${message.notification?.title}/${message.notification?.body}");
      String title = message.notification!.title.toString();
      String body = message.notification!.body.toString();
      List l = title.codeUnits;
      int r = 0;
      for (int n in l) {
        r += n;
      }
      if (map.containsKey(title)) {
        map[title].add(body);
      } else {
        map.addAll({
          title: [body]
        });
      }

      var inboxTextStyleInformation = InboxStyleInformation(
        map[title],
        htmlFormatContent: true,
        contentTitle: title,
        htmlFormatContentTitle: true,
      );

      AndroidNotificationAction ana1 = const AndroidNotificationAction(
          "markasread", "Mark as read",
          contextual: true, cancelNotification: true);
      AndroidNotificationAction ana2 = const AndroidNotificationAction(
          "answer", "Answer",
          inputs: [AndroidNotificationActionInput(label: "Input message")]);

      var androidNotificationDetails = AndroidNotificationDetails(title, title,
          groupKey: title,
          icon: "ic_launcher",
          channelAction: AndroidNotificationChannelAction.update,
          importance: Importance.max,
          styleInformation: inboxTextStyleInformation,
          priority: Priority.max,
          playSound: true,
          onlyAlertOnce: true,
          color: Colors.blue,
          actions: [ana1, ana2]);

      var platformChannelSpecifics =
          NotificationDetails(android: androidNotificationDetails);

      log(androidNotificationDetails.icon.toString());

      await fln.show(r, title, body, platformChannelSpecifics,
          payload: message.data["title"]);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      log("message opened app");
    });
  }
}

/*@pragma("vm:entry-point")
void notificationResponse(NotificationResponse payload) {
  log("sumthing");
  log(payload.notificationResponseType.name);
  MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/contacts-page',
      (route) => (route.settings.name != '/contacts-page') || route.isFirst,
      arguments: payload);
}*/

/*@pragma("vm:entry-point")
void notificationBackgroundResponse(NotificationResponse payload) {
  log("nuthing");
  log(payload.notificationResponseType.name);
  /*MyApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/contacts-page',
      (route) => (route.settings.name != '/contacts-page') || route.isFirst,
      arguments: payload);*/
}*/

class MyMainPage extends StatefulWidget {
  const MyMainPage({super.key, required this.title});

  final String title;

  @override
  State<MyMainPage> createState() => _MyMainPageState();
}

class _MyMainPageState extends State<MyMainPage> {
  //
  // if user is signed up the app goes to __email verification widget__
  //
  // else it takes him to widget responsibile for __authentication__
  //
  final bool logedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // __email verification widget__
            return const VerifyEmailPage();
          } else {
            // __authentication__
            return const AuthPage();
          }
        },
      ),
    );
  }
}
