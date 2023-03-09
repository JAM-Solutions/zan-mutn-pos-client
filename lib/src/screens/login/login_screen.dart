import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/listeners/message_listener.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/providers/login_provider.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginForm = GlobalKey<FormBuilderState>();

  @override
  void initState() {
    super.initState();
  }

  void _onSubmit() async {
    if (_loginForm.currentState!.saveAndValidate()) {
      Map<String, dynamic> payload = _loginForm.currentState!.value;
      User? loggedIn = await context.read<LoginProvider>().login(payload);
      if (loggedIn != null && mounted) {
        context.read<AppStateProvider>().setAuthenticated(loggedIn);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double logoSize = MediaQuery.of(context).size.width / 2.5;
    return Consumer<LoginProvider>(
      builder: (context, loginProvider, child) {
        return MessageListener<LoginProvider>(
          child: loginProvider.numberLogs == 3
              ? AppBaseScreen(
                  child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_rounded,
                        size: 48,
                      ),
                      const Text(
                        'You have reached 3 Trials, Another failed trial will deactivate the account',
                        textAlign: TextAlign.center,
                      ),
                      AppButton(
                        onPress: () {
                          loginProvider.addLogs();
                        },
                        label: 'Continue',
                      )
                    ],
                  ),
                ))
              : AppBaseScreen(
                  isLoading: loginProvider.isLoading,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 16, right: 16, top: 10, bottom: 16),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                  width: logoSize,
                                  height: logoSize,
                                  image: const AssetImage(
                                      'assets/images/logo.jpeg')),
                              const Text(
                                'ZAN-MUTM-POS',
                                style: TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(context
                                      .read<AppStateProvider>()
                                      .currentVersion ??
                                  ''),
                              const SizedBox(
                                height: 2,
                              ),
                              AppForm(
                                formKey: _loginForm,
                                controls: [
                                  const AppInputHidden(
                                    fieldName: 'grant_type',
                                    value: 'password',
                                  ),
                                  AppInputText(
                                    fieldName: 'username',
                                    label: 'Email',
                                    validators: [
                                      FormBuilderValidators.required(
                                          errorText: "Email is required")
                                    ],
                                  ),
                                  AppInputText(
                                    fieldName: 'password',
                                    label: 'Password',
                                    obscureText: !loginProvider.showPassword,
                                    suffixIcon: IconButton(
                                      onPressed: () =>
                                          loginProvider.showPassword =
                                              !loginProvider.showPassword,
                                      icon: Icon(loginProvider.showPassword
                                          ? Icons.remove_red_eye_sharp
                                          : Icons.remove_red_eye_outlined),
                                    ),
                                    validators: [
                                      FormBuilderValidators.required(
                                          errorText: "Password is required")
                                    ],
                                  ),
                                  AppButton(onPress: _onSubmit, label: 'Login'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
