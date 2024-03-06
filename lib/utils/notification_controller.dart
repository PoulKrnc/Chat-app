/*import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as locals;
import 'package:http/http.dart' as http;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:pavli_text/main.dart';

class NotificationController {
  static ReceivedAction? initialAction;

  ///  *********************************************
  ///     INITIALIZATIONS
  ///  *********************************************
  ///
  static Future<void> initializeLocalNotifications() async {
    await AwesomeNotifications().initialize(
        'resource://drawable/app_icon', //
        [
          NotificationChannel(
              channelKey: "messages",
              channelName: "Messages",
              channelDescription: 'Notification tests as alerts',
              groupSort: GroupSort.Desc,
              playSound: true,
              onlyAlertOnce: true,
              groupAlertBehavior: GroupAlertBehavior.Children,
              importance: NotificationImportance.High,
              defaultPrivacy: NotificationPrivacy.Private,
              defaultColor: Colors.blue,
              ledColor: Colors.white)
        ],
        debug: true);

    // Get initial notification action is optional
    initialAction = await AwesomeNotifications()
        .getInitialNotificationAction(removeFromActionEvents: false);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS LISTENER
  ///  *********************************************
  ///  Notifications events are only delivered after call this method
  @pragma('vm:entry-point')
  static Future<void> startListeningNotificationEvents() async {
    AwesomeNotifications().setListeners(
        onActionReceivedMethod: onActionReceivedMethod,
        onDismissActionReceivedMethod: dissmisAction,
        onNotificationCreatedMethod: notificationCreatedAction);
  }

  ///  *********************************************
  ///     NOTIFICATION EVENTS
  ///  *********************************************
  ///
  static Future<void> notificationCreatedAction(
      ReceivedNotification receivedNotification) async {
    log(receivedNotification.body.toString());
  }

  static Future<void> dissmisAction(ReceivedAction receivedAction) async {
    log("Dismiss Action");
    log(receivedAction.body.toString());
  }

  ///  *********************************************
  ///     REQUESTING NOTIFICATION PERMISSIONS
  ///  *********************************************
  ///

  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = MyApp.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(child: Icon(Icons.notifications)),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Allow PavliText to send you notifications!'),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Deny',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.red),
                  )),
              TextButton(
                  onPressed: () async {
                    userAuthorized = true;
                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    'Allow',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: Colors.deepPurple),
                  )),
            ],
          );
        });
    return userAuthorized &&
        await AwesomeNotifications().requestPermissionToSendNotifications();
  }

  ///  *********************************************
  ///     NOTIFICATION CREATION METHODS
  ///  *********************************************
  ///
  @pragma("vm:entry-point")
  static Future<void> createNewNotification(RemoteMessage message) async {
    String title = message.notification!.title.toString();

    String body = message.notification!.body.toString();
    List l = title.codeUnits;
    int r = 0;
    for (int n in l) {
      r += n;
    }

    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();
    if (!isAllowed) return;

    await AwesomeNotifications().setChannel(
      NotificationChannel(
          channelKey: "messages",
          channelName: "Messages",
          channelDescription: "Channel for messages",
          channelGroupKey: title,
          groupKey: title,
          playSound: true,
          onlyAlertOnce: true,
          groupAlertBehavior: GroupAlertBehavior.Summary,
          importance: NotificationImportance.High,
          defaultPrivacy: NotificationPrivacy.Private,
          defaultColor: Colors.blue,
          ledColor: Colors.white),
    );
    String str = "none";
    var tls = await AwesomeNotifications().getAppLifeCycle();
    if (tls == NotificationLifeCycle.Foreground) {
      str = "foreground";
    } else if (tls == NotificationLifeCycle.Background) {
      str = "background";
    } else if (tls == NotificationLifeCycle.Terminated) {
      str = "terminated";
    }

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
          id: -1, // -1 is replaced by a random number
          channelKey: "messages",
          title: title,
          groupKey: title,
          body: body + "  " + str,
          //'asset://assets/images/balloons-in-sky.jpg',
          notificationLayout: NotificationLayout.Default,
          category: NotificationCategory.Message,
          payload: {"sender": title, "text": body}),
      actionButtons: [
        NotificationActionButton(
            key: 'ANSWER',
            label: 'Answer',
            requireInputText: true,
            autoDismissible: false,
            actionType: ActionType.SilentAction),
        NotificationActionButton(
            key: 'MARK-AS-READ',
            label: 'Mark as read',
            actionType: ActionType.SilentBackgroundAction)
      ],
    );
  }

  static Future<void> resetBadgeCounter() async {
    await AwesomeNotifications().resetGlobalBadge();
  }

  static Future<void> cancelNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  log("Action received");
  if (receivedAction.actionType == ActionType.SilentAction ||
      receivedAction.actionType == ActionType.SilentBackgroundAction) {
    // For background actions, you must hold the execution until the end
    log('Message sent via notification input: "${receivedAction.buttonKeyInput}"');
    if (receivedAction.buttonKeyPressed == 'MARK-AS-READ') {
      log("Mark as read");
      await markAsRead(receivedAction);
    } else if (receivedAction.buttonKeyPressed == 'ANSWER') {
      log("Answer");
      await sendMessageBack(receivedAction);
    } else {
      log("No specified action");
    }
  } else {}
}

///  *********************************************
///     BACKGROUND TASKS
///  *********************************************
@pragma("vm:entry-point")
Future<void> markAsRead(ReceivedAction message) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    return;
  }
  String user = auth.currentUser!.email!;
  var doc = await db.collection("users").doc(user).get();
  String userNickname = doc.data()!["Nickname"];

  db
      .collection("nicknames")
      .doc(userNickname)
      .collection("contacts")
      .doc(message.title.toString())
      .get()
      .then((value) {
    List lst = value.data()!["ViewedBy"];
    if (!lst.contains(userNickname)) {
      lst.add(userNickname);
    }
    db
        .collection("nicknames")
        .doc(userNickname)
        .collection("contacts")
        .doc(message.title.toString())
        .update({"ViewedBy": lst});
    db
        .collection("nicknames")
        .doc(message.title.toString())
        .collection("contacts")
        .doc(userNickname)
        .update({"ViewedBy": lst});
  });
}

@pragma("vm:entry-point")
Future<void> sendMessageBack(ReceivedAction message) async {
  FirebaseFirestore db = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  String text = message.buttonKeyInput.toString();
  if (auth.currentUser == null) {
    return;
  }
  String user = auth.currentUser!.email!;
  var doc = await db.collection("users").doc(user).get();

  String userNickname = doc.data()!["Nickname"];
  var contactInfo = await db
      .collection("nicknames")
      .doc(userNickname)
      .collection("contacts")
      .doc(message.title.toString())
      .get();

  await db
      .collection("chats")
      .doc(contactInfo.data()!["ChatName"].toString())
      .collection("chats")
      .add({
    "Text": text,
    "Sender": userNickname,
    "Date": FieldValue.serverTimestamp(),
    "ReplyText": "",
    "ReplySender": ""
  });

  var time = Timestamp.now();
  await db
      .collection("nicknames")
      .doc(userNickname)
      .collection("contacts")
      .doc(message.title)
      .update({
    "LastChatDate": time,
    "LastChat": message.body,
    "LastChatSender": userNickname
  });
  await db
      .collection("nicknames")
      .doc(message.title)
      .collection("contacts")
      .doc(userNickname)
      .update({
    "LastChatDate": time,
    "LastChat": message.body,
    "LastChatSender": userNickname
  });
}
*/