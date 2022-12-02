import 'package:flutter/material.dart';

class AppScreen extends StatelessWidget {
  final Widget child;
  final bool? isLoading;
  const AppScreen({Key? key, required this.child, this.isLoading = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
      Padding(
      padding: const EdgeInsets.all(16.0),
          child: child,
        ),
          isLoading! ? const CircularProgressIndicator() : Container(),
        ],
      )
    ));
  }
}
