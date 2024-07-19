import './custom_animate_border.dart';
import 'package:flutter/material.dart';

class AnimatedTextField extends StatefulWidget {
  final String label;
  final Widget? suffix;
  final TextEditingController? inputController;

  const AnimatedTextField({Key? key, required this.label, required this.suffix, this.inputController})
      : super(key: key);

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with SingleTickerProviderStateMixin {
  AnimationController? controller;
  late Animation<double> alpha;
  final focusNode = FocusNode();

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    final Animation<double> curve =
        CurvedAnimation(parent: controller!, curve: Curves.easeInOut);
    alpha = Tween(begin: 0.0, end: 1.0).animate(curve);

    // controller?.forward();
    controller?.addListener(() {
      setState(() {});
    });
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        controller?.forward();
      } else {
        controller?.reverse();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: const BorderRadius.all(Radius.circular(8))),
      child: Theme(
        data: ThemeData(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.cyan,
                )),
        child: CustomPaint(
          painter: CustomAnimateBorder(alpha.value),
          child: TextFormField(
              validator: (value) {
              if (value == null || value.isEmpty) {
                return 'This Field is required';
              }
              return null;
            },
            controller: widget.inputController,
            focusNode: focusNode,
            decoration: InputDecoration(
              label: Text(widget.label, style: const TextStyle(fontSize: 14),),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              suffixIcon: widget.suffix,
            ),
          ),
        ),
      ),
    );
  }
}
