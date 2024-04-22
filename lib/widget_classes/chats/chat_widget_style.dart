// ignore_for_file: prefer_typing_uninitialized_variables, library_private_types_in_public_api

import 'dart:developer';
import 'dart:io';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:downloadsfolder/downloadsfolder.dart' as downloadFolder;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StyleDialogItem extends StatefulWidget {
  const StyleDialogItem({super.key, required this.child});
  final child;

  @override
  _StyleDialogItemState createState() => _StyleDialogItemState();
}

class _StyleDialogItemState extends State<StyleDialogItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      margin: const EdgeInsets.fromLTRB(50, 4, 50, 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: isLightMode(
          context,
          lWidget: Colors.grey[200],
          dWidget: Colors.grey[800],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.child,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

class ChatWidgetStyle extends StatefulWidget {
  const ChatWidgetStyle(
      {super.key,
      required this.chatSticker,
      required this.doc,
      required this.previousSender,
      required this.scaleFactor,
      required this.contact,
      required this.user});
  final previousSender;
  final chatSticker;
  final doc;
  final scaleFactor;
  final contact;
  final user;
  @override
  _ChatWidgetStyleState createState() => _ChatWidgetStyleState();
}

class _ChatWidgetStyleState extends State<ChatWidgetStyle> {
  var db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int scaleFactor = 1;

  Future<void> downloadNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        const InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadNotification();
  }

  void fileDownload() async {
    log("fileDownload");
    Reference storageRef = storage.refFromURL(widget.doc["ImageSrc"]);
    String fileUrl = await storageRef.getDownloadURL();
    log(fileUrl);
    String? downloadDirectoryPath =
        await downloadFolder.getDownloadDirectoryPath();
    String filePath = "$downloadDirectoryPath/${storageRef.name}";
    File file = File(filePath);
    //await file.create(recursive: true, exclusive: false);

    final downloadTask = storageRef.writeToFile(file);
    NotificationDetails nd = const NotificationDetails(
        android: AndroidNotificationDetails("downloadstatus", "Download Status",
            enableVibration: false, silent: true, playSound: false));
    flutterLocalNotificationsPlugin.show(
        100, "PavliText", "Downloading File", nd);
    downloadTask.snapshotEvents.listen((taskSnapshot) {
      switch (taskSnapshot.state) {
        case TaskState.running:
          fileDownloadState("running");
          flutterLocalNotificationsPlugin.show(
              100,
              "PavliText",
              "Downloading File",
              NotificationDetails(
                  android: AndroidNotificationDetails(
                      "downloadstatus", "Download Status",
                      enableVibration: false,
                      playSound: false,
                      showProgress: true,
                      silent: true,
                      progress: taskSnapshot.bytesTransferred,
                      maxProgress: taskSnapshot.totalBytes)));
          break;
        case TaskState.paused:
          fileDownloadState("paused");
          flutterLocalNotificationsPlugin.show(
              100,
              "PavliText",
              "Download was canceled",
              const NotificationDetails(
                  android: AndroidNotificationDetails(
                "downloadstatus",
                "Download Status",
                enableVibration: false,
                playSound: false,
                silent: true,
              )));
          break;
        case TaskState.success:
          fileDownloadState("success");
          flutterLocalNotificationsPlugin.show(
              100,
              "PavliText",
              "Download successful",
              const NotificationDetails(
                  android: AndroidNotificationDetails(
                "downloadstatus",
                "Download Status",
                enableVibration: false,
                playSound: false,
                silent: true,
              )));
          break;
        case TaskState.canceled:
          fileDownloadState("canceled");
          flutterLocalNotificationsPlugin.show(
              100,
              "PavliText",
              "Download was canceled",
              const NotificationDetails(
                  android: AndroidNotificationDetails(
                "downloadstatus",
                "Download Status",
                enableVibration: false,
                playSound: false,
                silent: true,
              )));
          break;
        case TaskState.error:
          fileDownloadState("error");
          flutterLocalNotificationsPlugin.show(
              100,
              "PavliText",
              "Download failed",
              const NotificationDetails(
                  android: AndroidNotificationDetails(
                "downloadstatus",
                "Download Status",
                enableVibration: false,
                playSound: false,
                silent: true,
              )));
          break;
      }
    });
  }

  void fileDownloadState(String code) {
    log(code);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(),
      child: Column(
        children: [
          widget.previousSender != "App"
              ? widget.chatSticker
                  ? Container()
                  : Container(
                      height: 7,
                      margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      decoration: BoxDecoration(
                        borderRadius: widget.chatSticker
                            ? null
                            : const BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6)),
                        color: isLightMode(
                          context,
                          lWidget: Colors.grey[200],
                          dWidget: Colors.grey[800],
                        ),
                      ),
                    )
              : Container(),
          (Container(
            decoration: BoxDecoration(
                border: Border.all(
                  width: 0.1,
                  color: isLightMode(
                    context,
                    lWidget: Colors.grey[200],
                    dWidget: Colors.grey[800],
                  ),
                ),
                borderRadius: widget.chatSticker
                    ? null
                    : const BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6)),
                color: isLightMode(
                  context,
                  lWidget: Colors.grey[200],
                  dWidget: Colors.grey[800],
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    color: isLightMode(
                      context,
                      lWidget: Colors.grey[200],
                      dWidget: Colors.grey[800],
                    ),
                  )
                ]),
            padding: widget.chatSticker
                ? const EdgeInsets.fromLTRB(5, 0, 5, 0)
                : const EdgeInsets.fromLTRB(5, 2, 5, 0),
            margin: widget.chatSticker
                ? const EdgeInsets.fromLTRB(10, 0, 10, 0)
                : const EdgeInsets.fromLTRB(10, 10, 10, 0),
            width: double.infinity,
            child: Column(
              children: [
                Column(
                  children: [
                    widget.chatSticker
                        ? const SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.doc["Sender"].toString(),
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                                textScaler:
                                    TextScaler.linear(widget.scaleFactor),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                timestampToDate(widget.doc["Date"]),
                                style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold),
                                textScaler:
                                    TextScaler.linear(widget.scaleFactor),
                              ),
                            ],
                          ),
                    if (widget.doc["ReplyText"] != "" &&
                        widget.doc["ReplySender"] != "") ...[
                      Container(
                        padding: const EdgeInsets.fromLTRB(3, 1, 1, 1),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Replying to: ",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    textScaler:
                                        TextScaler.linear(widget.scaleFactor),
                                  ),
                                ),
                                const SizedBox(
                                  width: 20,
                                )
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: Colors.blue.shade200)),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.doc["ReplySender"].toString(),
                                          style: TextStyle(
                                              color: Colors.blue.shade400,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold),
                                          textScaler: TextScaler.linear(
                                              widget.scaleFactor),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.doc["ReplyText"].toString(),
                                          style: const TextStyle(fontSize: 14),
                                          textScaler: TextScaler.linear(
                                              widget.scaleFactor),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                    endResult()
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget endResult() {
    String type = "Text";
    try {
      type = widget.doc["Type"];
    } catch (e) {
      type = "Text";
    }
    if (type == "Text") {
      return Row(
        children: [
          Expanded(
            child: Text(
              widget.doc["Text"].toString(),
              style: const TextStyle(fontSize: 20),
              textScaler: TextScaler.linear(widget.scaleFactor),
            ),
          ),
          const SizedBox(
            width: 20,
          )
        ],
      );
    } else if (type == "Image") {
      return Row(
        children: [
          Expanded(
            child: Image.network(
              widget.doc["ImageSrc"],
              loadingBuilder: (context, child, loadingProgress) {
                return child;
              },
              alignment: Alignment.centerLeft,
              fit: BoxFit.fitHeight,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context as BuildContext).size.width / 2.5,
          )
        ],
      );
    } else if (type == "File") {
      // TODO
      return Row(
        children: [
          const Expanded(flex: 1, child: Icon(Icons.picture_as_pdf, size: 40)),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 7,
            child: Text(
              "File sent by ${widget.doc["Sender"]}",
              style: const TextStyle(fontSize: 20),
              textScaler: TextScaler.linear(widget.scaleFactor),
            ),
          ),
          //const Spacer(),
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                fileDownload();
              },
              child: const Icon(
                Icons.download_rounded,
                size: 40,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      );
    } else if (type == "GameInvitation") {
      //TODO
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.doc["Text"].toString(),
                  style: const TextStyle(fontSize: 20),
                  textScaler: TextScaler.linear(widget.scaleFactor),
                ),
              ),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Center(
            child: widget.doc["Sender"] != widget.user
                ? GestureDetector(
                    onTap: () async {
                      clickSound();
                      log(widget.doc["GameSession"]);
                      log(widget.contact + widget.user);
                      var gameSession = await db
                          .collection("gamesessions")
                          .doc(widget.doc["GameSession"])
                          .get();
                      if (!gameSession.data()!["Started"]) {
                        Utils.showSnackBar("Game is starting");
                        await db
                            .collection("gamesessions")
                            .doc(widget.doc["GameSession"])
                            .update({"Started": true});
                        await db
                            .collection("nicknames")
                            .doc(widget.user)
                            .collection("games")
                            .doc(widget.doc["GameType"])
                            .update({
                          "waitingOpponent": false,
                          "gameSession": widget.doc["GameSession"],
                          "online": true,
                          "opponent": widget.contact
                        });
                        await db
                            .collection("nicknames")
                            .doc(widget.contact)
                            .collection("games")
                            .doc(widget.doc["GameType"])
                            .update({"waitingOpponent": false});
                        await Future.delayed(const Duration(seconds: 2));
                        Utils.showSnackBar("Navigate to game menu to play");
                      } else {
                        Utils.showSnackBar("Invalid");
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(18)),
                      child: const Text(
                        "Play",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                : GestureDetector(
                    onTap: () async {
                      log(widget.doc["GameSession"]);
                      log(widget.contact + widget.user);
                      Utils.showSnackBar("Invalid");
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(18)),
                      child: const Text(
                        "Play",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
          )
        ],
      );
    }
    return const Text(
      "Something went wrong :(",
      style: TextStyle(fontSize: 20),
    );
  }
}

class ChatWidgetStyle1 extends StatefulWidget {
  const ChatWidgetStyle1(
      {super.key,
      required this.chatSticker,
      required this.doc,
      required this.previousSender});
  final previousSender;
  final chatSticker;
  final doc;
  @override
  _ChatWidgetStyle1State createState() => _ChatWidgetStyle1State();
}

class _ChatWidgetStyle1State extends State<ChatWidgetStyle1> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        (Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            color: AdaptiveTheme.of(context).mode == AdaptiveThemeMode.light
                ? Colors.grey[200]
                : Colors.grey[800],
          ),
          padding: const EdgeInsets.fromLTRB(7, 4, 7, 2),
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          width: double.infinity,
          child: Column(
            children: [
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.doc["Sender"].toString(),
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        timestampToDate(widget.doc["Date"]),
                        style: const TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  if (widget.doc["ReplyText"] != "" &&
                      widget.doc["ReplySender"] != "") ...[
                    Container(
                      padding: const EdgeInsets.fromLTRB(3, 1, 1, 1),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Replying to: ",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              )
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border:
                                    Border.all(color: Colors.blue.shade200)),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.doc["ReplySender"].toString(),
                                        style: TextStyle(
                                            color: Colors.blue.shade400,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.doc["ReplyText"].toString(),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.doc["Text"].toString(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        )),
      ],
    );
  }
}

String timestampToDate(Timestamp? timestamp) {
  try {
    DateTime date = timestamp!.toDate();
    DateTime curDate = DateTime.now();
    date = date.subtract(Duration(milliseconds: date.millisecond));
    date = date.subtract(Duration(microseconds: date.microsecond));
    int diff = curDate.difference(date).inSeconds;
    if (diff >= 31536000) {
      return "${diff ~/ 31536000} year${diff ~/ 31536000 > 1 ? "s" : ""} ago";
    } else if (diff >= 2592000) {
      return "${diff ~/ 2592000} month${diff ~/ 2592000 > 1 ? "s" : ""} ago";
    } else if (diff >= 604800) {
      return "${diff ~/ 604800} week${diff ~/ 604800 > 1 ? "s" : ""} ago";
    } else if (diff >= 86400) {
      return "${diff ~/ 86400} day${diff ~/ 86400 > 1 ? "s" : ""} ago";
    } else if (diff >= 3600) {
      return DateFormat("${diff ~/ 3600 > 1 ? "hh" : "h"}:mm").format(date);
    } else if (diff >= 60) {
      return DateFormat("${diff ~/ 3600 > 1 ? "hh" : "h"}:mm").format(date);
    } else if (diff < 60) {
      return DateFormat("${diff ~/ 3600 > 1 ? "hh" : "h"}:mm").format(date);
    }
  } catch (e) {
    return "";
  }
  return "";
}
