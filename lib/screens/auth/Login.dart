import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xapp/Home.dart';
import 'package:xapp/providers/AuthProvider.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Registration.dart';
import 'package:xapp/widget/form/LinkButton.dart';
import 'package:xapp/widget/form/MainButton.dart';
import 'package:xapp/widget/form/PasswordInput.dart';
import 'package:xapp/widget/form/TextInput.dart';

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
                Padding(
                  padding: const EdgeInsets.only(
                    top: 5.0,
                    bottom: 50.0,
                  ),
                  child: Text(
                    "Connexion",
                    style: Theme.of(context).textTheme.headline1,
                    textAlign: TextAlign.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15.0,
                  ),
                  child: Text(
                    "Veuillez renseigner les champs du formulaire avec les indentifiants que vous avez utilisé pendant votre inscription",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
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
                            ? "Merci de saisir une adresse email valide"
                            : null,
                        label: "Entrez votre adresse email",
                      ),
                      PasswordInput(
                        controller: _passwordController,
                        validator: (value) => value.length < 6
                            ? "Votre mot de passe doit contenir au moins 6 caractères"
                            : null,
                        label: "Entrez votre mot de passe",
                      ),
                      MainButton(
                        label: "Me connecter",
                        onPressed: _isValid
                            ? () async {
                                if (!_formKey.currentState.validate()) {
                                  // TODO: Afficher une snackbar
                                  _scaffoldKey.currentState
                                      .showSnackBar(SnackBar(
                                    content: Text(
                                        "Le formulaire n'est pas complet ou des champs ne sont pas valides"),
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
                                      "Une erreur est survenue pendant votre connexion. Nous mettons tout en oeuvre pour résoudre le problème.";

                                  switch (e.code) {
                                    case 'user-not-found':
                                    case 'wrong-password':
                                      message =
                                          "Vos identifiants ne correpondent à aucun membre.";
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
                        label: "Créer un compte",
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
