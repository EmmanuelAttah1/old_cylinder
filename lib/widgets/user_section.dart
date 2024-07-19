import 'package:flutter/material.dart';

class UserSection extends StatelessWidget {
  const UserSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(20),
        child:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "Hello Emmanuel",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text(
                "What are you cooking today?",
                style: TextStyle(fontSize: 16),
              )
            ]),
            ClipOval(
              child: Container(
                width:40,
                height: 40,
                color: const Color.fromARGB(255, 211, 208, 208),
              ),
            ),
          ],
        ),
      ),
    ]);
  }
}