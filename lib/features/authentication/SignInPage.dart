import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/network/back-end/dto/authentication/UserSignInDTO.dart';
import 'package:streamrank/core/utils/Config.dart';

class SignInPage extends StatelessWidget {
  final AuthApiService authApiService = AuthApiService();
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;
      try {
        final signInDTO = UserSignInDTO.fromFormData(formData!);
        final response = await authApiService.signIn(signInDTO);

        if (response["status"] == "success")
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign-in successful!')),
          );
        else
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign-in failed!')),
          );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('internal server error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields correctly.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'usernameOrEmail',
                decoration: InputDecoration(labelText: 'Username or Email'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                ]),
              ),
              SizedBox(height: 16),
              FormBuilderTextField(
                name: 'password',
                obscureText: true,
                decoration: InputDecoration(labelText: 'Password'),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.minLength(6),
                ]),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _submitForm(context),
                child: Text('Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
