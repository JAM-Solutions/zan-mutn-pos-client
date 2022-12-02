import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_snackbar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginForm = GlobalKey<FormBuilderState>();
  late Function _onError;
  bool _isLoading = false;


  @override
  void initState() {
    _onError = appError(context);
  }

  void _onSubmit() {
    _loginForm.currentState!.saveAndValidate();
     debugPrint(_loginForm.currentState?.value.toString());
     _onError("Some errors");
  }

  @override
  Widget build(BuildContext context) {
    return AppScreen(
      child: AppForm(
        formKey: _loginForm,
       controls: [
         AppInputText(fieldName: 'email', label: 'Email',validators: [
           FormBuilderValidators.required(errorText: "Email is required")
         ],),
         AppInputText(
           fieldName: 'password',
           label: 'Password',
           obscureText: true,
           validators: [
             FormBuilderValidators.required(errorText: "Password is required")
           ],),

          AppButton(onPress: _onSubmit, label: 'Login'),
       ],
        ),
    );
  }
}
