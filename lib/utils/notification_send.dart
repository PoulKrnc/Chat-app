import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pavli_text/main.dart';

class Application extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _Application();
}

class _Application extends State<Application> {
  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data['type'] == 'chat') {
      Navigator.pushNamed(
        context,
        '/chat',
      );
    }
  }

  @override
  void initState() {
    super.initState();

    // Run code required to handle interacted messages in an async function
    // as initState() must not be async
    setupInteractedMessage();
  }

  @override
  Widget build(BuildContext context) {
    return Text("...");
  }
}

void awesomeNotification(RemoteMessage message) async {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    log(isAllowed.toString());
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  String title = message.notification!.title.toString();
  String body = message.notification!.body.toString();
  List l = title.codeUnits;
  int r = 0;
  for (int n in l) {
    r += n;
  }

  NotificationActionButton markAsReadButton = NotificationActionButton(
      key: title,
      label: "Mark as read",
      actionType: ActionType.SilentBackgroundAction);

  NotificationActionButton answerButton = NotificationActionButton(
      key: title,
      label: "Answer",
      requireInputText: true,
      actionType: ActionType.SilentBackgroundAction);

  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/app_icon',
      [
        NotificationChannel(
            channelGroupKey: title,
            channelKey: title,
            channelName: 'Basic notifications',
            groupSort: GroupSort.Desc,
            importance: NotificationImportance.High,
            defaultPrivacy: NotificationPrivacy.Private,
            channelDescription: 'Notification channel for messages',
            defaultColor: Colors.blue,
            enableVibration: true,
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupKey: title, channelGroupName: title)
      ],
      debug: true);
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: (receivedAction) =>
        onActionReceived(receivedAction),
  );
  /*AwesomeNotifications().createNotification(
      actionButtons: [markAsReadButton, answerButton],
      content: NotificationContent(
          id: r, channelKey: "message", title: title, body: body));*/
}

@pragma('vm:entry-point')
Future<void> onActionReceived(ReceivedAction receivedAction) async {
  log(receivedAction.title.toString());
  log(receivedAction.body.toString());
  if (receivedAction.actionType == ActionType.SilentBackgroundAction) {
    log("epicc");
  }
  MyApp.navigatorKey.currentState
      ?.pushNamed('/test-page', arguments: receivedAction);
}

void notification(RemoteMessage message) async {
  var androidInitialize =
      const AndroidInitializationSettings('resource://drawable/app_icon');
  var initializationSettings =
      InitializationSettings(android: androidInitialize);
  var fln = FlutterLocalNotificationsPlugin();

  fln.initialize(
    initializationSettings,
    //onDidReceiveNotificationResponse: ((details) => notificationResponse),
    /*onDidReceiveBackgroundNotificationResponse: ((details) =>
          notificationBackgroundResponse),*/
  );
  Map<String, dynamic> map = {};
  log("message");
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
      channelAction: AndroidNotificationChannelAction.createIfNotExists,
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
}
