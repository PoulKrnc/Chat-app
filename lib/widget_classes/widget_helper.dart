import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pavli_text/utils/utils.dart';

class ContactIconSearch extends StatefulWidget {
  const ContactIconSearch({Key? key, required this.icon}) : super(key: key);
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
          return const PeopleSearch();
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

class PeopleSearch extends StatefulWidget {
  const PeopleSearch({Key? key}) : super(key: key);

  @override
  _PeopleSearchState createState() => _PeopleSearchState();
}

class _PeopleSearchState extends State<PeopleSearch> {
  Widget crossWidget = Container(
    padding: const EdgeInsets.fromLTRB(4, 1, 16, 1),
  );

  void animation() async {
    await Future.delayed(const Duration(milliseconds: 0));
    setState(() {
      crossWidget = Container(
          padding: const EdgeInsets.fromLTRB(4, 1, 16, 1),
          child: const TextField(
            decoration: InputDecoration(
                hintText: "Nickname",
                isDense: true,
                border: InputBorder.none,
                disabledBorder: InputBorder.none),
          ));
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    animation();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: "searchIcon",
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 4, 0, 4),
            decoration: BoxDecoration(
                color: Colors.blue.shade400,
                borderRadius: BorderRadius.circular(100)),
            child: Row(
              children: [
                Container(
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
                Container(child: Expanded(child: crossWidget))
              ],
            ),
          ),
        ),
      ),
      body: Container(),
    );
  }
}
