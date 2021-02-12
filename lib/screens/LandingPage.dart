import 'package:flutter/material.dart';
import 'package:xapp/Config.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Booking.dart';
import 'package:xapp/screens/auth/Registration.dart';
import 'package:xapp/widget/form/MainButton.dart';

class LandingPage extends StatelessWidget {
  final FirestoreProvider firestoreProvider;
  final FunctionProvider functionProvider;

  const LandingPage({
    Key key,
    this.firestoreProvider,
    this.functionProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
            ),
            child: Text(
              Config.appName,
              style: Theme.of(context).textTheme.headline1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 15.0,
            ),
            child: Text(
              '${Config.appName} est encore en plein lancement.',
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              bottom: 20.0,
            ),
            child: Text(
              "Il possible de s'inscrire que si vous avez reçu une invitation.",
              style: Theme.of(context).textTheme.bodyText2,
              textAlign: TextAlign.center,
            ),
          ),
          MainButton(
            label: "Je n'ai reçu une invitation",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Registration(
                  firestoreProvider: firestoreProvider,
                  functionProvider: functionProvider,
                ),
              ),
            ),
          ),
          MaterialButton(
            child: Text(
              "J'ai pas de lien",
              style: Theme.of(context).textTheme.bodyText2.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Booking(
                  firestoreProvider: firestoreProvider,
                  functionProvider: functionProvider,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
