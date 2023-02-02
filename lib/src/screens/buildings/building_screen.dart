import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/building_provider.dart';
import 'package:zanmutm_pos_client/src/services/buildings_service.dart';
import 'package:zanmutm_pos_client/src/services/service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_card.dart';
import 'package:zanmutm_pos_client/src/widgets/app_container.dart';
import 'package:zanmutm_pos_client/src/widgets/app_fetcher.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_dropdown.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_table.dart';
import 'package:zanmutm_pos_client/src/widgets/app_visibility.dart';

class BuildingsScreen extends StatefulWidget {
  const BuildingsScreen({super.key});

  @override
  State<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends State<BuildingsScreen> {
  searchHouseNumber(houseNumber) {
    Future.delayed(Duration.zero, () => _loadHouseNumber(houseNumber));
  }

  var buildingIds;
  _loadHouseNumber(String houseNumber) async {
    Building? building = (await getIt<BuildingsService>()
        .gethousenumber(houseNumber));
    debugPrint(buildingIds.toString());
    if (building == null) {
      setState(() {
        register = true;
        view = false;
      });
    } else {
      setState(() {
        register = false;
        view = true;
      });
    }
  }

  void _onPressed() {
    var payload = formkey.currentState?.value;
    BuildingsService().registerHouse(payload);
  }

  final _formKey = GlobalKey<FormBuilderState>();
  final formkey = GlobalKey<FormBuilderState>();
  final TextEditingController houseNumber = TextEditingController();
  bool register = false;
  bool view = false;
  bool showStreet = false;
  var adminIds = 0;
  var adminHierarchyId;
  @override
  void initState() {
    super.initState();
    adminHierarchyId = context.read<AppStateProvider>().user!.adminHierarchyId!;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BuildingProvider>(builder: (context, provider, child) {
      return AppBaseScreen(
          appBar: AppBar(
            title: const Text('Household'),
            centerTitle: true,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          controller: houseNumber,
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            label: const Text('House Number'),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 15),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor)),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          searchHouseNumber(houseNumber.text);
                        })
                  ],
                ),
                const SizedBox(
                  height: 100,
                ),
                AppVisibility(
                  visible: register,
                  child: AppCard(
                    child: AppForm(
                      formKey: formkey,
                      controls: [
                        const AppInputText(
                            fieldName: 'houseNumber', label: 'House Number'),
                        const AppInputHidden(
                          fieldName: 'status',
                          value: 'IN_USE',
                        ),
                        const AppInputHidden(
                            fieldName: 'active', value: 'true'),
                        AppFetcher(
                            api:
                                '/admin-hierarchies/children/$adminHierarchyId',
                            builder: (items, isloaidng) => AppInputDropDown(
                                onChange: (adminId) => setState(() {
                                      showStreet = true;
                                      adminIds = adminId;
                                    }),
                                items: items,
                                name: 'parentAdminId',
                                label: 'Sheia')),
                        AppVisibility(
                          visible: showStreet,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: AppFetcher(
                                api: '/admin-hierarchies/children/$adminIds',
                                builder: (items, isloaidng) => AppInputDropDown(
                                    items: items,
                                    name: 'adminHierarchyId',
                                    label: 'Street')),
                          ),
                        ),
                        const AppInputText(
                            fieldName: 'location', label: 'Location'),
                        AppFetcher(
                            api: '/solid-waste-building-categories',
                            builder: (items, isloaidng) => AppInputDropDown(
                                items: items,
                                name: 'buildingCategoryId',
                                label: 'Building Category')),
                        AppButton(
                            onPress: () {
                              if (formkey.currentState!.saveAndValidate()) {
                                _onPressed();
                              }
                            },
                            label: 'Register Building')
                      ],
                    ),
                  ),
                ),
                AppVisibility(
                    visible: view,
                    child: AppCard(
                      elevation: 3,
                        child: AppContainer(
                          height: MediaQuery.of(context).size.height / 2,
                          child: AppTable(
                              data: provider.buildings
                                  .map((e) => e.toJson())
                                  .toList(),
                              columns: [
                            AppTableColumn(header: 'House Number', value: 'houseNumber'),
                            AppTableColumn(header: 'Location', value: 'location'),
                            AppTableColumn(header: 'Status', value: 'status')
                          ]),
                        )))
              ],
            ),
          ));
    });
  }
}
