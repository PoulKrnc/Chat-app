// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:pavli_text/widget_classes/contact_widget.dart';

class ContactIconSearch extends StatefulWidget {
  const ContactIconSearch({super.key, required this.icon, required this.data});
  final Map<String, dynamic> data;
  final IconData icon;
  @override
  _ContactIconSearchState createState() => _ContactIconSearchState();
}

class _ContactIconSearchState extends State<ContactIconSearch> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return PeopleSearch(
            data: widget.data,
          );
        }));
        //Navigator.of(context).push(createRoute());
        SystemSound.play(SystemSoundType.click);
      },
      child: Hero(
        tag: "searchIcon",
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(100)),
          child: Icon(
            color: isLightMode(
              context,
              lWidget: Colors.grey[200],
              dWidget: Colors.grey[800],
            ),
            widget.icon,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class BlockedContacts extends StatefulWidget {
  const BlockedContacts({super.key, required this.icon, required this.data});
  final Map<String, dynamic> data;
  final IconData icon;

  @override
  _BlockedContactsState createState() => _BlockedContactsState();
}

class _BlockedContactsState extends State<BlockedContacts> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return BlockedContactsPage(
            data: widget.data,
          );
        }));
        //Navigator.of(context).push(createRoute());
        SystemSound.play(SystemSoundType.click);
      },
      child: Hero(
        tag: "blockedIcon",
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
              color: Colors.blue.shade400,
              borderRadius: BorderRadius.circular(100)),
          child: Icon(
            color: isLightMode(
              context,
              lWidget: Colors.grey[200],
              dWidget: Colors.grey[800],
            ),
            widget.icon,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class BlockedContactsPage extends StatefulWidget {
  const BlockedContactsPage({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  _BlockedContactsPageState createState() => _BlockedContactsPageState();
}

class _BlockedContactsPageState extends State<BlockedContactsPage> {
  String title = "";
  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;

  void waiter() async {
    String str = "Blocked contacts";
    for (int i = 0; i < str.length; i++) {
      await Future.delayed(const Duration(milliseconds: 10));
      setState(() {
        title += str[i];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    waiter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: "blockedIcon",
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(100)),
                child: Icon(
                  color: isLightMode(
                    context,
                    lWidget: Colors.grey[200],
                    dWidget: Colors.grey[800],
                  ),
                  Icons.person_off,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge!
                    .copyWith(color: Colors.white),
              )
            ],
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
                              "Your blocked contact list is empty for now",
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
                              log(e.toString());
                              return const Text("No data");
                            }
                            if (!doc["Blocked"]) {
                              return Container();
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
    );
  }
}

class PeopleSearch extends StatefulWidget {
  const PeopleSearch({super.key, required this.data});
  final Map<String, dynamic> data;

  @override
  _PeopleSearchState createState() => _PeopleSearchState();
}

class _PeopleSearchState extends State<PeopleSearch> {
  Widget crossWidget = Container(
    padding: const EdgeInsets.fromLTRB(4, 1, 16, 1),
  );
  final db = FirebaseFirestore.instance;
  List<String> userList = [];
  bool searching = false;

  final _controller = TextEditingController();
  bool controllerFocused = true;

  void animation() async {
    await Future.delayed(const Duration(milliseconds: 0));
    setState(() {
      crossWidget = Container(
          padding: const EdgeInsets.fromLTRB(4, 1, 16, 1),
          child: TextField(
            onTap: () {
              setState(() {
                controllerFocused = true;
              });
            },
            onTapOutside: (event) {
              setState(() {
                controllerFocused = false;
                unFocusKeyboard();
              });
            },
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w500),
            controller: _controller,
            autocorrect: false,
            autofocus: true,
            onEditingComplete: () {
              setState(() {
                controllerFocused = false;
                unFocusKeyboard();
              });
              searchFunc();
            },
            onSubmitted: (value) {
              setState(() {
                controllerFocused = false;
                unFocusKeyboard();
              });
              searchFunc();
            },
            decoration: const InputDecoration(
                hintText: "Nickname",
                isDense: true,
                border: InputBorder.none,
                disabledBorder: InputBorder.none),
          ));
    });
  }

  Future<List<String>> getAllVariations(String input) async {
    List<String> variations = [];

    void generateVariations(String currentString, int index) {
      if (index == input.length) {
        variations.add(currentString);
        return;
      }
      generateVariations(currentString + input[index].toUpperCase(), index + 1);
      generateVariations(currentString + input[index].toLowerCase(), index + 1);
    }

    generateVariations("", 0);
    return variations;
  }

  void searchFunc() async {
    setState(() {
      searching = true;
      userList = [];
    });
    String text = _controller.text.trim();
    if (text == "") {
      await Future.delayed(const Duration(milliseconds: 1100));
      setState(() {
        searching = false;
      });
      return;
    }
    Set<String> list = {};
    var nicknamesRef = db.collection("nicknames");
    List<String> variations = await getAllVariations(text);

    for (int i = text.length - 1; i > text.length - 2; i--) {
      var documents = await nicknamesRef
          .where(
            "Nickname",
            isGreaterThanOrEqualTo: text.substring(0, i + 1),
          )
          .where("Nickname", isLessThan: "${text.substring(0, i + 1)}\uffff")
          .get();
      for (var element in documents.docs) {
        var item = element.data()["Nickname"];
        list.add(item);
      }
    }
    Set<List<String>> variations30 = {};
    List<String> strList = [];
    for (String str in variations) {
      strList.add(str);
      if (strList.length >= 29) {
        variations30.add(strList);
        strList = [];
      }
    }
    for (List<String> lst in variations30) {
      var documents = await nicknamesRef.where("Nickname", whereIn: lst).get();
      for (var element in documents.docs) {
        var item = element.data()["Nickname"];
        list.add(item);
      }
    }
    setState(() {
      userList = list.toList();
      searching = false;
    });
  }

  @override
  void initState() {
    animation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Hero(
              tag: "searchIcon",
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
                decoration: BoxDecoration(
                    color: controllerFocused
                        ? Colors.blue.shade300
                        : Colors.blue.shade400,
                    borderRadius: BorderRadius.circular(100)),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: searchFunc,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 100),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Colors.blue.shade400,
                            borderRadius: BorderRadius.circular(100)),
                        child: Icon(
                          Icons.search,
                          size: 30,
                          color: isLightMode(
                            context,
                            lWidget: Colors.grey[200],
                            dWidget: Colors.grey[800],
                          ),
                        ),
                      ),
                    ),
                    Expanded(child: crossWidget),
                  ],
                ),
              ),
            ),
            if (searching) ...[
              LinearProgressIndicator(
                borderRadius: BorderRadius.circular(3),
                minHeight: 2,
              )
            ] else ...[
              Container(
                height: 2,
              )
            ]
          ],
        ),
      ),
      body: ListView.builder(
        itemBuilder: ((context, index) {
          return PersonSearchWidget(
            nickname: userList[index],
            data: widget.data,
          );
        }),
        itemCount: userList.length,
      ),
    );
  }
}

//_______________________________________________________________________________
class PersonSearchWidget extends StatefulWidget {
  final String nickname;
  final Map<String, dynamic> data;
  const PersonSearchWidget(
      {super.key, required this.nickname, required this.data});

  @override
  _PersonSearchWidgetState createState() => _PersonSearchWidgetState();
}

class _PersonSearchWidgetState extends State<PersonSearchWidget> {
  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;
  late Map<String, dynamic> personData;
  bool setupsReady = false;
  bool inContacts = false;

  void addContact() async {
    if (inContacts) {
      return;
    }
    String chatId = DateTime.now().microsecondsSinceEpoch.toString();
    DateTime date = DateTime.now();
    var date1 = Timestamp.fromDate(date);
    db
        .collection('nicknames')
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.nickname)
        .set({
      "Blocked": false,
      "BlockedBy": "",
      "ChatName": chatId,
      "Group": false,
      "ViewedBy": [],
      "LastChatDate": date1,
      "LastChatSender": "App",
      "LastChat":
          "This is a start of conversation between ${widget.data["Nickname"]} and ${widget.nickname}"
    });
    db
        .collection('nicknames')
        .doc(widget.nickname)
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
          "This is a start of conversation between ${widget.data["Nickname"]} and ${widget.nickname}"
    });
    db.collection('chats').doc(chatId).set({
      "Users": [widget.data["Nickname"], widget.nickname],
      "Group": false
    });
    db.collection('chats').doc(chatId).collection("chats").doc().set({
      "Sender": "App",
      "Date": FieldValue.serverTimestamp(),
      "Text":
          "This is a start of conversation between ${widget.data["Nickname"]} and ${widget.nickname}",
      "ReplyText": "",
      "ReplySender": "",
      "ViewedBy": [],
      "LastChatDate": date1,
      "LastChatSender": "App",
      "LastChat":
          "This is a start of conversation between ${widget.data["Nickname"]} and ${widget.nickname}"
    });
    setState(() {
      inContacts = true;
    });
  }

  Widget profilePicture() {
    try {
      storage.refFromURL(personData["ProfilePicUrl"]);
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ProfilePicture(
          name: personData["Nickname"],
          radius: 21.0,
          fontsize: 21,
          img: personData["ProfilePicUrl"],
        ),
      );
    } catch (e) {
      return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: null,
          child: ProfilePicture(
            name: personData["Nickname"],
            radius: 21.0,
            fontsize: 21,
          ));
    }
  }

  void setups() async {
    await db.collection("nicknames").doc(widget.nickname).get().then((value) {
      setState(() {
        personData = value.data()!;
      });
    });
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(widget.nickname)
        .get()
        .then(
      (value) {
        if (value.exists) {
          setState(() {
            inContacts = true;
          });
        }
      },
    );
    setState(() {
      setupsReady = true;
    });
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
          onTap: () {},
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            decoration: const BoxDecoration(
                border: BorderDirectional(
                    bottom: BorderSide(color: Colors.blue, width: 1.0))),
            padding: const EdgeInsets.all(7),
            child: SingleChildScrollView(
              child: Row(
                children: [
                  profilePicture(),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(widget.nickname,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      SystemSound.play(SystemSoundType.click);
                      addContact();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(100)),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                            child: Text(
                              inContacts
                                  ? "Already in contacts"
                                  : "Add to contacts",
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          inContacts
                              ? const Icon(
                                  Icons.task_alt_rounded,
                                  color: Colors.blue,
                                  size: 32,
                                )
                              : const Icon(
                                  Icons.add_circle_outline,
                                  color: Colors.blue,
                                  size: 32,
                                ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
    }
    return GestureDetector(
        onTap: () {
          SystemSound.play(SystemSoundType.click);
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
                  name: widget.nickname,
                  radius: 21,
                  fontsize: 21,
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.nickname,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Spacer(),
                const LoadingIndicatorFb1()
              ],
            ),
          ),
        ));
  }
}
