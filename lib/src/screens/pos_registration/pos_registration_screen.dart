import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/pos_registration.dart';
import 'package:zanmutm_pos_client/src/providers/pos_registration_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

class PosRegistrationScreen extends StatefulWidget {
  const PosRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<PosRegistrationScreen> createState() => _PosRegistrationScreenState();
}

class _PosRegistrationScreenState extends State<PosRegistrationScreen> {
  final _regForm = GlobalKey<FormBuilderState>();

  fetchRegistration(BuildContext context) async {
    if (_regForm.currentState?.saveAndValidate() != true) return;
    PosRegistration? reg = await context
        .read<PosRegistrationProvider>()
        .fetchRegistration(_regForm.currentState?.value['imei']);
    if (reg == null) return;
    if (!mounted) return;
    bool? isConfirmed = await AppMessages.appConfirm(
        context,
        'Confirm Registration',
        'Confirm Register this pos with imei ${reg.imei}');
    if (isConfirmed != true || !mounted) return;
    await context
        .read<PosRegistrationProvider>().register(reg);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Consumer<PosRegistrationProvider>(
        builder: (context, provider, child) {
          return MessageListener<PosRegistrationProvider>(
            child: AppBaseScreen(
              isLoading: provider.isLoading,
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("POS REGISTRATION"),
                      const SizedBox(
                        height: 24,
                      ),
                      AppForm(
                        formKey: _regForm,
                        controls: [
                          AppInputText(
                            fieldName: 'imei',
                            label: 'Enter this POS IMEI',
                            validators: [
                              FormBuilderValidators.required(
                                  errorText: 'IMEI is required')
                            ],
                          ),
                          AppButton(onPress: () => fetchRegistration(context),
                              label: 'Register')
                        ],
                      ),
                    ],
                  )),
            ),
          );
        },
      ),
    );
  }
}
