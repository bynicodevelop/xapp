import 'package:flutter/material.dart';
import 'package:xapp/Config.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Booking.dart';
import 'package:xapp/screens/auth/Registration.dart';
import 'package:xapp/services/Translate.dart';
import 'package:xapp/widget/form/MainButton.dart';
import 'package:xapp/widget/typographie/Heading.dart';
import 'package:xapp/widget/typographie/MainText.dart';

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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Heading(
            label: Config.appName,
          ),
          MainText(
            label: t(context)
                .appInLaunch
                .replaceFirst(r'$appName', Config.appName),
          ),
          MainText(
            label: t(context).registrationOnInvivationMessage,
          ),
          MainButton(
            label: t(context).invitationLabel,
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
              t(context).notInvitationLabel,
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
