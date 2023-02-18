import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/building_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_card.dart';
import 'package:zanmutm_pos_client/src/widgets/app_fetcher.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_dropdown.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';

class AddHouseHoldScreen extends StatefulWidget {
  final Building building;

  const AddHouseHoldScreen({Key? key, required this.building})
      : super(key: key);

  @override
  State<AddHouseHoldScreen> createState() => _AddHouseHoldScreenState();
}

class _AddHouseHoldScreenState extends State<AddHouseHoldScreen> {
  final List<Map<String, dynamic>> _genderList = [
    {'id': 1, 'name': 'Male'},
    {'id': 2, 'name': 'Female'}
  ];
  final List<Map<String, dynamic>> _frequencyList = [
    {'id': 'WEEKLY', 'name': 'WEEKLY'},
    {'id': 'MONTHLY', 'name': 'MONTHLY'},
  ];
  final List<Map<String, dynamic>> _categoryList = [
    {'id': 'INDIVIDUAL', 'name': 'INDIVIDUAL'},
    {'id': 'COMPANY', 'name': 'COMPANY'}
  ];
  void onPressed() async {
    var payload = householdformkey.currentState?.value;
    await context.read<BuildingProvider>().registerHousehold(payload);
    Navigator.pop(context);
  }

  final _formKey = GlobalKey<FormBuilderState>();
  final formkey = GlobalKey<FormBuilderState>();
  final householdformkey = GlobalKey<FormBuilderState>();
  bool showindividual = false;
  bool showcompany = false;
  bool all = false;
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
              title: const Text('Add Household'),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('House Number: ${widget.building.houseNumber}'),
                  Text('Location: ${widget.building.location}'),
                  Text(
                      'adminHierarchyName: ${widget.building.adminHierarchyName}'),
                  const SizedBox(
                    height: 16,
                  ),
                  AppCard(
                      child: AppForm(
                    formKey: householdformkey,
                    controls: [
                      AppInputDropDown<String>(
                        items: _categoryList,
                        name: 'category',
                        label: 'Category',
                        onChange: (value) {
                          if (value == 'INDIVIDUAL') {
                            setState(() {
                              showindividual = true;
                              showcompany = false;
                              all = true;
                            });
                          } else if (value == 'COMPANY') {
                            setState(() {
                              showcompany = true;
                              showindividual = false;
                              all = true;
                            });
                          }
                        },
                      ),
                      if (showcompany)
                        AppInputText(
                          fieldName: 'tin',
                          label: 'TIN',
                          validators: [
                            FormBuilderValidators.required(
                                errorText: "Tin is required")
                          ],
                        ),
                      if (showcompany)
                        AppInputText(
                            fieldName: 'companyName',
                            label: 'Company Name',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "Company Name is required")
                            ]),
                      if (showindividual)
                        AppInputText(
                            fieldName: 'nin',
                            label: 'NIN',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "NIN is required")
                            ]),
                      if (showindividual)
                        AppInputText(
                            fieldName: 'firstName',
                            label: 'First Name',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "First Name is required")
                            ]),
                      if (showindividual)
                        AppInputText(
                            fieldName: 'middleName',
                            label: 'Middle Name',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "Middle Name is required")
                            ]),
                      if (showindividual)
                        AppInputText(
                            fieldName: 'lastName',
                            label: 'Last Name',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "Last Name is required")
                            ]),
                      if (showindividual)
                        AppInputDropDown(
                            items: _genderList,
                            name: 'gender',
                            label: 'Gender',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "Gender is required")
                            ]),
                      if (showindividual)
                        AppInputText(
                            fieldName: 'mobileNumber',
                            label: 'Phone Number',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "Phone Number is required")
                            ]),
                      if (all)
                        AppInputText(
                            fieldName: 'email',
                            label: 'Email',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "Email is required")
                            ]),
                      if (all)
                        AppInputText(
                            fieldName: 'address',
                            label: 'Address',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "Address is required")
                            ]),
                      const AppInputHidden(
                        fieldName: 'active',
                        value: 'true',
                      ),
                      if (all)
                        AppFetcher(
                            api:
                                '/admin-hierarchies/children/$adminHierarchyId',
                            builder: (items, isloaidng) => AppInputDropDown(
                                    items: items,
                                    name: 'adminHierarchyId',
                                    label: 'Sheia',
                                    validators: [
                                      FormBuilderValidators.required(
                                          errorText: "Sheia is required")
                                    ])),
                      if (all)
                        AppFetcher(
                            api: '/tax-payer-statuses',
                            builder: (items, isloaidng) => AppInputDropDown(
                                    items: items,
                                    displayValue: 'description',
                                    name: 'status',
                                    label: 'Taxpayer Status',
                                    validators: [
                                      FormBuilderValidators.required(
                                          errorText:
                                              "Taxpayer Status is required")
                                    ])),
                      if (all)
                        AppFetcher(
                            api: '/solid-waste-payment-modes',
                            builder: (items, isloaidng) => AppInputDropDown(
                                    items: items,
                                    name: 'paymentModeId',
                                    label: 'Payment Mode',
                                    validators: [
                                      FormBuilderValidators.required(
                                          errorText: "Payment Mode is required")
                                    ])),
                      if (all)
                        AppInputDropDown<String>(
                            items: _frequencyList,
                            name: 'paymentFrequency',
                            label: 'Payment Frequencey',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: "Payment Frequency is required")
                            ]),
                      AppInputHidden(
                        fieldName: 'buildingHouseNumber',
                        value: widget.building.houseNumber,
                      ),
                      AppInputHidden(
                        fieldName: 'buildingId',
                        value: widget.building.id,
                      ),
                      AppInputHidden(
                          fieldName: 'location',
                          value: widget.building.location),
                      if (all)
                        AppFetcher(
                            api: '/solid-waste-building-categories',
                            builder: (items, isloaidng) => AppInputDropDown(
                                    items: items,
                                    name: 'buildingCategoryId',
                                    label: 'Building Category',
                                    validators: [
                                      FormBuilderValidators.required(
                                          errorText:
                                              "Building Category is required")
                                    ])),
                      AppButton(
                          onPress: () {
                            if (householdformkey.currentState!
                                .saveAndValidate()) {
                              onPressed();
                            }
                          },
                          label: 'Register Household Details')
                    ],
                  ))
                ],
              ),
            )),
      );
    });
  }
}
