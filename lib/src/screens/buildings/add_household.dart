import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:zanmutm_pos_client/src/models/building.dart';
import 'package:zanmutm_pos_client/src/services/buildings_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_card.dart';
import 'package:zanmutm_pos_client/src/widgets/app_fetcher.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_dropdown.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_visibility.dart';

class AddHouseHoldScreen extends StatefulWidget {
  final Building building;

  const AddHouseHoldScreen({Key? key, required this.building})
      : super(key: key);

  @override
  State<AddHouseHoldScreen> createState() => _AddHouseHoldScreenState();
}

class _AddHouseHoldScreenState extends State<AddHouseHoldScreen> {
  void _onPressed() {
    var payload = formkey.currentState?.value;
    BuildingsService().registerHouse(payload);
    setState(() {
      register = false;
      _household = true;
      Navigator.pop(context);
    });
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
  Widget build(BuildContext context) {
    return AppBaseScreen(
        appBar: AppBar(
          title: Text('Add Household'),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('House Number: ${widget.building.houseNumber}'),
              Text('Location: ${widget.building.location}'),
              SizedBox(
                height: 16,
              ),
              AppCard(
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
                      child:
                          const AppInputText(fieldName: 'tin', label: 'TIN')),
                  AppVisibility(
                      visible: showcompany,
                      child: const AppInputText(
                          fieldName: 'companyName', label: 'Company Name')),
                  AppVisibility(
                      visible: showindividual,
                      child:
                          const AppInputText(fieldName: 'nin', label: 'NIN')),
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
                        items: _genderList, name: 'gender', label: 'Gender'),
                  ),
                  AppVisibility(
                      visible: showindividual,
                      child: const AppInputText(
                          fieldName: 'mobileNumber', label: 'Phone Number')),
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
                        api: '/admin-hierarchies/children/$adminHierarchyId',
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
                    value: widget.building.houseNumber,
                  ),
                  AppInputHidden(
                      fieldName: 'location', value: widget.building.location),
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
                        if (householdformkey.currentState!.saveAndValidate()) {
                          onPressed();
                        }
                      },
                      label: 'Register Household Details')
                ],
              ))
            ],
          ),
        ));
  }
}
