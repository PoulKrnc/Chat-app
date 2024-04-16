import 'dart:developer';

import 'package:animate_gradient/animate_gradient.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_time/date_time.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:pavli_text/widget_classes/game_widgets/my_animated_gradient.dart';

class Tictactoe extends StatefulWidget {
  final Map<String, dynamic> data;
  const Tictactoe({super.key, required this.data});

  @override
  _TictactoeState createState() => _TictactoeState();
}

class _TictactoeState extends State<Tictactoe> {
  var db = FirebaseFirestore.instance;
  bool contactsReady = false;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> contactList = [];
  bool invitationPending = false;
  late QueryDocumentSnapshot<Map<String, dynamic>> invitedContact;

  void gameSetup() async {
    db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("games")
        .doc("TicTacToe")
        .set({"online": false});
  }

  void loadContacts() async {
    db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .get()
        .then((value) {
      var docs = value.docs;
      for (int i = 0; i < docs.length; i++) {
        if (!docs[i].data()["Blocked"]) {
          var d = docs[1];
          setState(() {
            contactList.add(docs[i]);
          });
        }
      }
      contactsReady = true;
      setState(() {
        contactsReady = true;
      });
    });
  }

  void sendMessage(String opponent, String gameSession) async {
    String text =
        widget.data["Nickname"] + " invited you to a game of TicTacToe";
    String chatId = (await db
            .collection("nicknames")
            .doc(widget.data["Nickname"])
            .collection("contacts")
            .doc(opponent)
            .get())
        .data()!["ChatName"];
    log(chatId);

    //pushNotification(text);
    await db.collection("chats").doc(chatId).collection("chats").add({
      "Text": text,
      "Sender": widget.data["Nickname"],
      "Date": FieldValue.serverTimestamp(),
      "ReplyText": "",
      "ReplySender": "",
      "Type": "GameInvitation",
      "GameSession": gameSession
    });
    var time = Timestamp.now();
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("contacts")
        .doc(opponent)
        .update({
      "LastChatDate": time,
      "LastChat": text,
      "LastChatSender": widget.data["Nickname"]
    });
    await db
        .collection("nicknames")
        .doc(opponent)
        .collection("contacts")
        .doc(widget.data["Nickname"])
        .update({
      "LastChatDate": time,
      "LastChat": text,
      "LastChatSender": widget.data["Nickname"]
    });

    //viewChatEdit1();
  }

  void selectUser(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    log(doc.id);
    Utils.showSnackBar("Invited ${doc.id} to the game.");
    Navigator.of(context).pop();
    DocumentReference<Map<String, dynamic>> sessionDoc = await db
        .collection("gamesessions")
        .add({
      "Host": widget.data["Nickname"],
      "Opponent": doc.id,
      "Started": false
    });
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("games")
        .doc("TicTacToe")
        .set({
      "online": true,
      "waitingOpponent": true,
      "opponent": doc.id,
      "gameSession": sessionDoc.id
    });
    sendMessage(doc.id, sessionDoc.id);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Hero(
              tag: "TicTacToe1",
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6)),
                child: Image.asset(
                  "assets/TICTACTOE.png",
                  height: 80,
                ),
              )),
          const SizedBox(
            width: 10,
          )
        ],
        title: Hero(
            tag: "TicTacToe",
            child: Container(
              child: Text("TicTacToe",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      )),
            )),
      ),
      body: SafeArea(
          child: StreamBuilder(
              stream: db
                  .collection("nicknames")
                  .doc(widget.data["Nickname"])
                  .collection("games")
                  .doc("TicTacToe")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.data == null ||
                    snapshot.data!.data() == null ||
                    !snapshot.hasData) {
                  // IF GAME IS NOT EVEN SET UP #ERROR
                  gameSetup();
                  return MyAnimatedGradient(
                    child: Center(
                      child: Text("Loading",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white,
                              )),
                    ),
                  );
                } else if (snapshot.data!.data()!["online"]) {
                  // IF GAME IS ONLINE
                  if (snapshot.data!.data()!["waitingOpponent"]) {
                    log(snapshot.data!.data()!["opponent"]);
                    return Text("data");
                  } else {
                    log("wtf");
                  }
                } else if (!snapshot.data!.data()!["online"]) {
                  log("fsafsafsaf");
                  return MyAnimatedGradient(
                    child: Center(
                        child: GestureDetector(
                      onTap: () {
                        clickSound();
                        startNewGame();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text("Start new game",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.blue,
                                )),
                      ),
                    )),
                  );
                }
                return Column(
                  children: [Text(snapshot.data!["online"].toString())],
                );
              })),
    );
  }

  void startNewGame() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            child: Column(children: [
              const Text(
                "Choose an opponent",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              contactsReady
                  ? Column(
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        for (var contact in contactList) ...[
                          Row(
                            children: [
                              const Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    clickSound();
                                    selectUser(contact);
                                  },
                                  child: Container(
                                      width: MediaQuery.of(context).size.width /
                                          1.5,
                                      margin: const EdgeInsets.all(2),
                                      padding:
                                          const EdgeInsets.fromLTRB(7, 3, 7, 3),
                                      decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          border:
                                              Border.all(color: Colors.blue),
                                          borderRadius:
                                              BorderRadius.circular(11)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            contact.id,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          const Icon(
                                            Icons.inbox_rounded,
                                            color: Colors.blue,
                                            size: 30,
                                          )
                                        ],
                                      ))),
                              const Spacer()
                            ],
                          ),
                        ]
                      ],
                    )
                  : const Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        LoadingIndicatorFb1()
                      ],
                    ),
            ]),
          ),
        );
      },
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    ).then((value) {});
  }
}
