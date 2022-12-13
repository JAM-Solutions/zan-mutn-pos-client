import 'package:flutter/material.dart';

class AppListviewBuilder extends StatelessWidget {
  final String title;
  final String number;
  final String text;
  final Function onTap;
  final bool disabled;
  const AppListviewBuilder({Key? key, required this.text, required this.number, required this.title, required this.onTap,this.disabled = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: BouncingScrollPhysics(),
    shrinkWrap: true,
    itemBuilder: (context, index) {
          return Column(
            children: [
              ListTile(
                onTap: disabled ? null : () => onTap(),
              leading: Text(number),
                title: Text(title),
                trailing: Text(text),
          ),
            ],
          );
    }
    );
  }
}
