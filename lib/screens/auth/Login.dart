import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xapp/Home.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Registration.dart';
import 'package:xapp/services/Translate.dart';
import 'package:xapp/widget/form/LinkButton.dart';
import 'package:xapp/widget/form/MainButton.dart';
import 'package:xapp/widget/form/PasswordInput.dart';
import 'package:xapp/widget/form/TextInput.dart';
import 'package:xapp/widget/typographie/Heading.dart';
import 'package:xapp/widget/typographie/MainText.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  FirestoreProvider _firestoreProvider;
  FunctionProvider _functionProvider;
  AuthProvider _authProvider;

  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    _firestoreProvider = Provider.of<FirestoreProvider>(context, listen: false);
    _functionProvider = Provider.of<FunctionProvider>(context, listen: false);

    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                  height: 100.0,
                  image: AssetImage("assets/logo.png"),
                ),
                Heading(
                  label: t(context).loginTitle,
                ),
                MainText(
                  label: t(context).loginText,
                ),
                Form(
                  key: _formKey,
                  onChanged: () => setState(
                      () => _isValid = _formKey.currentState.validate()),
                  child: Column(
                    children: [
                      TextInput(
                        controller: _emailController,
                        validator: (value) => !EmailValidator.validate(value)
                            ? t(context).enterValideEmailErrorMessage
                            : null,
                        label: t(context).emailLabelForm,
                      ),
                      PasswordInput(
                        controller: _passwordController,
                        validator: (value) => value.length < 6
                            ? t(context).passwordErrorMessage
                            : null,
                        label: t(context).passwordLabel,
                      ),
                      MainButton(
                        label: t(context).connectMeButton,
                        onPressed: _isValid
                            ? () async {
                                if (!_formKey.currentState.validate()) {
                                  // TODO: Afficher une snackbar
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text(t(context).invalidForm),
                                  ));
                                  return;
                                }

                                try {
                                  await _authProvider.login(
                                    _emailController.text,
                                    _passwordController.text,
                                  );

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Home(),
                                    ),
                                    (_) => false,
                                  );
                                } catch (e) {
                                  String message =
                                      t(context).conectionErrorMessage;

                                  switch (e.code) {
                                    case 'user-not-found':
                                    case 'wrong-password':
                                      message =
                                          t(context).badCredentialErrorMessage;
                                      break;
                                  }
                                  _scaffoldKey.currentState.showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                    ),
                                  );
                                }
                              }
                            : null,
                      ),
                      LinkButton(
                        label: t(context).createAccountBtn,
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Registration(
                                firestoreProvider: _firestoreProvider,
                                functionProvider: _functionProvider,
                              ),
                            )),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
