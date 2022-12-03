import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/providers/auth_provider.dart';
import 'package:zanmutm_pos_client/src/screens/login/login_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_fetcher.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_dropdown.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
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
  late AuthProvider _authProvider;

  @override
  void initState() {
    _onError = appError(context, autoClose: true);
    _authProvider =  Provider.of<AuthProvider>(context, listen: false);
    super.initState();
  }

  void _onSubmit() async {
    if(_loginForm.currentState!.saveAndValidate()) {
      setState(() {
        _isLoading = true;
      });
      Map<String, dynamic> payload = _loginForm.currentState!.value;
      debugPrint(payload.toString());
      try {
         var resp = await login(payload);
         _authProvider.userAuthorized(resp.data);
         setState(() {
           _isLoading = false;
         });
      }catch(e) {
        debugPrint(e.toString());
        _onError(e.toString());
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBaseScreen(
      isLoading: _isLoading,
      child: Center(
        child: AppForm(
          formKey: _loginForm,
         controls: [
           const AppInputHidden(
             fieldName: 'grant_type',
             value: 'password',),
           AppInputText(
             fieldName: 'username',
             label: 'Email',
             validators: [
             FormBuilderValidators.required(
                 errorText: "Email is required")
           ],),
           AppInputText(
             fieldName: 'password',
             label: 'Password',
             obscureText: true,
             validators: [
               FormBuilderValidators.required(
                   errorText: "Password is required")
             ],),
            AppButton(onPress: _onSubmit, label: 'Login'),
         ],
          ),
      ),
    );
  }
}
