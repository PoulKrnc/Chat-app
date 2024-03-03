// ignore_for_file: must_be_immutable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatState extends StatelessWidget {
  final String contact;
  final Map<String, dynamic> data;
  ChatState({super.key, required this.contact, required this.data});

  var db = FirebaseFirestore.instance;
  var chatsLst = [];

  void chatsLstFill() async {
    var col =
        db.collection("nicknames").doc(data["Nickname"]).collection("contacts");
    var chatsCol = col.doc(contact).collection(contact);

    await chatsCol.get().then((value) {
      for (var i in value.docs) {
        chatsLst.add(i.data());
      }
    });
  }

  List<Widget> chats() {
    chatsLstFill();
    List<Widget> lst1 = [];
    for (int i = 0; i < chatsLst.length; i++) {
      lst1.add(Container(
        decoration: BoxDecoration(border: Border.all()),
        child: Text(chatsLst[i]["Text"].toString()),
      ));
    }
    return lst1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(contact),
      ),
      body: Column(
        children: chats(),
      ),
    );
  }
}
