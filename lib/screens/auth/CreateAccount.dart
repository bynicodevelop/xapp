import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xapp/Config.dart';
import 'package:xapp/Home.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/services/FormValidation.dart';
import 'package:xapp/services/Translate.dart';
import 'package:xapp/widget/form/MainButton.dart';
import 'package:xapp/widget/form/PasswordInput.dart';
import 'package:xapp/widget/form/TextInput.dart';
import 'package:xapp/widget/typographie/Heading.dart';
import 'package:xapp/widget/typographie/MainText.dart';

class CreateAccount extends StatefulWidget {
  final FirestoreProvider firestoreProvider;
  final FunctionProvider functionProvider;
  final String email;

  const CreateAccount({
    Key key,
    this.firestoreProvider,
    this.functionProvider,
    this.email,
  }) : super(key: key);

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  AuthProvider _authProvider;

  bool _isUniqueSlug = true;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _usernameController.addListener(() {
      if (_usernameController.text.isNotEmpty) {
        _slugController.value = TextEditingValue(
          text: slugifyField(_usernameController.text),
          selection: _slugController.selection,
        );
      }
    });

    _slugController.addListener(
      () => isUniqueSlug(
        _slugController.text,
        widget.firestoreProvider,
      ).then(
        (isUniqueSlug) => setState(() => _isUniqueSlug = isUniqueSlug),
      ),
    );
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
              children: [
                Heading(
                  label: t(context).createAccountTitle,
                ),
                MainText(
                  label: t(context).textCreateAccount,
                ),
                Form(
                  key: _formKey,
                  onChanged: () => setState(
                    () => _isValid = _formKey.currentState.validate(),
                  ),
                  child: Column(
                    children: [
                      TextInput(
                          controller: _usernameController,
                          label: t(context).usernameLabelForm,
                          validator: (value) => value.length > 2
                              ? null
                              : t(context).invalidUsername),
                      TextInput(
                        controller: _slugController,
                        validator: (value) =>
                            !_isUniqueSlug ? t(context).slugAlreadyUse : null,
                        label: t(context).slugExample,
                      ),
                      PasswordInput(
                        controller: _passwordController,
                        validator: (value) => value.length > 5
                            ? null
                            : t(context).passwordErrorMessage,
                        label: t(context).passwordLabel,
                      ),
                      MainButton(
                        onPressed: _isValid && _isUniqueSlug
                            ? () async {
                                if (_formKey.currentState.validate()) {
                                  String email = widget.email;
                                  print(email);
                                  String uid =
                                      await _authProvider.createAccount(
                                    widget.email,
                                    _passwordController.text,
                                    _usernameController.text,
                                    _slugController.text,
                                  );

                                  if (uid == null) {
                                    _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        content: Text(t(context)
                                            .createAccountErrorMessage),
                                      ),
                                    );

                                    return;
                                  }

                                  // TODO: Uniquement pour tester en local
                                  if (!Config.production) {
                                    uid = "HRFOFJvXA3yaY9jFUQgiP9Vkd0o3";
                                    email = "boby@domain.tld";
                                  }

                                  final bool result = await widget
                                      .functionProvider
                                      .createAccount(
                                    email,
                                    _usernameController.text,
                                    _slugController.text,
                                    uid,
                                  );

                                  if (!result) {
                                    // TODO: Gérer le cas ou l'inscription est ok, mais pas possible de mettre à jour le profil
                                  }

                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Home(),
                                    ),
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              }
                            : null,
                        label: t(context).createAccountButton.toUpperCase(),
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
