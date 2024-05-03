import 'package:flutter/material.dart';
import 'package:pavli_text/widget_classes/game_widgets/my_animated_gradient.dart';

class Chess extends StatefulWidget {
  const Chess({Key? key}) : super(key: key);

  @override
  _ChessState createState() => _ChessState();
}

class _ChessState extends State<Chess> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            Hero(
                tag: "Chess1",
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6)),
                  child: Image.asset(
                    "assets/CHESS.png",
                    height: 80,
                  ),
                )),
            const SizedBox(
              width: 10,
            )
          ],
          title: Hero(
              tag: "Chess",
              child: Container(
                child: Text("Chess",
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        )),
              )),
        ),
        body: SafeArea(
          child: MyAnimatedGradient(
              child: Center(
                  child: Text("Coming soon",
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              )))),
        ));
  }
}
