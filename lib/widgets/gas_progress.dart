import 'package:flutter/material.dart';

class GasProgress extends StatelessWidget {

  final double progress;
  final double gasUsed;


  const GasProgress({
    super.key,
    required this.progress,
    required this.gasUsed
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(children: [
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: CircularProgressIndicator(
            value: progress, // Progress value from 0.0 to 1.0
            strokeWidth: 8, // Thickness of the progress indicator
            backgroundColor:
                Colors.grey, // Background color of the progress indicator
            valueColor: AlwaysStoppedAnimation<Color>(
                progress <= 0.5 && progress > 0.3?
                const Color.fromRGBO(246, 186, 77, 1)
                :
                progress <= 0.3?
                const Color.fromARGB(255, 119, 45, 45)
                :
                const Color(0xFF4F772D)
                ), // Color of the progress indicator
          ),
        ),
        Positioned(
            width: 200,
            height: 200,
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${(progress * 100).toInt()}%",
                    style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500,),
                  ),
                  Text("${double.parse(gasUsed.toStringAsFixed(1))}kg of gas used"),
                ]))
      ]),
    );
  }
}
