// ignore_for_file: prefer_interpolation_to_compose_strings, library_private_types_in_public_api, prefer_typing_uninitialized_variables, prefer_final_fields, avoid_unnecessary_containers, prefer_const_literals_to_create_immutables

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:pavli_text/widget_classes/contact_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pavli_text/widget_classes/widget_helper.dart';

class ContactsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> setupsList;
  const ContactsPage({super.key, required this.data, required this.setupsList});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;
  var data1;
  final contactsList = [];
  String str1 = "";
  bool chatOpener = false;
  final _searchController = TextEditingController();
  //TextEditingController _newGroupController = TextEditingController();

  bool contactsAreReady = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (contactsAreReady) {
      return const LoadingIndicatorFb1();
    }
    return Scaffold(
      appBar: AppBar(
        title: Container(
          child: Row(
            children: [ContactIconSearch(icon: Icons.search)],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 220,
                margin: const EdgeInsetsDirectional.fromSTEB(0, 5, 0, 5),
                padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                child: StreamBuilder<QuerySnapshot>(
                    stream: db
                        .collection("nicknames")
                        .doc(widget.data["Nickname"])
                        .collection("contacts")
                        .orderBy("LastChatDate", descending: true)
                        .snapshots(),
                    builder: (context, snapshot1) {
                      if (!snapshot1.hasData) {
                        return const Column(
                          children: [
                            Spacer(),
                            Text(
                              "Your contact list is empty for now",
                              style: TextStyle(fontSize: 17),
                            ),
                            Spacer()
                          ],
                        );
                      }
                      // ignore: prefer_is_empty
                      if (snapshot1.data!.docs.length == 0) {
                        return const Row(
                          children: [
                            Spacer(),
                            Text("Your contacts are empty for now."),
                            Spacer()
                          ],
                        );
                      }
                      return ListView.builder(
                          itemCount: snapshot1.data!.docs.length,
                          itemBuilder: (context, index) {
                            DocumentSnapshot doc = snapshot1.data!.docs[index];
                            try {
                              doc["LastChatDate"].toString();
                            } catch (e) {
                              db
                                  .collection("nicknames")
                                  .doc(widget.data["Nickname"])
                                  .collection("contacts")
                                  .doc(doc.id);
                            }
                            return ContactWidget(
                              doc: doc,
                              data: widget.data,
                            );
                          });
                    }),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addContact,
        child: const Icon(Icons.add),
      ),
    );
  }

  void addContact() {
    showModalBottomSheet(
        isScrollControlled: true,
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
                height: 150,
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                        child: const Text(
                          "Type an existing username:",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsetsDirectional.fromSTEB(
                            25, 10, 25, 10),
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(15, 0, 5, 0),
                        decoration: BoxDecoration(
                            color: AdaptiveTheme.of(context).mode ==
                                    AdaptiveThemeMode.light
                                ? Colors.grey[100]
                                : Colors.grey[800],
                            border: Border.all(color: Colors.blue),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  offset: const Offset(5, 5),
                                  blurRadius: 10,
                                  color: Color.fromARGB(
                                      255,
                                      isLightMode(context,
                                          lWidget: 155, dWidget: 66),
                                      isLightMode(context,
                                          lWidget: 155, dWidget: 66),
                                      isLightMode(context,
                                          lWidget: 155, dWidget: 66)))
                            ]),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: TextField(
                                autofocus: true,
                                controller: _searchController,
                                onEditingComplete: searchForPeople,
                                decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Username"),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                decoration: const BoxDecoration(
                                    border: Border(
                                        left: BorderSide(color: Colors.blue))),
                                child: GestureDetector(
                                  onTap: searchForPeople,
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }

  Future<bool> checkIfContactInLst(String personNickname) async {
    bool st1 = true;
    if (personNickname != "") {
      await db
          .collection("nicknames")
          .doc(widget.data["Nickname"])
          .collection("contacts")
          .doc(personNickname)
          .get()
          .then((value) {
        st1 = value.exists;
      });
    }
    return st1;
  }

  void searchForPeople() async {
    setState(() {
      personNickname = _searchController.text.trim();
      _searchController.text = "";
    });
    unFocusKeyboard();
    Navigator.pop(context);
    var doc = await db.collection("nicknames").doc(personNickname).get();
    if (doc.exists) {
      if (!await checkIfContactInLst(personNickname)) {
        addContacts();
      } else {
        Utils.showSnackBar("Nickname is already in your contacts");
      }
    } else {
      Utils.showSnackBar("Nickname does not exist");
    }
  }

  bool personExists = false;
  String personNickname = "";

  void addContacts() async {
    String chatId = DateTime.now().microsecondsSinceEpoch.toString();
    DateTime date = DateTime.now();
    var date1 = Timestamp.fromDate(date);
    db
        .collection('nicknames')
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(personNickname)
        .set({
      "Blocked": false,
      "BlockedBy": "",
      "ChatName": chatId,
      "Group": false,
      "ViewedBy": [],
      "LastChatDate": date1,
      "LastChatSender": "App",
      "LastChat":
          "This is a start of conversation between ${widget.data["Nickname"]} and $personNickname"
    });
    db
        .collection('nicknames')
        .doc(personNickname)
        .collection("contacts")
        .doc(widget.data["Nickname"])
        .set({
      "Blocked": false,
      "BlockedBy": "",
      "ChatName": chatId,
      "Group": false,
      "ViewedBy": [],
      "LastChatDate": date1,
      "LastChatSender": "App",
      "LastChat":
          "This is a start of conversation between ${widget.data["Nickname"]} and $personNickname"
    });
    db.collection('chats').doc(chatId).set({
      "Users": [widget.data["Nickname"], personNickname],
      "Group": false
    });
    db.collection('chats').doc(chatId).collection("chats").doc().set({
      "Sender": "App",
      "Date": FieldValue.serverTimestamp(),
      "Text":
          "This is a start of conversation between ${widget.data["Nickname"]} and $personNickname",
      "ReplyText": "",
      "ReplySender": "",
      "ViewedBy": [],
      "LastChatDate": date1,
      "LastChatSender": "App",
      "LastChat":
          "This is a start of conversation between ${widget.data["Nickname"]} and $personNickname"
    });
  }

  void onNavItemTap(int index) {
    setState(() {});
  }
}
