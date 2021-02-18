import 'package:flutter/material.dart';
import 'package:xapp/services/Translate.dart';
import 'package:xapp/widget/typographie/Heading.dart';
import 'package:xapp/widget/typographie/MainText.dart';

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
            Heading(
              label: t(context).thanksTitle,
            ),
            MainText(
              label: t(context).usernameReservedText,
            ),
            MainText(
              label: t(context).checkInboxText,
            ),
          ],
        ),
      ),
    );
  }
}
