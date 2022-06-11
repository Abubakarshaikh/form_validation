import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FormValidationPage(),
    );
  }
}

class FormValidationPage extends StatefulWidget {
  const FormValidationPage({Key? key}) : super(key: key);

  @override
  State<FormValidationPage> createState() => _FormValidationPageState();
}

class _FormValidationPageState extends State<FormValidationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        TextFormField(
          onChanged: (value) {
            changedEmail(value);
          },
          decoration: InputDecoration(
            hintText: 'email',
            helperText: 'A complete, valid email e.g. joe@gmail.com',
            errorText: invalidEmail
                ? 'Please ensure the email entered is valid'
                : null,
          ),
        ),
        TextFormField(
          onChanged: (value) {
            changedPassword(value);
          },
          decoration: InputDecoration(
            hintText: 'password',
            helperText:
                '''Password should be at least 8 characters with at least one letter and number''',
            errorText: invalidPassword
                ? '''Password must be at least 8 characters and contain at least one letter and number'''
                : null,
          ),
        ),
      ],
    ));
  }

  bool invalidEmail = false;

  bool invalidPassword = false;

  void emailUnfocused() {}
  void passwordUnfocused() {}

  void changedEmail([String value = '']) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
    );
    emailRegex.hasMatch(value) ? invalidEmail = false : invalidEmail = true;
  }

  void changedPassword([String value = '']) {
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    passwordRegex.hasMatch(value)
        ? invalidPassword = false
        : invalidPassword = true;
  }
}

enum PasswordValidationError { invalid }

class Password extends FormzInput<String, PasswordValidationError> {
  Password.pure([String value = '']) : super.pure(value);
  Password.dirty([String value = '']) : super.dirty(value);

  static final _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  PasswordValidationError? validator(String? value) {
    return _passwordRegex.hasMatch(value ?? '')
        ? null
        : PasswordValidationError.invalid;
  }
}

class FormValidationController {
  final ValueNotifier<Password> password =
      ValueNotifier<Password>(Password.pure());

  final ValueNotifier<FormzStatus> status =
      ValueNotifier<FormzStatus>(FormzStatus.pure);

  void passwordUnfocused() {
    final dirtyPassword = Password.dirty(password.value.value);
    password.value = dirtyPassword;
    status.value = Formz.validate([dirtyPassword, email.value]);
  }

  void changedPassword(String value) {
    final changedPassword = Password.dirty(value);
    password.value = changedPassword.valid ? changedPassword : Password.pure();
    status.value = Formz.validate([changedPassword, password.value]);
  }
}
