import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final Function onPress;
  final String label;

  const AppButton({Key? key, required this.onPress, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  ElevatedButton(
        onPressed: () => onPress(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor, // Set the background color
      ),
        child: Text(label),
    );
  }
}
