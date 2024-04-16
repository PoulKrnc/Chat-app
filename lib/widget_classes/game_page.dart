import 'package:flutter/material.dart';
import 'package:pavli_text/widget_classes/game_widgets/game_item.dart';
import 'package:pavli_text/widget_classes/game_widgets/tictactoe.dart';

class GamePage extends StatefulWidget {
  final Map<String, dynamic> data;
  final Map<String, dynamic> setupsList;
  const GamePage({super.key, required this.data, required this.setupsList});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Games")),
      body: SafeArea(
        child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                GameItem(
                  page: Tictactoe(
                    data: widget.data,
                  ),
                  title: "TicTacToe",
                  img: "assets/TICTACTOE.png",
                  data: widget.data,
                )
              ],
            )),
      ),
    );
  }
}
