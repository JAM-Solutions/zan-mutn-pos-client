import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/models/household.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/building_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_listview_builder.dart';

class ViewHouseHoldScreen extends StatefulWidget {
  final Building building;

  const ViewHouseHoldScreen({Key? key, required this.building})
      : super(key: key);

  @override
  State<ViewHouseHoldScreen> createState() => _ViewHouseHoldScreenState();
}

class _ViewHouseHoldScreenState extends State<ViewHouseHoldScreen> {
  Households? housedetails;
  void fetch(houseNumber, id) async {
    housedetails =
        await context.read<BuildingProvider>().fetchHouseholds(houseNumber, id);
  }

  @override
  void initState() {
    super.initState();
    fetch(widget.building.houseNumber, widget.building.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BuildingProvider>(builder: (context, provider, child) {
      List<Households> housedetails = provider.houseHolds;
      return MessageListener<BuildingProvider>(
        child: AppBaseScreen(
            isLoading: provider.fyIsLoading,
            appBar: AppBar(
              title: const Text('View Household'),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Text('Name'),
                      Spacer(),
                      Text('Control Number'),
                      SizedBox(
                        width: 20,
                      ),
                    ],
                  ),
                  ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Card(
                            elevation: 2,
                            child: ListTile(
                              onTap: () => null,
                              title: Text(housedetails[index]
                                  .taxPayerName
                                  .toString()
                                  .toUpperCase()),
                              trailing: Text(
                                  housedetails[index].controlNumber == null
                                      ? ''
                                      : housedetails[index].controlNumber),
                            ),
                          ),
                        ],
                      );
                    },
                    itemCount:
                        housedetails.isNotEmpty ? housedetails.length : 0,
                  )
                ],
              ),
            )),
      );
    });
  }
}
