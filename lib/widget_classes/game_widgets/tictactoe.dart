// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
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
  bool _waiter = true;

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
    await db.collection("chats").doc(chatId).collection("chats").add({
      "Text": text,
      "Sender": widget.data["Nickname"],
      "Date": FieldValue.serverTimestamp(),
      "ReplyText": "",
      "ReplySender": "",
      "Type": "GameInvitation",
      "GameType": "TicTacToe",
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
    pushNotification(text, opponent);
    //viewChatEdit1();
  }

  void selectUser(QueryDocumentSnapshot<Map<String, dynamic>> doc) async {
    log(doc.id);
    Utils.showSnackBar("Invited ${doc.id} to the game.");
    Navigator.of(context).pop();
    await db
        .collection("nicknames")
        .doc(widget.data["Nickname"])
        .collection("games")
        .doc("TicTacToe")
        .get()
        .then((value) async {
      try {
        await db
            .collection("gamesessions")
            .doc(value.data()!["gameSession"])
            .update({"Started": true});
      } catch (e) {
        log(e.toString());
      }
    });
    DocumentReference<Map<String, dynamic>> sessionDoc =
        await db.collection("gamesessions").add({
      "Host": widget.data["Nickname"],
      "Opponent": doc.id,
      "Started": false,
      "Data": [
        {"1": "", "2": "", "3": ""},
        {"1": "", "2": "", "3": ""},
        {"1": "", "2": "", "3": ""}
      ],
      "Turn": doc.id,
      "TurnData": "X",
      "Finished": false,
      "Winner": ""
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

  void surrender(
      AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
          gameSnapshot) async {
    showDialog(
        context: context,
        builder: (context) {
          return Center(
              child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Do you really want to surrender?",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              clickSound();
                              String winner = "";
                              if (gameSnapshot.data!.data()!["Host"] ==
                                  widget.data["Nickname"]) {
                                winner = gameSnapshot.data!.data()!["Opponent"];
                              } else {
                                winner = gameSnapshot.data!.data()!["Host"];
                              }
                              await db
                                  .collection("gamesessions")
                                  .doc(gameSnapshot.data!.id.toString())
                                  .update({"Finished": true, "Winner": winner});
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "Yes",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          ),
                          const SizedBox(
                            width: 40,
                          ),
                          GestureDetector(
                            onTap: () {
                              clickSound();
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              "No",
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                          )
                        ],
                      )
                    ],
                  )));
        });
  }

  void winCheck(DocumentSnapshot<Map<String, dynamic>> gameData, int x, int y,
      String turnData) async {
    log("winCheck");
    List data = gameData.data()!["Data"];
    data[x][y.toString()] = turnData;
    bool win = false;
    for (int i = 0; i < 3; i++) {
      if (data[i]["1"] == turnData &&
          data[i]["2"] == turnData &&
          data[i]["3"] == turnData) {
        log("win1");
        win = true;
      }
      if (data[0][(i + 1).toString()] == turnData &&
          data[1][(i + 1).toString()] == turnData &&
          data[2][(i + 1).toString()] == turnData) {
        log("win2");
        win = true;
      }
    }
    if (data[0][(1).toString()] == turnData &&
        data[1][(2).toString()] == turnData &&
        data[2][(3).toString()] == turnData) {
      log("win3");
      win = true;
    } else if (data[2][(1).toString()] == turnData &&
        data[1][(2).toString()] == turnData &&
        data[0][(3).toString()] == turnData) {
      log("win4");
      win = true;
    }
    if (win) {
      await db
          .collection("gamesessions")
          .doc(gameData.id)
          .update({"Finished": true, "Winner": widget.data["Nickname"]});
    }
  }

  void pushNotification(String message, String opponent) async {
    log("______________Notification sent_______________");
    List<dynamic> tokenList = [];

    await db.collection("nicknames").doc(opponent).get().then((value) {
      try {
        tokenList = value.data()!["tokenList"];
      } catch (e) {
        tokenList = [];
      }
    });
    for (String tokenL in tokenList) {
      try {
        Map<String, Object> body;

        body = {
          "to": tokenL,
          "notification": {"title": widget.data["Nickname"], "body": message}
        };

        var res = await post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            body: jsonEncode(body),
            headers: {
              HttpHeaders.contentTypeHeader: "application/json",
              HttpHeaders.authorizationHeader:
                  "key=AAAAWCL3XpU:APA91bFxP_DGH1VXWWteQB9ov-KBLF3xzGmklUhlgQCMrw2H3laoTNAIeke6ccpPvxw7bQD9gYzTlzyy__55RKfjk6TuS3F8TnHwSwB_zJgaMhgUBmGA_5uSLkp8oAywzJd4Z74e6Yhk"
            });
        log("Notification response: ${res.body}");
      } catch (e) {
        log("Nottification error: $e");
      }
    }
  }

  void waiter() async {
    setState(() {
      _waiter = false;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _waiter = true;
    });
  }

  @override
  void initState() {
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
              decoration: const BoxDecoration(),
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
                  return MyAnimatedGradient(
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          clickSound();
                          gameSetup();
                        },
                        child: Text("Setup",
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                )),
                      ),
                    ),
                  );
                } else if (snapshot.data!.data()!["online"]) {
                  // IF GAME IS ONLINE
                  if (snapshot.data!.data()!["waitingOpponent"]) {
                    // IF PERSON IS WAITING FOR OPPONENT
                    log(snapshot.data!.data()!["opponent"]);
                    return MyAnimatedGradient(
                        child: Center(
                            child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Waiting for an opponent",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        GestureDetector(
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
                            child: Text("Invite another person",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall!
                                    .copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: Colors.blue,
                                    )),
                          ),
                        ),
                      ],
                    )));
                  } else {
                    // IF GAME IS ALL SET
                    return MyAnimatedGradient(
                        child: StreamBuilder(
                      stream: db
                          .collection("gamesessions")
                          .doc(snapshot.data!.data()!["gameSession"])
                          .snapshots(),
                      builder: (context, gameSnapshot) {
                        List lst = [];
                        try {
                          lst = gameSnapshot.data!.data()!["Data"];
                        } catch (e) {
                          return const Center(child: Text("LOADING"));
                        }
                        bool finished = gameSnapshot.data!.data()!["Finished"];
                        String winner = gameSnapshot.data!.data()!["Winner"];
                        String turn = gameSnapshot.data!.data()!["Turn"];
                        String host = gameSnapshot.data!.data()!["Host"];
                        String opponent =
                            gameSnapshot.data!.data()!["Opponent"];

                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (finished) ...[
                                Text(
                                  "You ${winner == widget.data["Nickname"] ? "Won" : "Lost"}",
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                )
                              ] else if (turn == widget.data["Nickname"]) ...[
                                Text(
                                  "Your turn",
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                )
                              ] else ...[
                                Text(
                                  "",
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                )
                              ],
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Theme.of(context).canvasColor),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (int i = 0; i < 3; i++) ...[
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          for (int j = 1; j <= 3; j++) ...[
                                            GestureDetector(
                                              onTap: () async {
                                                if (!_waiter) {
                                                  Utils.showSnackBar("Wait");
                                                  return;
                                                }
                                                waiter();
                                                clickSound();
                                                if (finished) {
                                                  Utils.showSnackBar(
                                                      "Game already finished");
                                                  return;
                                                }
                                                if (lst[i][j.toString()] !=
                                                    "") {
                                                  Utils.showSnackBar("Invalid");
                                                  return;
                                                }
                                                if (turn ==
                                                    widget.data["Nickname"]) {
                                                  clickSound();
                                                  lst[i][j.toString()] =
                                                      gameSnapshot.data!
                                                          .data()!["TurnData"];
                                                  String turnData = "";
                                                  String nextTurn = "";
                                                  if (gameSnapshot.data!
                                                              .data()![
                                                          "TurnData"] ==
                                                      "X") {
                                                    turnData = "O";
                                                  } else {
                                                    turnData = "X";
                                                  }

                                                  if (turn == host) {
                                                    nextTurn = opponent;
                                                  } else {
                                                    nextTurn = host;
                                                  }
                                                  await db
                                                      .collection(
                                                          "gamesessions")
                                                      .doc(snapshot.data!
                                                              .data()![
                                                          "gameSession"])
                                                      .update({
                                                    "Data": lst,
                                                    "TurnData": turnData,
                                                    "Turn": nextTurn
                                                  });
                                                  winCheck(
                                                      gameSnapshot.data!,
                                                      i,
                                                      j,
                                                      gameSnapshot.data!
                                                          .data()!["TurnData"]);
                                                } else {
                                                  Utils.showSnackBar(
                                                      "Not your turn");
                                                }
                                              },
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              1.5)),
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width /
                                                      4,
                                                  child: Center(
                                                      child: Text(
                                                    lst[i][j.toString()],
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleLarge,
                                                  ))),
                                            ),
                                          ],
                                        ],
                                      )
                                    ]
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (!finished) ...[
                                GestureDetector(
                                  onTap: () {
                                    clickSound();
                                    surrender(gameSnapshot);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text("Surrender",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                              color: Colors.blue,
                                            )),
                                  ),
                                ),
                              ] else ...[
                                GestureDetector(
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
                                )
                              ]
                            ],
                          ),
                        );
                      },
                    ));
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
                return MyAnimatedGradient(
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        clickSound();
                        gameSetup();
                      },
                      child: Text("Setup",
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                                color: Colors.white,
                              )),
                    ),
                  ),
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
