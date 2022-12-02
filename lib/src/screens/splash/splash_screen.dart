import 'package:flutter/material.dart';

/// Screen to display when app is loading authentication session
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   Container(
        decoration:  const BoxDecoration(color: Colors.lightBlue),
    child:  const Center(
    child:  Text("Loading...."),
    ),
    );
  }
}
