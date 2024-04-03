// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, avoid_unnecessary_containers, use_build_context_synchronously, unnecessary_new

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:pavli_text/widget_classes/chats/add_attachment_item.dart';
import 'package:pavli_text/widget_classes/chats/chat_widget_style.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.contact, required this.data});
  final String contact;
  final Map<String, dynamic> data;
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  var chatsLst = [];
  Map<String, dynamic> data = {};
  List<Widget> lst1 = [];
  Timer? timer;
  bool backBtn = false;
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  String message = "";
  bool blockedReady = false;
  bool blocked = false;
  String blockedBy = "";
  bool chatIdReady = false;
  String chatId = "";
  List chatUsers = [];
  bool ifGroup = false;
  bool ifReplying = false;
  double scaleFactor = 1;
  // ignore: prefer_typing_uninitialized_variables
  var doc1;
  String replyText = "Repying";

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> downloadNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void blockedCheck() async {
    var doc = db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.contact);
    await doc.get().then((value) {
      var map = value.data();
      setState(() {
        blocked = map!["Blocked"];
        blockedBy = map["BlockedBy"];
        blockedReady = true;
      });
    });
  }

  void sendMessage() async {
    if (_controller.text.isNotEmpty) {
      String text = _controller.text.trim();
      _controller.clear();
      pushNotification(text);
      if (!ifReplying) {
        await db.collection("chats").doc(chatId).collection("chats").add({
          "Text": text,
          "Sender": widget.data["Nickname"],
          "Date": FieldValue.serverTimestamp(),
          "ReplyText": "",
          "ReplySender": ""
        });
      } else {
        await db.collection("chats").doc(chatId).collection("chats").add({
          "Text": text,
          "Sender": widget.data["Nickname"],
          "Date": FieldValue.serverTimestamp(),
          "ReplyText": replyText,
          "ReplySender": doc1["Sender"]
        });
      }
      var time = Timestamp.now();
      await db
          .collection("nicknames")
          .doc(widget.data["Nickname"])
          .collection("contacts")
          .doc(widget.contact)
          .update({
        "LastChatDate": time,
        "LastChat": text,
        "LastChatSender": widget.data["Nickname"]
      });
      await db
          .collection("nicknames")
          .doc(widget.contact)
          .collection("contacts")
          .doc(widget.data["Nickname"])
          .update({
        "LastChatDate": time,
        "LastChat": text,
        "LastChatSender": widget.data["Nickname"]
      });

      setState(() {
        ifReplying = false;
        replyText = "Replying";
      });

      viewChatEdit1();
    }
  }

  late Reference uploadRef;
  String imageStr = "";

  void sendImage(ImageSource imageSource) async {
    //TODO

    log("uploadImge");
    ImagePicker imagePicker = ImagePicker();
    XFile? file =
        await imagePicker.pickImage(source: imageSource, imageQuality: 25);
    if (file == null) {
      log("null");
      return;
    }

    String fileName =
        user.email! + DateTime.now().microsecondsSinceEpoch.toString();
    ;
    Reference storageRef = FirebaseStorage.instance.ref();
    Reference imageRef = storageRef.child("chats/$chatId");
    uploadRef = imageRef.child(fileName);

    log(fileName);
    //File file1 = File(file.path);
    await uploadRef.putData(await file.readAsBytes());
    String picUrl = await uploadRef.getDownloadURL();
    log(picUrl);

    if (true) {
      String text = "Image sent by ${widget.data["Nickname"]}";
      pushNotification("Sent image");
      if (!ifReplying) {
        await db.collection("chats").doc(chatId).collection("chats").add({
          "Type": "Image",
          "Text": text,
          "ImageSrc": picUrl,
          "Sender": widget.data["Nickname"],
          "Date": FieldValue.serverTimestamp(),
          "ReplyText": "",
          "ReplySender": ""
        });
      } else {
        await db.collection("chats").doc(chatId).collection("chats").add({
          "Type": "Image",
          "Text": text,
          "ImageSrc": picUrl,
          "Sender": widget.data["Nickname"],
          "Date": FieldValue.serverTimestamp(),
          "ReplyText": replyText,
          "ReplySender": doc1["Sender"]
        });
      }
      var time = Timestamp.now();
      await db
          .collection("nicknames")
          .doc(widget.data["Nickname"])
          .collection("contacts")
          .doc(widget.contact)
          .update({
        "LastChatDate": time,
        "LastChat": text,
        "LastChatSender": widget.data["Nickname"]
      });
      await db
          .collection("nicknames")
          .doc(widget.contact)
          .collection("contacts")
          .doc(widget.data["Nickname"])
          .update({
        "LastChatDate": time,
        "LastChat": text,
        "LastChatSender": widget.data["Nickname"]
      });

      setState(() {
        ifReplying = false;
        replyText = "Replying";
      });

      viewChatEdit1();
    }
  }

  void sendDocument() async {
    String? path = await FlutterDocumentPicker.openDocument();
    if (path == null || path.isEmpty) {
      return;
    }
    log(path);
    log(path.substring(path.lastIndexOf(".") + 1, path.length));
    File file = File(path);
    String fileName = "";
    try {
      fileName =
          "${DateTime.now().microsecondsSinceEpoch}.${path.substring(path.lastIndexOf(".") + 1, path.length)}";
    } catch (e) {
      log(e.toString());
    }

    Reference storageRef = FirebaseStorage.instance.ref();
    Reference imageRef = storageRef.child("chats/$chatId");
    uploadRef = imageRef.child(fileName);

    log(fileName);
    //File file1 = File(file.path);
    NotificationDetails nd = NotificationDetails(
        android: AndroidNotificationDetails("downloadstatus", "Download Status",
            enableVibration: false, silent: true, playSound: false));
    flutterLocalNotificationsPlugin.show(
        101, "PavliText", "Uploading File", nd);
    String picUrl = "";
    uploadRef
        .putData(await file.readAsBytes())
        .asStream()
        .listen((event) async {
      log("thios");
      switch (event.state) {
        case TaskState.running:
          log("message");
          flutterLocalNotificationsPlugin.show(
              101,
              "PavliText",
              "Uploading File",
              NotificationDetails(
                  android: AndroidNotificationDetails(
                      "downloadstatus", "Download Status",
                      enableVibration: false,
                      playSound: false,
                      showProgress: true,
                      silent: true,
                      progress: event.bytesTransferred,
                      maxProgress: event.totalBytes)));
          break;

        case TaskState.paused:
          flutterLocalNotificationsPlugin.show(
              101,
              "PavliText",
              "Upload was canceled",
              NotificationDetails(
                  android: AndroidNotificationDetails(
                "downloadstatus",
                "Download Status",
                enableVibration: false,
                playSound: false,
                silent: true,
              )));
          break;

        case TaskState.success:
          flutterLocalNotificationsPlugin.show(
              101,
              "PavliText",
              "Upload successful",
              NotificationDetails(
                  android: AndroidNotificationDetails(
                "downloadstatus",
                "Download Status",
                enableVibration: false,
                playSound: false,
                silent: true,
              )));
          picUrl = await uploadRef.getDownloadURL();
          log(picUrl);
          writeFileChat(picUrl);
          break;

        case TaskState.canceled:
          flutterLocalNotificationsPlugin.show(
              101,
              "PavliText",
              "Upload was canceled",
              NotificationDetails(
                  android: AndroidNotificationDetails(
                "downloadstatus",
                "Download Status",
                enableVibration: false,
                playSound: false,
                silent: true,
              )));
          break;

        case TaskState.error:
          flutterLocalNotificationsPlugin.show(
              101,
              "PavliText",
              "Upload failed",
              NotificationDetails(
                  android: AndroidNotificationDetails(
                "downloadstatus",
                "Download Status",
                enableVibration: false,
                playSound: false,
                silent: true,
              )));
          break;
        default:
      }
    });
  }

  void writeFileChat(String picUrl) async {
    if (true) {
      String text = "File sent by ${widget.data["Nickname"]}";
      pushNotification("Sent file");
      if (!ifReplying) {
        await db.collection("chats").doc(chatId).collection("chats").add({
          "Type": "File",
          "Text": text,
          "ImageSrc": picUrl,
          "Sender": widget.data["Nickname"],
          "Date": FieldValue.serverTimestamp(),
          "ReplyText": "",
          "ReplySender": ""
        });
      } else {
        await db.collection("chats").doc(chatId).collection("chats").add({
          "Type": "File",
          "Text": text,
          "ImageSrc": picUrl,
          "Sender": widget.data["Nickname"],
          "Date": FieldValue.serverTimestamp(),
          "ReplyText": replyText,
          "ReplySender": doc1["Sender"]
        });
      }
      log("2");
      var time = Timestamp.now();
      await db
          .collection("nicknames")
          .doc(widget.data["Nickname"])
          .collection("contacts")
          .doc(widget.contact)
          .update({
        "LastChatDate": time,
        "LastChat": text,
        "LastChatSender": widget.data["Nickname"]
      });
      await db
          .collection("nicknames")
          .doc(widget.contact)
          .collection("contacts")
          .doc(widget.data["Nickname"])
          .update({
        "LastChatDate": time,
        "LastChat": text,
        "LastChatSender": widget.data["Nickname"]
      });

      setState(() {
        ifReplying = false;
        replyText = "Replying";
      });

      viewChatEdit1();
    }
  }

  void scrollToBottom() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.fastOutSlowIn);
  }

  void textFieldChanged(var value) {
    setState(() {
      message = value;
    });
  }

  void setChats() async {
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.contact)
        .get()
        .then((value) {
      setState(() {
        chatId = value.data()!["ChatName"];
      });
    });
    db.collection("chats").doc(chatId).get().then((value) {
      setState(() {
        chatUsers = value.data()!["Users"];
      });
    });
    setState(() {
      chatIdReady = true;
    });
  }

  void notificationTest() async {}

  final mFunc = FirebaseFunctions.instance;

  void pushNotification(String message) async {
    log("______________Notification sent_______________");
    List<dynamic> tokenList = [];
    for (int i = 0; i <= chatUsers.length - 1; i++) {
      if (chatUsers[i] == widget.data["Nickname"]) {
      } else {
        await db.collection("nicknames").doc(chatUsers[i]).get().then((value) {
          try {
            tokenList = value.data()!["tokenList"];
          } catch (e) {
            tokenList = [];
          }
        });
        /*mFunc.httpsCallable("sendNotification").call({
          "tokens": tokenList,
          "title": widget.data["Nickname"],
          "body": message
        }).then((value) {
          log(value.data.toString());
        });*/
        for (String tokenL in tokenList) {
          try {
            Map<String, Object> body;
            if (ifGroup) {
              body = {
                "to": tokenL,
                "notification": {
                  "title": "New message in group  ${widget.contact}: ",
                  "body": widget.data["Nickname"]
                }
              };
            } else {
              body = {
                "to": tokenL,
                "notification": {
                  "title": widget.data["Nickname"],
                  "body": message
                }
              };
            }

            // ignore: unused_local_variabledd
            var res = await post(
                Uri.parse("https://fcm.googleapis.com/fcm/send"),
                body: jsonEncode(body),
                headers: {
                  HttpHeaders.contentTypeHeader: "application/json",
                  HttpHeaders.authorizationHeader:
                      "key=AAAAWCL3XpU:APA91bFxP_DGH1VXWWteQB9ov-KBLF3xzGmklUhlgQCMrw2H3laoTNAIeke6ccpPvxw7bQD9gYzTlzyy__55RKfjk6TuS3F8TnHwSwB_zJgaMhgUBmGA_5uSLkp8oAywzJd4Z74e6Yhk"
                });
          } catch (e) {
            log("Nottification error: $e");
          }
        }
      }
    }
  }

  void viewChatEdit1() async {
    List lst = [widget.data["Nickname"]];
    db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.contact)
        .update({"ViewedBy": lst});
    db
        .collection("nicknames")
        .doc(widget.contact)
        .collection("contacts")
        .doc(widget.data["Nickname"])
        .update({"ViewedBy": lst});
  }

  void ifGroupFn() async {
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.contact)
        .get()
        .then((value) {
      if (value.data()!["Group"] == true) {
        ifGroup = true;
      }
    });
  }

  void linkClick(doc) async {
    log(doc["Text"]);
    /*final Uri url =
        Uri.parse("https://deku.posstree.com/en/flutter/url_launcher/");

    if (await canLaunchUrl(url)) {
      log("message");
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }*/
  }

  void copyClick(doc) async {
    log(widget.data["Nickname"]);
    await Clipboard.setData(ClipboardData(text: doc["Text"]));
  }

  void replyClick(var doc) {
    setState(() {
      ifReplying = true;
      doc1 = doc;
    });
    String str1 = doc1["Text"].toString();
    if (doc1["Text"].toString().length > 30) {
      str1 = doc1["Text"].toString().substring(0, 30);
    }
    setState(() {
      replyText = str1;
    });
  }

  final TextEditingController _editChatController = TextEditingController();

  void editChatFunc(DocumentSnapshot<Object?> doc) async {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["Text"] = _editChatController.text;
    if (_editChatController.text.trim() != "") {
      await db
          .collection("chats")
          .doc(chatId)
          .collection("chats")
          .doc(doc.id)
          .update(data);
      unFocusKeyboard();
      Navigator.pop(context);
      setState(() {});
    }
  }

  void editChat(DocumentSnapshot<Object?> doc) async {
    Navigator.pop(context);
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    _editChatController.text = data["Text"];
    showDialog(
        context: context,
        builder: (context) {
          return Scaffold(
              backgroundColor: Color.fromARGB(0, 0, 0, 0),
              body: GestureDetector(
                onTap: () {
                  unFocusKeyboard();
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Center(
                      child: Container(
                          child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                          onTap: () {
                            editChatFunc(doc);
                          },
                          child: StyleDialogItem(child: "Edit Message")),
                      Container(
                          padding: EdgeInsets.fromLTRB(50, 4, 50, 4),
                          child: TextField(
                            cursorColor: Colors.blue,
                            autofocus: true,
                            controller: _editChatController,
                            textCapitalization: TextCapitalization.sentences,
                            autocorrect: false,
                            enableSuggestions: true,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: isLightMode(
                                  context,
                                  lWidget: Colors.grey[200],
                                  dWidget: Colors.grey[800],
                                ),
                                border: OutlineInputBorder(
                                    gapPadding: 4,
                                    borderRadius: BorderRadius.circular(8))),
                            onSubmitted: (value) => setState(() {
                              editChatFunc(doc);
                            }),
                            onTap: scrollToBottom,
                          )),
                    ],
                  ))),
                ),
              ));
        });
  }

  void deleteChat(DocumentSnapshot<Object?> doc) async {
    //TODO
    try {
      storage.refFromURL(doc["ImageSrc"]).delete();
    } catch (e) {
      log(e.toString());
    }
    await db
        .collection("chats")
        .doc(chatId)
        .collection("chats")
        .doc(doc.id)
        .delete();
    setState(() {});
  }

  String timestampToDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
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
    return "$date";
  }

  void viewChatEdit() async {
    db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.contact)
        .get()
        .then((value) {
      List lst = [];
      try {
        lst = value.data()!["ViewedBy"];
      } catch (e) {}
      if (!lst.contains(widget.data["Nickname"])) {
        lst.add(widget.data["Nickname"]);
      }
      db
          .collection("nicknames")
          .doc(widget.data["Nickname"])
          .collection("contacts")
          .doc(widget.contact)
          .update({"ViewedBy": lst});
      db
          .collection("nicknames")
          .doc(widget.contact)
          .collection("contacts")
          .doc(widget.data["Nickname"])
          .update({"ViewedBy": lst});
    });
  }

  @override
  void dispose() {
    viewChatEdit();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    previousTime = Timestamp.fromDate(DateTime.utc(2000, 1, 1, 1, 1, 1));
    blockedCheck();
    ifGroupFn();
    setChats();
    setups();
    downloadNotification();
    attachmentsList = <Widget>[
      GestureDetector(
          onTap: attachmentListChange1,
          child: AddAttachmentItem(
            iconData: Icons.add_circle,
            size: 42,
          ))
    ];
    attWidth = attachmentsList.length * 42 + 18;
  }

  late Map<String, dynamic> contact;
  bool setupsReady = false;

  void setups() async {
    setState(() {
      contact = widget.data;
    });
    await db.collection("nicknames").doc(widget.contact).get().then((value) {
      setState(() {
        contact = value.data()!;
      });
    });

    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .get()
        .then((value) {
      setState(() {
        data = value.data()!;
      });
    });
    try {
      scaleFactor = data["ScaleFactor"];
    } catch (e) {
      log(e.toString());
    }
    log(scaleFactor.toString());
    setState(() {
      setupsReady = true;
    });
  }

  Widget profilePicture() {
    try {
      storage.refFromURL(contact["ProfilePicUrl"]);
      return Container(
        child: ProfilePicture(
          name: contact["Nickname"],
          radius: 21.0,
          fontsize: 21,
          img: contact["ProfilePicUrl"],
        ),
      );
    } catch (e) {
      return Container(
          child: ProfilePicture(
        name: contact["Nickname"],
        radius: 21.0,
        fontsize: 21,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!blockedReady) {
      return Utils.loadingScaffold();
    }
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15))),
          centerTitle: true,
          title: Row(
            children: [
              profilePicture(),
              SizedBox(
                width: 10,
              ),
              Text(widget.contact),
            ],
          ),
          elevation: 0,
          leading: InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    moreBtn();
                  },
                  child: const Icon(Icons.more_vert),
                )),
          ],
        ),
        body: chatWidgets(),
        /*floatingActionButton:
            FloatingActionButton(onPressed: floatingActionButtonClick),*/
      ),
    );
  }

  void attachmentListChange1() {
    //TODO
    setState(() {
      attachmentsList = <Widget>[
        GestureDetector(
            onTap: () {
              clickSound();
              attachmentListChange2();
            },
            child: AddAttachmentItem(iconData: Icons.remove_circle, size: 42)),
        GestureDetector(
            onTap: () {
              clickSound();
              attachmentListChange2();
              sendImage(ImageSource.gallery);
            },
            child: AddAttachmentItem(iconData: Icons.image, size: 42)),
        GestureDetector(
            onTap: () {
              clickSound();
              attachmentListChange2();
              sendImage(ImageSource.camera);
            },
            child: AddAttachmentItem(iconData: Icons.camera_alt, size: 42)),
        GestureDetector(
            onTap: () {
              clickSound();
              attachmentListChange2();
              sendDocument();
            },
            child: AddAttachmentItem(
                iconData: Icons.picture_as_pdf_rounded, size: 42)),
      ];
      attWidth = attachmentsList.length * 42 + 18;
    });
  }

  void attachmentListChange2() async {
    setState(() {
      attWidth = 42 + 18;
    });
    await Future.delayed(Duration(milliseconds: 300));
    setState(() {
      attachmentsList = <Widget>[
        GestureDetector(
            onTap: attachmentListChange1,
            child: AddAttachmentItem(iconData: Icons.add_circle, size: 42))
      ];
    });
  }

  double attWidth = 0;
  bool addAtachmentState = false;
  List<Widget> attachmentsList = [];

  String previousSender = "";
  Timestamp previousTime =
      Timestamp.fromDate(DateTime.utc(2000, 1, 1, 1, 1, 1));

  Widget chatWidgets() {
    if (blocked && blockedBy == widget.contact) {
      return SafeArea(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 20),
              child: const Text("You were blocked."))
        ],
      ));
    } else if (blocked && blockedBy == widget.data["Nickname"]) {
      return SafeArea(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
              margin: const EdgeInsets.only(top: 20),
              child: const Text("You blocked this user"))
        ],
      ));
    }
    return Stack(
      children: [
        Positioned(
          child: Align(
            alignment: FractionalOffset.topCenter,
            child: StreamBuilder<QuerySnapshot>(
                //____________________________________STREAMBUILDER
                stream: db
                    .collection("chats")
                    .doc(chatId)
                    .collection("chats")
                    .orderBy("Date", descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Text("Loading...");
                  }
                  previousSender = "";
                  previousTime =
                      Timestamp.fromDate(DateTime.utc(2000, 1, 1, 1, 1, 1));
                  return SingleChildScrollView(
                    reverse: true,
                    controller: _scrollController,
                    child: Column(
                      children: [
                        ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = snapshot.data!.docs[index];
                            bool chatSticker = false;
                            try {
                              if (doc["Sender"] == previousSender &&
                                  (doc["Date"].seconds - previousTime.seconds <=
                                      180)) {
                                chatSticker = true;
                              }
                            } catch (e) {
                              log(e.toString());
                            }
                            try {
                              previousSender = doc["Sender"];
                              previousTime = doc["Date"];
                            } catch (e) {
                              log(e.toString());
                            }
                            return GestureDetector(
                                onLongPress: () {
                                  unFocusKeyboard();
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Center(
                                          child: Container(
                                              child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ChatWidgetStyle1(
                                                chatSticker: chatSticker,
                                                previousSender: previousSender,
                                                doc: doc,
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  replyClick(doc);
                                                  Navigator.pop(context);
                                                },
                                                child: StyleDialogItem(
                                                    child: "Reply"),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  copyClick(doc);
                                                  Navigator.pop(context);
                                                },
                                                child: StyleDialogItem(
                                                    child: "Copy"),
                                              ),
                                              if (doc["Sender"] ==
                                                      widget.data["Nickname"] ||
                                                  widget.data["Nickname"] ==
                                                      "Poul") ...[
                                                GestureDetector(
                                                  onTap: () {
                                                    editChat(doc);
                                                  },
                                                  child: StyleDialogItem(
                                                      child: "Edit"),
                                                ),
                                              ],
                                              if (doc["Sender"] ==
                                                      widget.data["Nickname"] ||
                                                  widget.data["Nickname"] ==
                                                      "Poul") ...[
                                                GestureDetector(
                                                  onTap: () {
                                                    deleteChat(doc);
                                                    Navigator.pop(context);
                                                  },
                                                  child: StyleDialogItem(
                                                      child: "Delete"),
                                                ),
                                              ]
                                            ],
                                          )),
                                        );
                                      });
                                },
                                //
                                child: ChatWidgetStyle(
                                  chatSticker: chatSticker,
                                  previousSender: previousSender,
                                  doc: doc,
                                  scaleFactor: scaleFactor,
                                )
                                //
                                );
                          },
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          height: 5,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(6),
                                bottomRight: Radius.circular(6)),
                            color: isLightMode(
                              context,
                              lWidget: Colors.grey[200],
                              dWidget: Colors.grey[800],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 350,
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ),
        Positioned(
          child: Align(
            alignment: FractionalOffset.bottomCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                //TODO

                AnimatedContainer(
                    curve: Curves.easeIn,
                    duration: Duration(milliseconds: 300),
                    width: attWidth /*attachmentsList.length * 42 + 18*/,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(30)),
                      color: isLightMode(
                        context,
                        lWidget: Colors.grey[200],
                        dWidget: Colors.grey[800],
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(8, 10, 10, 0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: attachmentsList),
                    )),

                Container(
                  decoration: BoxDecoration(
                      color: isLightMode(
                        context,
                        lWidget: Colors.grey[200],
                        dWidget: Colors.grey[800],
                      ),
                      borderRadius:
                          BorderRadius.only(topRight: Radius.circular(12))),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (ifReplying) ...[
                        Align(
                          alignment: FractionalOffset.bottomLeft,
                          child: Text(
                            "Replying to:",
                            style: TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(0, 0, 0, 8),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          doc1["Sender"].toString(),
                                          style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.w600),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        )
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          replyText,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    ifReplying = false;
                                    replyText = "Replying";
                                  });
                                },
                                child: Icon(Icons.cancel),
                              )
                            ],
                          ),
                        )
                      ],
                      Row(children: [
                        Expanded(
                          child: TextFormField(
                            controller: _controller,
                            textCapitalization: TextCapitalization.sentences,
                            autocorrect: false,
                            keyboardType: TextInputType.text,
                            keyboardAppearance: Brightness.light,
                            enableSuggestions: true,
                            decoration: InputDecoration(
                                filled: true,
                                fillColor: isLightMode(
                                  context,
                                  lWidget: Colors.grey[200],
                                  dWidget: Colors.grey[800],
                                ),
                                labelText: "Type your message",
                                border: OutlineInputBorder(
                                    borderSide: const BorderSide(width: 0),
                                    gapPadding: 10,
                                    borderRadius: BorderRadius.circular(25))),
                            onChanged: (value) => textFieldChanged(value),
                            onFieldSubmitted: (value) => setState(() {
                              sendMessage();
                            }),
                            /*onTap: () {
                              scrollToBottom();
                            },*/
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        GestureDetector(
                          onTap: sendMessage,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.blue),
                            child: const Icon(
                              Icons.send,
                              size: 30,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void moreBtn() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: AnimatedPadding(
                  padding: MediaQuery.of(context).viewInsets,
                  duration: const Duration(milliseconds: 100),
                  child: SizedBox(
                    height: 300,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        if (!blocked) ...[
                          GestureDetector(
                            onTap: blockUser,
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              child: const Text(
                                "Block chat",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ),
                          )
                        ] else if (blocked &&
                            blockedBy == widget.data["Nickname"]) ...[
                          GestureDetector(
                            onTap: unBlockUser,
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              child: const Text(
                                "Unblock chat",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              ),
                            ),
                          )
                        ] else ...[
                          GestureDetector(
                            child: Container(
                              margin: const EdgeInsets.all(20),
                              child: const Text(
                                "You were blocked",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                              ),
                            ),
                          )
                        ],
                        GestureDetector(
                          onTap: removeFromContacts,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            child: const Text(
                              "Remove contact",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  )));
        });
  }

  void removeFromContacts() async {
    Navigator.pop(context);
    Navigator.pop(context);
    await db.collection("chats").doc(chatId).delete();
    await db
        .collection('nicknames')
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.contact)
        .delete();
    await db
        .collection('nicknames')
        .doc(widget.contact)
        .collection("contacts")
        .doc(widget.data["Nickname"])
        .delete();
  }

  void unBlockUser() async {
    Navigator.pop(context);
    Navigator.pop(context);
    await db
        .collection('nicknames')
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.contact)
        .update({"Blocked": false, "BlockedBy": ""});
    await db
        .collection('nicknames')
        .doc(widget.contact)
        .collection("contacts")
        .doc(widget.data["Nickname"])
        .update({"Blocked": false, "BlockedBy": ""});
  }

  void blockUser() async {
    Navigator.pop(context);
    Navigator.pop(context);
    await db
        .collection('nicknames')
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.contact)
        .update({"Blocked": true, "BlockedBy": widget.data["Nickname"]});
    await db
        .collection('nicknames')
        .doc(widget.contact)
        .collection("contacts")
        .doc(widget.data["Nickname"])
        .update({"Blocked": true, "BlockedBy": widget.data["Nickname"]});
  }
}
