import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const Color primaryColor =  Color(0xFF06a9c6);
const Color dangerColor =  Colors.red;

final ThemeData defaultTheme = ThemeData(
  primaryColor: primaryColor,
  secondaryHeaderColor: Colors.tealAccent,
  fontFamily: 'OpenSans',
  textTheme: const TextTheme(
    headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
  ),
  appBarTheme: const AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(0, 255, 255, 255)
    ),
    color: primaryColor,
    titleTextStyle: TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 24
    ),
    elevation: 0
  ),
 textButtonTheme: TextButtonThemeData(
   style: TextButton.styleFrom(
     foregroundColor: primaryColor,
   ),
 ),
 elevatedButtonTheme: ElevatedButtonThemeData(
   style: ElevatedButton.styleFrom(
     backgroundColor: primaryColor,
   ),
 ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: primaryColor
  ),
  iconTheme: const IconThemeData(
    color: Color.fromARGB(200, 110, 114, 116)
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryColor
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    showUnselectedLabels: true,
    unselectedIconTheme: IconThemeData(
        color: Color(0xFF000000),
         size: 18
    ),
    unselectedItemColor: Color(0xFF000000),
    unselectedLabelStyle: TextStyle(
      color: Color(0xFF000000),
      fontSize: 12,
      overflow: TextOverflow.clip,
        fontFamily: 'Roboto'
    ),
    selectedLabelStyle: TextStyle(
        color: primaryColor,
      fontSize: 12,
      fontWeight: FontWeight.bold,
      fontFamily: 'Roboto'
    ),
    selectedItemColor: primaryColor,
    selectedIconTheme: IconThemeData(
      color: primaryColor,
        size: 18
    )
  ),
  inputDecorationTheme: const InputDecorationTheme(
     labelStyle: TextStyle(fontSize: 14),
      border: OutlineInputBorder(
        borderSide: BorderSide(width: 1),
      ) ,
      errorBorder:   OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: dangerColor),
      ),
    focusedBorder:OutlineInputBorder(
      borderSide: BorderSide(width: 0.9, color: primaryColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(width: 0.9, color: dangerColor),
    )

  ),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    backgroundColor:  Color.fromARGB(255, 50, 50, 50),
    elevation: 4,
    actionTextColor: Colors.white,
  )
);
