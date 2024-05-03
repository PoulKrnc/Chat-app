import 'package:flutter/material.dart';
import 'package:pavli_text/utils/utils.dart';

class GameItem extends StatefulWidget {
  final Widget page;
  final String title;
  final String img;
  final Map<String, dynamic> data;
  final String text;
  const GameItem(
      {super.key,
      required this.page,
      required this.title,
      required this.img,
      required this.data,
      required this.text});

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
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.fromLTRB(15, 6, 15, 6),
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
                    decoration: const BoxDecoration(),
                    child: Text(widget.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20,
                                )),
                  ),
                ),
                Text(
                  widget.text,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const Spacer(),
            Hero(
              tag: "${widget.title}1",
              child: Container(
                margin: const EdgeInsets.all(3),
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
