import 'package:flutter/material.dart';
import 'package:xapp/Config.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Thanks.dart';
import 'package:xapp/services/FormValidation.dart';
import 'package:xapp/widget/form/MainButton.dart';

class Booking extends StatefulWidget {
  final FirestoreProvider firestoreProvider;
  final FunctionProvider functionProvider;
  final String email;

  const Booking({
    Key key,
    this.firestoreProvider,
    this.functionProvider,
    this.email = '',
  }) : super(key: key);

  @override
  _BookingState createState() => _BookingState();
}

class _BookingState extends State<Booking> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _slugController = TextEditingController();

  bool _isValid = false;
  bool _isUniqueSlug = true;
  bool _isReservation = false;

  @override
  void initState() {
    super.initState();

    if (widget.email.isNotEmpty) {
      _emailController.text = widget.email;
    } else {
      setState(() => _isReservation = true);
    }

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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 20.0,
                  ),
                  child: Text(
                    "Reservez votre nom d'utilisateur",
                    style: Theme.of(context).textTheme.headline1,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Text(
                    widget.email.isNotEmpty
                        ? "L'adresse email que vous avez saisie, ne fait pas partie de nos invités."
                        : "${Config.appName} est encore en plein lancement.",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Text(
                    "Mais bonne nouvelle !",
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10.0,
                  ),
                  child: Text(
                    "Vous pouvez réserver votre nom d'utilisateur.",
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
                      Visibility(
                        visible: _isReservation,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 5.0,
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              errorMaxLines: 2,
                              border: OutlineInputBorder(),
                              labelText: "Entrez votre email principal",
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        child: TextFormField(
                          controller: _usernameController,
                          validator: (value) => value.length > 2
                              ? null
                              : "Votre nom d'utilisateur doit contenir au moins 2 catactères",
                          decoration: InputDecoration(
                            errorMaxLines: 2,
                            border: OutlineInputBorder(),
                            labelText: "Entrez un nom d'utilisateur",
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5.0,
                        ),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _slugController,
                              decoration: InputDecoration(
                                errorMaxLines: 2,
                                errorText: !_isUniqueSlug
                                    ? "Cet identifiant exist déjà. Pourquoi ne pas en essayer un autre."
                                    : null,
                                border: OutlineInputBorder(),
                                labelText:
                                    "Votre identifiant pourrait être le suivant...",
                              ),
                            ),
                          ],
                        ),
                      ),
                      MainButton(
                        label: 'Reserver'.toUpperCase(),
                        onPressed: _isValid && _isUniqueSlug
                            ? () async {
                                if (_formKey.currentState.validate()) {
                                  final bool result = await widget
                                      .functionProvider
                                      .createUserReservation(
                                    _emailController.text,
                                    _usernameController.text,
                                    _slugController.text,
                                  );

                                  if (result) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Thanks(),
                                      ),
                                    );
                                  } else {
                                    _scaffoldKey.currentState.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            "Nous n'avons pas pu prendre en compte votre enregistrement pour des raisons techniques."),
                                      ),
                                    );
                                  }
                                }
                              }
                            : null,
                      ),
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
