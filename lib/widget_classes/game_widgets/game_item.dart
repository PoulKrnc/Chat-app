import 'package:flutter/material.dart';
import 'package:pavli_text/utils/utils.dart';
import 'package:pavli_text/widget_classes/game_widgets/tictactoe.dart';

class GameItem extends StatefulWidget {
  final Widget page;
  final String title;
  final String img;
  final Map<String, dynamic> data;
  const GameItem(
      {Key? key,
      required this.page,
      required this.title,
      required this.img,
      required this.data})
      : super(key: key);

  @override
  _GameItemState createState() => _GameItemState();
}

class _GameItemState extends State<GameItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        clickSound();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => widget.page),
        ).then((value) => setState(() {}));
      },
      child: Container(
        margin: EdgeInsets.all(6),
        padding: EdgeInsets.fromLTRB(15, 6, 15, 6),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 1),
            borderRadius: BorderRadius.circular(7)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: widget.title,
                  child: Container(
                    child: Text(widget.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                )),
                  ),
                ),
                Text(
                  "Play ${widget.title} with friends",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            Spacer(),
            Hero(
              tag: "${widget.title}1",
              child: Container(
                margin: EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6)),
                child: Image.asset(
                  widget.img,
                  height: 80,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
