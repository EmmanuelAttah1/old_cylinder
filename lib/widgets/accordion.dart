import 'package:flutter/material.dart';

class CustomAccordion extends StatefulWidget {
  final Widget title;
  final Widget content;
  final bool opened;
  final void Function(dynamic index) openTab;
  final int index;

  const CustomAccordion(
      {Key? key,
      required this.title,
      required this.content,
      required this.opened, required this.openTab, required this.index,})
      : super(key: key);

  @override
  _CustomAccordionState createState() => _CustomAccordionState();
}

class _CustomAccordionState extends State<CustomAccordion> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        GestureDetector(
          onTap: () {
            widget.openTab(widget.index);
          },
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(0),
              color: const Color.fromARGB(255, 251, 249, 249),
            ),
            child: Row(
              children: <Widget>[
                Expanded(child: widget.title),
                Icon(
                  widget.opened ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (widget.opened)
          Container(
              color: const Color.fromARGB(255, 251, 249, 249),
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
              margin: const EdgeInsets.only(bottom: 20),
              width: double.maxFinite,
              child: widget.content),
      ],
    );
  }
}
