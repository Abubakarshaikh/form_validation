import 'package:flutter/material.dart';
import 'package:formz/formz.dart';

void main() => runApp(const App());

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
  FormValidationPageState createState() => FormValidationPageState();
}

class FormValidationPageState extends State<FormValidationPage> {
  final FormValidationController _controller =
      FormValidationController.instance;
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(() {
      if (!_emailFocusNode.hasFocus) {
        _controller.emailUnfocused();
        FocusScope.of(context).requestFocus(_passwordFocusNode);
      }
    });

    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        _controller.passwordUnfocused();
      }
    });
  }

  @override
  void dispose() {
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Form Validation')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            EmailInput(focusNode: _emailFocusNode),
            PasswordInput(focusNode: _passwordFocusNode),
            SubmitButton(),
          ],
        ),
      ),
    );
  }
}

class EmailInput extends StatelessWidget {
  EmailInput({Key? key, required this.focusNode}) : super(key: key);

  final FocusNode focusNode;
  final FormValidationController _controller =
      FormValidationController.instance;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Email>(
      valueListenable: _controller.email,
      builder: (context, state, widget) {
        return TextFormField(
          initialValue: state.value,
          focusNode: focusNode,
          decoration: InputDecoration(
            icon: const Icon(Icons.email),
            labelText: 'Email',
            helperText: 'A complete, valid email e.g. joe@gmail.com',
            errorText: state.invalid
                ? 'Please ensure the email entered is valid'
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            _controller.emailChanged(value);
          },
          textInputAction: TextInputAction.next,
        );
      },
    );
  }
}

class PasswordInput extends StatelessWidget {
  PasswordInput({Key? key, required this.focusNode}) : super(key: key);

  final FocusNode focusNode;
  final FormValidationController _controller =
      FormValidationController.instance;
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Password>(
      valueListenable: _controller.password,
      builder: (context, state, _) {
        return TextFormField(
          initialValue: state.value,
          focusNode: focusNode,
          decoration: InputDecoration(
            icon: const Icon(Icons.lock),
            helperText:
                '''Password should be at least 8 characters with at least one letter and number''',
            helperMaxLines: 2,
            labelText: 'Password',
            errorMaxLines: 2,
            errorText: state.invalid
                ? '''Password must be at least 8 characters and contain at least one letter and number'''
                : null,
          ),
          obscureText: true,
          onChanged: (value) {
            _controller.passwordChanged(value);
          },
          textInputAction: TextInputAction.done,
        );
      },
    );
  }
}

class SubmitButton extends StatelessWidget {
  final FormValidationController _controller =
      FormValidationController.instance;

  SubmitButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<FormzStatus>(
      valueListenable: _controller.status,
      builder: (context, state, widget) {
        return ElevatedButton(
          onPressed:
              state.isValidated ? () => _controller.formSubmitted() : null,
          child: const Text('Submit'),
        );
      },
    );
  }
}

enum EmailValidationError { invalid }

enum PasswordValidationError { invalid }

class FormValidationController {
  FormValidationController._privateConstructor();

  static final FormValidationController instance =
      FormValidationController._privateConstructor();

  final ValueNotifier<Email> email = ValueNotifier<Email>(const Email.pure());
  final ValueNotifier<Password> password =
      ValueNotifier<Password>(const Password.pure());

  final ValueNotifier<FormzStatus> status =
      ValueNotifier<FormzStatus>(FormzStatus.pure);

  void emailUnfocused() {
    final dirtyEmail = Email.dirty(email.value.value);
    email.value = dirtyEmail;
    status.value = Formz.validate([dirtyEmail, password.value]);
  }

  void passwordUnfocused() {
    final dirtyPassword = Password.dirty(password.value.value);
    password.value = dirtyPassword;
    status.value = Formz.validate([dirtyPassword, email.value]);
  }

  void emailChanged(String value) {
    final changedEmail = Email.dirty(value);
    email.value = changedEmail.valid ? changedEmail : Email.pure(value);
    status.value = Formz.validate([changedEmail, password.value]);
  }

  void passwordChanged(String value) {
    final changedPassword = Password.dirty(value);
    password.value =
        changedPassword.valid ? changedPassword : Password.pure(value);
    status.value = Formz.validate([changedPassword, email.value]);
  }

  Future<void> formSubmitted() async {
    final submittedEmail = Email.dirty(email.value.value);
    final submittedPassword = Password.dirty(password.value.value);

    email.value = submittedEmail;
    password.value = submittedPassword;
    status.value = Formz.validate([submittedEmail, submittedPassword]);

    if (status.value.isValidated) {
      status.value = FormzStatus.submissionInProgress;
      await Future<void>.delayed(const Duration(seconds: 1));
      status.value = FormzStatus.submissionSuccess;
    }
  }
}

class Email extends FormzInput<String, EmailValidationError> {
  const Email.pure([String value = '']) : super.pure(value);
  const Email.dirty([String value = '']) : super.dirty(value);

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );

  @override
  EmailValidationError? validator(String? value) {
    return _emailRegex.hasMatch(value ?? '')
        ? null
        : EmailValidationError.invalid;
  }
}

class Password extends FormzInput<String, PasswordValidationError> {
  const Password.pure([String value = '']) : super.pure(value);
  const Password.dirty([String value = '']) : super.dirty(value);

  static final _passwordRegex =
      RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  PasswordValidationError? validator(String? value) {
    return _passwordRegex.hasMatch(value ?? '')
        ? null
        : PasswordValidationError.invalid;
  }
}
