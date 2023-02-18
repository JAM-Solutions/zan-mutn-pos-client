import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/building_provider.dart';
import 'package:zanmutm_pos_client/src/routes/app_routes.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_card.dart';
import 'package:zanmutm_pos_client/src/widgets/app_container.dart';
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';
import 'package:zanmutm_pos_client/src/widgets/app_fetcher.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_icon_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_dropdown.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_visibility.dart';

class BuildingsScreen extends StatefulWidget {
  const BuildingsScreen({super.key});

  @override
  State<BuildingsScreen> createState() => _BuildingsScreenState();
}

class _BuildingsScreenState extends State<BuildingsScreen> {
  Building? _building;

  searchHouseNumber(String houseNumber) async {
    _building =
        await context.read<BuildingProvider>().fetchbuildings(houseNumber);
  }

  final List<Map<String, dynamic>> _genderList = [
    {'id': 1, 'name': 'Male'},
    {'id': 2, 'name': 'Female'}
  ];
  final List<Map<String, dynamic>> _frequencyList = [
    {'id': 1, 'name': 'WEEKLY'},
    {'id': 2, 'name': 'MONTHLY'},
    {'id': 3, 'name': 'QUATERLY'},
    {'id': 4, 'name': 'SEMI_ANNUALY'},
    {'id': 5, 'name': 'ANNUALY'}
  ];
  final List<Map<String, dynamic>> _categoryList = [
    {'id': 1, 'name': 'INDIVIDUAL'},
    {'id': 2, 'name': 'COMPANY'}
  ];
  final List<Map<String, dynamic>> frequency = [
    {'id': 1, 'name': 'WEEKLY'},
    {'id': 2, 'name': 'MONTHLY'}
  ];

  void _onPressed() async {
    var payload = formkey.currentState?.value;
    var houseNumber = formkey.currentState?.value['houseNumber'];
    await context.read<BuildingProvider>().registerHouse(payload, houseNumber);
  }

  final _formKey = GlobalKey<FormBuilderState>();
  final formkey = GlobalKey<FormBuilderState>();
  final householdformkey = GlobalKey<FormBuilderState>();
  final TextEditingController houseNumber = TextEditingController();
  bool showStreet = false;
  bool all = false;
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
      Building? building = provider.building;
      return MessageListener<BuildingProvider>(
        child: AppBaseScreen(
            isLoading: provider.fyIsLoading,
            appBar: AppBar(
              title: const Text('Building'),
              centerTitle: true,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: houseNumber,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              label: const Text('Building Number'),
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
                    height: 16,
                  ),
                  //register
                  AppVisibility(
                    visible: provider.register,
                    child: AppCard(
                      child: AppForm(
                        formKey: formkey,
                        controls: [
                          const AppInputHidden(
                            fieldName: 'status',
                            value: 'IN_USE',
                          ),
                          const AppInputHidden(
                              fieldName: 'active', value: 'true'),
                          const AppInputText(
                              fieldName: 'houseNumber', label: 'House Number'),
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
                              padding: const EdgeInsets.only(bottom: 0),
                              child: AppFetcher(
                                  api: '/admin-hierarchies/children/$adminIds',
                                  builder: (items, isloaidng) =>
                                      AppInputDropDown(
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
                  //diplay
                  AppVisibility(
                      visible: provider.view,
                      child: AppContainer(
                        height: MediaQuery.of(context).size.height / 2,
                        child: AppDetailCard(
                          columns: [
                            AppDetailColumn(
                                header: 'Building Number',
                                value: building?.houseNumber),
                            AppDetailColumn(
                                header: 'adminHierarchyName',
                                value: building?.adminHierarchyName),
                            AppDetailColumn(
                                header: 'Building Location',
                                value: building?.location),
                            AppDetailColumn(
                                header: 'Building Category',
                                value: building?.buildingCategoryName),
                            AppDetailColumn(
                                header: 'Building Status',
                                value: building?.status),
                          ],
                          data: {},
                          title: "Building Details",
                          actionBuilder: (row) => Row(
                            children: [
                              AppIconButton(
                                  onPressed: () => context.push(
                                      AppRoute.addHouseHold,
                                      extra: building!),
                                  icon: Icons.add_home_sharp),
                              const Spacer(),
                              AppIconButton(
                                  onPressed: () => context.push(
                                      AppRoute.viewHouseHold,
                                      extra: building!),
                                  icon: Icons.view_list),
                            ],
                          ),
                        ),
                      ))
                ],
              ),
            )),
      );
    });
  }
}
