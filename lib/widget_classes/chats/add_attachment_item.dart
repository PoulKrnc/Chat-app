// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class AddAttachmentItem extends StatefulWidget {
  final IconData iconData;
  final double size;
  const AddAttachmentItem(
      {super.key, required this.iconData, required this.size});

  @override
  _AddAttachmentItemState createState() => _AddAttachmentItemState();
}

class _AddAttachmentItemState extends State<AddAttachmentItem> {
  bool doer = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Icon(
      widget.iconData,
      color: Colors.blue,
      size: widget.size,
    );
  }
}
