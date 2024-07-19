import 'package:flutter/material.dart';

class BluetoothItem extends StatelessWidget {

  final int index;
  final String title;
  final Future<void> Function(int index) connectFunction;

  const BluetoothItem({
    super.key, required this.title, required this.connectFunction, required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: (){
        debugPrint("pressed");
        connectFunction(index);
      },
      leading: const Icon(
          Icons.bluetooth,
          size: 24,
        ),
        title: Text(title,),
    );
  }
}