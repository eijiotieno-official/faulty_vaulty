import 'package:flutter/material.dart';

class PasscodeInputWidget extends StatelessWidget {
  final int value;
  final Function function;

  const PasscodeInputWidget(
      {super.key, required this.value, required this.function});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: GestureDetector(
        onTap: () {
          function(value: value);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).hoverColor,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Center(
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
