import 'dart:developer';
import 'dart:ui';

import 'package:pavli_text/widget_classes/chats/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class ContactWidget extends StatefulWidget {
  final Map<String, dynamic> data;
  final DocumentSnapshot<Object?> doc;
  const ContactWidget({Key? key, required this.data, required this.doc})
      : super(key: key);

  @override
  _ContactWidgetState createState() => _ContactWidgetState();
}

class _ContactWidgetState extends State<ContactWidget> {
  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late Image? img = Image.asset("assets/empty_profile_picture.jfif");
  late Map<String, dynamic> contact;
  bool setupsReady = false;
  bool viewed = false;
  bool streamGoer = true;

  void onContractTap(String str) {
    Future.delayed(Duration.zero, () {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChatPage(contact: str, data: widget.data)),
      ).then((value) => setState(() {}));
    });
  }

  void stream() async {
    String name = widget.doc.id;
    while (streamGoer) {
      if (name != widget.doc.id) {
        await db.collection("nicknames").doc(widget.doc.id).get().then((value) {
          contact = value.data()!;
        });
        setState(() {
          name = widget.doc.id;
        });
      }

      List lst = widget.doc["ViewedBy"];
      if (lst.contains(widget.data["Nickname"])) {
        viewed = true;
      } else {
        viewed = false;
      }
      setState(() {});
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  String timestampToDate(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    DateTime curDate = DateTime.now();
    date = date.subtract(Duration(milliseconds: date.millisecond));
    date = date.subtract(Duration(microseconds: date.microsecond));
    int diff = curDate.difference(date).inSeconds;
    if (diff >= 31536000) {
      return "${diff ~/ 31536000} year${diff ~/ 31536000 > 1 ? "s" : ""}";
    } else if (diff >= 2592000) {
      return "${diff ~/ 2592000} month${diff ~/ 2592000 > 1 ? "s" : ""}";
    } else if (diff >= 604800) {
      return "${diff ~/ 604800} week${diff ~/ 604800 > 1 ? "s" : ""}";
    } else if (diff >= 86400) {
      return "${diff ~/ 86400} day${diff ~/ 86400 > 1 ? "s" : ""}";
    } else if (diff >= 3600) {
      return "${diff ~/ 3600} hour${diff ~/ 3600 > 1 ? "s" : ""}";
    } else if (diff >= 60) {
      return "${diff ~/ 60} minute${diff ~/ 60 > 1 ? "s" : ""}";
    } else if (diff < 30) {
      return "just now";
    } else if (diff < 60) {
      return "1 minute";
    }
    return "$date";
  }

  String createStringSender() {
    try {
      String lastChatSender = widget.doc["LastChatSender"];
      return "${lastChatSender == widget.data["Nickname"] ? "You" : (lastChatSender.length > 9 ? "${lastChatSender.substring(0, 8)}..." : lastChatSender)}: ";
    } catch (e) {
      return "";
    }
  }

  String createStringChat() {
    try {
      String lastChat = widget.doc["LastChat"];
      return lastChat.length > 17
          ? "${lastChat.substring(0, 15)}..."
          : lastChat;
    } catch (e) {
      return "";
    }
  }

  Widget profilePicture() {
    try {
      storage.refFromURL(contact["ProfilePicUrl"]);
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
            border: Border.all(
                color: viewedWidget(Colors.black, Colors.blue),
                width: viewedWidget(0.0, 3.5)),
            borderRadius: BorderRadius.circular(100)),
        child: ProfilePicture(
          name: contact["Nickname"],
          radius: viewedWidget(21.0, 17.5),
          fontsize: 21,
          img: contact["ProfilePicUrl"],
        ),
      );
    } catch (e) {
      return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: viewedWidget(
              null,
              BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 3.5),
                  borderRadius: BorderRadius.circular(100))),
          child: ProfilePicture(
            name: contact["Nickname"],
            radius: viewedWidget(21.0, 17.5),
            fontsize: 21,
          ));
    }
  }

  dynamic viewedWidget(dynamic yes, dynamic no) {
    if (viewed) {
      return yes;
    }
    return no;
  }

  void setups() async {
    await db.collection("nicknames").doc(widget.doc.id).get().then((value) {
      setState(() {
        contact = value.data()!;
      });
    });
    setState(() {
      setupsReady = true;
    });
    try {
      widget.doc["LastChat"].toString();
      widget.doc["LastChatSender"].toString();
    } catch (e) {
      db
          .collection("nicknames")
          .doc(widget.data["Nickname"])
          .collection("contacts")
          .doc(widget.doc.id)
          .update({"LastChat": "...", "LastChatSender": widget.doc.id});
    }

    try {
      List lst = widget.doc["ViewedBy"];
      if (lst.contains(widget.data["Nickname"])) {
        viewed = true;
      } else {
        viewed = false;
      }
    } catch (e) {
      log(e.toString());
      log(widget.data["Nickname"] + " : " + widget.doc.id);
      db
          .collection('nicknames')
          .doc(widget.data["Nickname"])
          .collection("contacts")
          .doc(widget.doc.id)
          .update({
        "ViewedBy": [],
      });
      db
          .collection('nicknames')
          .doc(widget.doc.id)
          .collection("contacts")
          .doc(widget.data["Nickname"])
          .update({
        "ViewedBy": [],
      });
      viewed = false;
    }
    stream();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    streamGoer = false;
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    setups();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (setupsReady) {
      return GestureDetector(
          onTap: () {
            onContractTap(widget.doc.id);
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: BoxDecoration(
                color: viewedWidget(null, null),
                border: BorderDirectional(
                    bottom: BorderSide(
                        color: Colors.blue, width: viewedWidget(1.0, 2.5)))),
            padding: const EdgeInsets.all(7),
            child: SingleChildScrollView(
              child: Row(
                children: [
                  profilePicture(),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(widget.doc.id,
                      style: viewedWidget(
                          const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                          const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.w900,
                              fontSize: 16))),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timestampToDate(widget.doc["LastChatDate"]),
                        style: viewedWidget(
                            null, const TextStyle(fontWeight: FontWeight.w500)),
                      ),
                      Row(
                        children: [
                          Text(
                            createStringSender(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(createStringChat())
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
          ));
    }
    return GestureDetector(
        onTap: () {
          onContractTap(widget.doc.id);
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          decoration: const BoxDecoration(
              border:
                  BorderDirectional(bottom: BorderSide(color: Colors.blue))),
          padding: const EdgeInsets.all(7),
          child: SingleChildScrollView(
            child: Row(
              children: [
                ProfilePicture(
                  name: widget.doc.id,
                  radius: 21,
                  fontsize: 21,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.doc.id,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
              ],
            ),
          ),
        ));
  }
}
