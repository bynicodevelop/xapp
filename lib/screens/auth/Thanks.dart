import 'package:flutter/material.dart';

class Thanks extends StatelessWidget {
  const Thanks({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 20.0,
              ),
              child: Text(
                'Merci.',
                style: Theme.of(context).textTheme.headline1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                bottom: 10.0,
              ),
              child: Text(
                "Votre nom d'utilisateur est réservé.",
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            Text(
              "Surveillez votre boite mail, il est possible que vous receviez un accès à votre compte.",
              style: Theme.of(context).textTheme.bodyText2,
            ),
          ],
        ),
      ),
    );
  }
}
