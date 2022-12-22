import 'package:flutter/material.dart';

class AppBaseScreen extends StatelessWidget {
  final Widget child;
  final bool? isLoading;
  final AppBar? appBar;
  final EdgeInsetsGeometry? padding;

  const AppBaseScreen({Key? key,
    required this.child,
    this.isLoading = false, this.appBar, this.padding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: appBar,
        body: Stack(
          alignment: AlignmentDirectional.center,
          children: [
        Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
            isLoading! ? const CircularProgressIndicator() : Container(),
          ],
        ));
  }
}
