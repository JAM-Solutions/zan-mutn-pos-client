import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:zanmutm_pos_client/src/services/buildings_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_card.dart';
import 'package:zanmutm_pos_client/src/widgets/app_visibility.dart';

class Buildings extends StatefulWidget {
  const Buildings({super.key});

  @override
  State<Buildings> createState() => _BuildingsState();
}

class _BuildingsState extends State<Buildings> {
  searchHousenumber(houseNumber) {
    Future.delayed(Duration.zero, () => _loadHousenumber(houseNumber));
  }

  List buildingids = [];
  _loadHousenumber(String houseNumber) {
    setState(() {
      buildingids = BuildingsService().gethousenumber(houseNumber) as List;
      if (buildingids.isEmpty) {
        register = true;
      } else {
        register = false;
      }
    });
  }

  final _formKey = GlobalKey<FormBuilderState>();
  final TextEditingController controller = TextEditingController();
  bool register = false;

  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
        appBar: AppBar(
          title: const Text('Household'),
          centerTitle: true,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: controller,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(36),
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      searchHousenumber(controller.text);
                    })
              ],
            ),
            AppVisibility(
              visible: register,
              child: AppCard(
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: controller,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(36),
                          borderSide: BorderSide(
                              color: Theme.of(context).primaryColor)),
                    ),
                  ),
                ),
              ),
            ),
            AppVisibility(
              visible: buildingids.isEmpty ? false : true,
              child: const AppCard(
                  child: Center(
                child: Text('data'),
              )),
            ),
          ],
        ));
    ;
  }
}
