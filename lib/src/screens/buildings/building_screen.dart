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
import 'package:zanmutm_pos_client/src/widgets/app_detail_card.dart';
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
  Building? _building;
  searchHouseNumber(houseNumber) {
    Future.delayed(Duration.zero, () => _loadHouseNumber(houseNumber));
  }

  var buildingIds;
  _loadHouseNumber(String houseNumber) async {
    Building? building =
        (await getIt<BuildingsService>().gethousenumber(houseNumber));
    debugPrint(buildingIds.toString());
    if (building == null) {
      setState(() {
        register = true;
        view = false;
        _building = building;
      });
    } else {
      setState(() {
        register = false;
        view = true;
        _building = building;
      });
    }
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

  void _onPressed() {
    var payload = formkey.currentState?.value;
    BuildingsService().registerHouse(payload);
    setState(() {
      register = false;
      _household = true;
      Navigator.pop(context);
    });
  }

  void onPressed() {
    var payload = householdformkey.currentState?.value;
    BuildingsService().registerHousehold(payload);
    setState(() {
      register = false;
      _household = true;
      Navigator.pop(context);
    });
  }

  final _formKey = GlobalKey<FormBuilderState>();
  final formkey = GlobalKey<FormBuilderState>();
  final householdformkey = GlobalKey<FormBuilderState>();
  final TextEditingController houseNumber = TextEditingController();
  bool register = false;
  bool view = false;
  bool showStreet = false;
  bool _household = false;
  bool showindividual = false;
  bool showcompany = false;
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
                  height: 16,
                ),
                //register
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
                //house hold reg
                AppVisibility(
                  visible: _household,
                  child: AppCard(
                      child: AppForm(
                    formKey: householdformkey,
                    controls: [
                      AppInputDropDown(
                        items: _categoryList,
                        name: 'category',
                        label: 'Category',
                        onChange: (value) {
                          if (value == 1) {
                            setState(() {
                              showindividual = true;
                              showcompany = false;
                              all = true;
                            });
                          } else if (value == 2) {
                            setState(() {
                              showcompany = true;
                              showindividual = false;
                              all = true;
                            });
                          }
                        },
                      ),
                      AppVisibility(
                          visible: showcompany,
                          child: const AppInputText(
                              fieldName: 'tin', label: 'TIN')),
                      AppVisibility(
                          visible: showcompany,
                          child: const AppInputText(
                              fieldName: 'companyName', label: 'Company Name')),
                      AppVisibility(
                          visible: showindividual,
                          child: const AppInputText(
                              fieldName: 'nin', label: 'NIN')),
                      AppVisibility(
                        visible: showindividual,
                        child: const AppInputText(
                            fieldName: 'firstName', label: 'First Name'),
                      ),
                      AppVisibility(
                        visible: showindividual,
                        child: const AppInputText(
                            fieldName: 'middleName', label: 'Middle Name'),
                      ),
                      AppVisibility(
                        visible: showindividual,
                        child: const AppInputText(
                            fieldName: 'lastName', label: 'Last Name'),
                      ),
                      AppVisibility(
                        visible: showindividual,
                        child: AppInputDropDown(
                            items: _genderList,
                            name: 'gender',
                            label: 'Gender'),
                      ),
                      AppVisibility(
                          visible: showindividual,
                          child: const AppInputText(
                              fieldName: 'mobileNumber',
                              label: 'Phone Number')),
                      AppVisibility(
                          visible: all,
                          child: const AppInputText(
                              fieldName: 'email', label: 'Email')),
                      AppVisibility(
                        visible: all,
                        child: const AppInputText(
                            fieldName: 'address', label: 'Address'),
                      ),
                      const AppInputHidden(
                        fieldName: 'active',
                        value: 'true',
                      ),
                      AppVisibility(
                        visible: all,
                        child: AppFetcher(
                            api:
                                '/admin-hierarchies/children/$adminHierarchyId',
                            builder: (items, isloaidng) => AppInputDropDown(
                                items: items,
                                name: 'adminHierarchyId',
                                label: 'Sheia')),
                      ),
                      AppVisibility(
                        visible: all,
                        child: AppFetcher(
                            api: '/tax-payer-statuses',
                            builder: (items, isloaidng) => AppInputDropDown(
                                items: items,
                                displayValue: 'description',
                                name: 'status',
                                label: 'Taxpayer Status')),
                      ),
                      AppVisibility(
                        visible: all,
                        child: AppFetcher(
                            api: '/solid-waste-payment-modes',
                            builder: (items, isloaidng) => AppInputDropDown(
                                items: items,
                                name: 'paymentModeId',
                                label: 'Payment Mode')),
                      ),
                      AppVisibility(
                        visible: all,
                        child: AppInputDropDown(
                            items: _frequencyList,
                            name: 'paymentFrequencey',
                            label: 'Payment Frequencey'),
                      ),
                      AppInputHidden(
                        fieldName: 'houseNumber',
                        value: houseNumber.text.toString(),
                      ),
                      AppVisibility(
                        visible: all,
                        child: const AppInputText(
                            fieldName: 'location', label: 'Location'),
                      ),
                      AppVisibility(
                        visible: all,
                        child: AppFetcher(
                            api: '/solid-waste-building-categories',
                            builder: (items, isloaidng) => AppInputDropDown(
                                items: items,
                                name: 'buildingCategoryId',
                                label: 'Building Category')),
                      ),
                      AppButton(
                          onPress: () {
                            if (householdformkey.currentState!
                                .saveAndValidate()) {
                              onPressed();
                            }
                          },
                          label: 'Register Household Details')
                    ],
                  )),
                ),
                //diplay
                AppVisibility(
                    visible: view,
                    child: AppContainer(
                      height: MediaQuery.of(context).size.height / 2,
                      child: AppDetailCard(
                        columns: [
                          AppDetailColumn(
                              header: 'Building Number',
                              value: _building?.houseNumber),
                          AppDetailColumn(
                              header: 'Building Location',
                              value: _building?.location),
                          AppDetailColumn(
                              header: 'Building Status',
                              value: _building?.status),
                        ],
                        data: {},
                        title: "House Hold",
                        actionBuilder: (row) => Row(
                          children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    _household = true;
                                    view = false;
                                  });
                                },
                                icon: Icon(Icons.add_home_sharp))
                          ],
                        ),
                      ),
                    ))
              ],
            ),
          ));
    });
  }
}
