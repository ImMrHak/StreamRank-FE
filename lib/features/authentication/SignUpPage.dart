import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';
import 'package:streamrank/core/network/back-end/AuthApiService.dart';
import 'package:streamrank/core/network/back-end/dto/authentication/UserSignUpDTO.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final GlobalKey<FormBuilderState> _formKey = GlobalKey<FormBuilderState>();
  final AuthApiService authApiService = AuthApiService();
  bool _isPasswordVisible = false; // Toggle for Password Visibility
  bool _isConfirmPasswordVisible = false; // Toggle for Confirm Password Visibility

  void _submitForm(BuildContext context) async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState?.value;

      if (formData!['password'] != formData['confirmPassword']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match!')),
        );
        return;
      }

      try {
        final signUpDTO = UserSignUpDTO.fromFormData(formData);
        final response = await authApiService.signUp(signUpDTO);

        if (response["status"] == "success") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-up successful!')),
          );
          Navigator.pop(context); // Return to the previous screen
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign-up failed!')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Internal Server Error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields correctly')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Adjust layout when keyboard is shown
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: FormBuilder(
              key: _formKey,
              child: Center(
                child: Card(
                  elevation: 8,
                  child: Container(
                    padding: const EdgeInsets.all(32.0),
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FlutterLogo(size: 100),
                          _gap(),
                          Text(
                            "Create Account",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Fill in the details below to create a new account.",
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          _gap(),

                          // First Name
                          FormBuilderTextField(
                            name: 'firstName',
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              hintText: 'Enter your first name',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                          _gap(),

                          // Last Name
                          FormBuilderTextField(
                            name: 'lastName',
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              hintText: 'Enter your last name',
                              prefixIcon: Icon(Icons.person_outline),
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                          _gap(),

                          // Email
                          FormBuilderTextField(
                            name: 'email',
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'Enter your email address',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.email(),
                            ]),
                          ),
                          _gap(),

                          // Username
                          FormBuilderTextField(
                            name: 'userName',
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              hintText: 'Choose a username',
                              prefixIcon: Icon(Icons.account_circle),
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                          _gap(),

                          // Password
                          FormBuilderTextField(
                            name: 'password',
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: 'Create a password',
                              prefixIcon: const Icon(Icons.lock),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(8),
                              FormBuilderValidators.maxLength(20),
                            ]),
                          ),
                          _gap(),

                          // Confirm Password
                          FormBuilderTextField(
                            name: 'confirmPassword',
                            obscureText: !_isConfirmPasswordVisible,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              hintText: 'Re-enter your password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                    _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                              ),
                            ),
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(),
                              FormBuilderValidators.minLength(8),
                              FormBuilderValidators.maxLength(20),
                            ]),
                          ),
                          _gap(),

                          // Date of Birth
                          FormBuilderDateTimePicker(
                            name: 'dateOfBirth',
                            inputType: InputType.date,
                            format: DateFormat('yyyy-MM-dd'),
                            decoration: const InputDecoration(
                              labelText: 'Date of Birth',
                              hintText: 'Select your date of birth',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            validator: FormBuilderValidators.required(),
                          ),
                          _gap(),

                          // Sign Up Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                              onPressed: () => _submitForm(context),
                              child: const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Back to Sign In
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Already have an account? Sign In'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _gap() => const SizedBox(height: 16);
}
