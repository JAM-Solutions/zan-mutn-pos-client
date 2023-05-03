import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

/// Screen to display when app is loading authentication session
class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   const MaterialApp(
      home:  AppBaseScreen(
        child:  Center(
        child:  Text("Configuration Loading....", textDirection: TextDirection.ltr,),
        ),
      ),
    );
  }
}
