import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xapp/Config.dart';
import 'package:xapp/Home.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/services/FormValidation.dart';
import 'package:xapp/widget/form/MainButton.dart';
import 'package:xapp/widget/form/PasswordInput.dart';
import 'package:xapp/widget/form/TextInput.dart';

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
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20.0,
                  ),
                  child: Text(
                    "Créons votre compte",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Text(
                    "Pour finaliser la préparation de votre compte, merci de remplir les champs suivants",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
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
                        label: "Entrez un nom d'utilisateur",
                        validator: (value) => value.length > 2
                            ? null
                            : "Votre nom d'utilisateur doit contenir au moins 2 catactères",
                      ),
                      TextInput(
                        controller: _slugController,
                        validator: (value) => !_isUniqueSlug
                            ? "Cet identifiant exist déjà. Pourquoi ne pas en essayer un autre."
                            : null,
                        label: "Votre identifiant pourrait être le suivant...",
                      ),
                      PasswordInput(
                        controller: _passwordController,
                        validator: (value) => value.length > 5
                            ? null
                            : "Votre mot de passe doit contenu plus de 6 caractères.",
                        label: "Saisissez un mot de passe",
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
                                        content: Text(
                                            "Nous n'avons pas pu créer votre compte. Nos service ont été prévenu (Merci de bien vouloir réésayer un peu plutard)."),
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
                        label: "Créer mon compte".toUpperCase(),
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
