import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:provider/provider.dart';
import 'package:zanmutm_pos_client/src/models/user.dart';
import 'package:zanmutm_pos_client/src/providers/app_state_provider.dart';
import 'package:zanmutm_pos_client/src/services/auth_service.dart';
import 'package:zanmutm_pos_client/src/widgets/app_button.dart';
import 'package:zanmutm_pos_client/src/widgets/app_form.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_hidden.dart';
import 'package:zanmutm_pos_client/src/widgets/app_input_text.dart';
import 'package:zanmutm_pos_client/src/widgets/app_base_screen.dart';
import 'package:zanmutm_pos_client/src/widgets/app_messages.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginForm = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  bool _showPassword = false;
  late AppStateProvider _authProvider;

  @override
  void initState() {
    _authProvider =  Provider.of<AppStateProvider>(context, listen: false);
    super.initState();
  }

  void _onSubmit() async {
    if(_loginForm.currentState!.saveAndValidate()) {
      setState(() =>_isLoading = true);
      Map<String, dynamic> payload = _loginForm.currentState!.value;
      try {
         User user = await authService.login(payload);
         _authProvider.setAuthenticated(user);
         setState(() => _isLoading = false);
      } catch(e) {
        setState(() => _isLoading = false);
        debugPrint(e.toString());
        AppMessages.showError(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double logoSize = MediaQuery.of(context).size.width / 2.5;
    return AppBaseScreen(
      isLoading: _isLoading,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                    width: logoSize,
                    height: logoSize,
                    image: const AssetImage('assets/images/logo.jpeg')),
               const SizedBox(height: 2,),
                const Text('ZAN-MUTM-POS', style: TextStyle(color: Colors.blueGrey, fontSize: 18, fontWeight: FontWeight.bold),),
                Text(dotenv.env['AP_BUILD_MODE'] ?? 'No'),
                const SizedBox(height: 2,),
                AppForm(
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
                     obscureText: !_showPassword,
                     suffixIcon: IconButton(
                       onPressed: () {
                         setState(() => _showPassword = !_showPassword);
                       },
                       icon: Icon(_showPassword
                           ? Icons.remove_red_eye_sharp
                           : Icons.remove_red_eye_outlined),
                     ),
                     validators: [
                       FormBuilderValidators.required(
                           errorText: "Password is required")
                     ],),
                    AppButton(onPress: _onSubmit, label: 'Login'),
                 ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
