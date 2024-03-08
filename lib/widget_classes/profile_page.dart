// ignore_for_file: library_private_types_in_public_api, prefer_interpolation_to_compose_strings

import 'package:pavli_text/set_stuff/settings_page.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:pavli_text/widget_classes/edit_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class ProfilePage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> setupsList;
  const ProfilePage({Key? key, required this.data, required this.setupsList})
      : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser!;
  var db = FirebaseFirestore.instance;
  var nicknameData;
  bool setupReady = false;
  bool profileSwitch = false;

  void setup() async {
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .get()
        .then((value) {
      setState(() {
        nicknameData = value.data();
      });
    });
    setupReady = true;
  }

  void dialogBuilder(BuildContext context) {}

  void logOut() async {
    List<dynamic> tokenList = [];
    String? token = await FirebaseMessaging.instance.getToken();
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .get()
        .then((value) {
      tokenList = value.data()!["tokenList"];
    });
    tokenList.remove(token);
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .update({"tokenList": tokenList});
    Navigator.pop(context);
    FirebaseAuth.instance.signOut();
  }

  @override
  void initState() {
    // TODO: implement initState
    setup();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!setupReady) {
      return Scaffold(
        appBar: AppBar(),
        body: Utils.loadingScaffold(),
      );
    } else {
      return Scaffold(
        endDrawer: Drawer(
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(15, 5, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SettingsPage()),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        decoration: const BoxDecoration(),
                        child: const Row(
                          children: [
                            Icon(Icons.settings),
                            Text(
                              "Settings",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ],
                        ),
                      )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfile(
                                    data: widget.data,
                                  )),
                        ).then((value) {
                          setState(() {});
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        decoration: const BoxDecoration(),
                        child: const Row(
                          children: [
                            Icon(Icons.person),
                            Text(
                              "Edit profile",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ],
                        ),
                      )),
                  GestureDetector(
                      onTap: logOut,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        decoration: const BoxDecoration(),
                        child: const Row(
                          children: [
                            Icon(Icons.logout),
                            Text(
                              "Log out",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 18),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
        ),
        appBar: AppBar(
          title: PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (context) {
                        return EditProfile(
                          data: widget.data,
                        );
                      })).then((value) {
                        setState(() {});
                      });
                    },
                    child: const Text(
                      "Edit profile",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      FirebaseAuth.instance.signOut();
                    },
                    child: const Text(
                      "Log Out",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ];
            },
            child: Row(
              children: [
                /*
                ProfilePicture(
                  name: widget.data["Nickname"],
                  radius: 21,
                  fontsize: 21,
                  img: nicknameData["ProfilePicUrl"],
                ),
                const SizedBox(
                  width: 10,
                ),*/
                Text(
                  widget.data["Nickname"],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                profileSwitch
                    ? const Icon(Icons.arrow_forward_ios)
                    : const Icon(Icons.keyboard_arrow_down)
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 1, 15, 0),
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfilePicture(
                            name: widget.data["Nickname"],
                            radius: 38,
                            fontsize: 21,
                            img: nicknameData["ProfilePicUrl"],
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(9, 0, 0, 0),
                            padding: const EdgeInsets.fromLTRB(11, 11, 11, 11),
                            decoration: const BoxDecoration(
                                border: Border(
                                    left: BorderSide(
                                        color: Colors.blue, width: 2.3))),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${widget.data["Nickname"]}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  user.email!,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        child: Container(),
                      )
                    ],
                  )

                  /*
                  Text(
                    "Loged in as: ${user.email!}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Nickname: ${widget.data["Nickname"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Birthday: ${widget.data["Date_born"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text("Version: " + widget.setupsList["Version"]),
                  */
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
