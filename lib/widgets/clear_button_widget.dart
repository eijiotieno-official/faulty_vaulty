import 'package:flutter/material.dart';

class ClearButtonWidget extends StatelessWidget {
  const ClearButtonWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).hoverColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(
            child: Icon(Icons.backspace_rounded, size: 30),
          ),
        ),
      ),
    );
  }
}
