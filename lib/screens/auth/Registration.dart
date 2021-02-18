import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Booking.dart';
import 'package:xapp/screens/auth/CreateAccount.dart';
import 'package:xapp/screens/auth/Login.dart';
import 'package:xapp/services/Translate.dart';
import 'package:xapp/widget/form/MainButton.dart';
import 'package:xapp/widget/typographie/Heading.dart';
import 'package:xapp/widget/typographie/MainText.dart';

class Registration extends StatefulWidget {
  final FirestoreProvider firestoreProvider;
  final FunctionProvider functionProvider;

  const Registration({
    Key key,
    this.firestoreProvider,
    this.functionProvider,
  }) : super(key: key);

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final TextEditingController _textEditingController = TextEditingController();

  bool _isValid = false;

  @override
  void initState() {
    super.initState();

    _textEditingController.addListener(() {
      if (_textEditingController.text.isNotEmpty) {
        if (!EmailValidator.validate(_textEditingController.text)) {
          setState(() => _isValid = false);

          return;
        }

        setState(() => _isValid = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
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
                  label: t(context).enterInvitedEmailText,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 15.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _textEditingController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: t(context).emailLabelForm,
                        ),
                      ),
                      Visibility(
                        visible:
                            !_isValid && _textEditingController.text.isNotEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                          ),
                          child: Text(
                            t(context).invalideEmail,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(color: Theme.of(context).errorColor),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                MainButton(
                  label: t(context).continueButton.toUpperCase(),
                  onPressed: _isValid
                      ? () async {
                          final INVITED result = await widget.firestoreProvider
                              .isInvitedEmail(_textEditingController.text);

                          Widget screen = CreateAccount(
                            firestoreProvider: widget.firestoreProvider,
                            functionProvider: widget.functionProvider,
                            email: _textEditingController.text,
                          );

                          if (result == INVITED.EMAIL_NOT_FOUND) {
                            screen = Booking(
                              firestoreProvider: widget.firestoreProvider,
                              functionProvider: widget.functionProvider,
                              email: _textEditingController.text,
                            );

                            final bool isUniqueEmail = await widget
                                .firestoreProvider
                                .isUniqueEmail(_textEditingController.text);

                            if (!isUniqueEmail) {
                              screen = Login();
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => screen,
                            ),
                          );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
