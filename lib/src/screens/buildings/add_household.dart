import 'package:flutter/material.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class AddHouseHoldScreen extends StatefulWidget {
  final Building building;

  const AddHouseHoldScreen({Key? key, required this.building}) : super(key: key);

  @override
  State<AddHouseHoldScreen> createState() => _AddHouseHoldScreenState();
}

class _AddHouseHoldScreenState extends State<AddHouseHoldScreen> {
  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      appBar: AppBar(
        title: Text('Add Household'),
      ),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('House Number: ${widget.building.houseNumber}'),
            Text('Location: ${widget.building.location}'),
            SizedBox(height: 16,),
            SingleChildScrollView(
              child: Text('Form Here'),
            )
          ],
        ));
  }
}
