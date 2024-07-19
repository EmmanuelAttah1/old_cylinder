import 'package:flutter/material.dart';


class RefilDate extends StatelessWidget {
  final String title;
  final String? date;

  const RefilDate({
    super.key, required this.title, required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Container(
          decoration: BoxDecoration(
              color: const Color(0xFFC9D4DB),
              borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal:20, vertical: 30),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(date!)
            ],
          )),
    );
  }
}