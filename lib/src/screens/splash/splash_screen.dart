import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

/// Screen to display when app is loading authentication session
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   const Padding(
      padding:  EdgeInsets.all(16.0),
      child:  Center(
      child:  Text("Loading....", textDirection: TextDirection.ltr,),
      ),
    );
  }
}
