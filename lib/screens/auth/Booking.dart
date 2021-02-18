import 'package:flutter/material.dart';
import 'package:xapp/Config.dart';
import 'package:xapp/providers/FirestoreProvider.dart';
import 'package:xapp/providers/FunctionProvider.dart';
import 'package:xapp/screens/auth/Thanks.dart';
import 'package:xapp/services/FormValidation.dart';
import 'package:xapp/services/Translate.dart';
import 'package:xapp/widget/form/MainButton.dart';
import 'package:xapp/widget/typographie/Heading.dart';
import 'package:xapp/widget/typographie/MainText.dart';

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
                Heading(
                  label: t(context).reserveUsernameTitle,
                ),
                MainText(
                  label: widget.email.isNotEmpty
                      ? t(context).invalidInvitationEmailMessage
                      : t(context)
                          .appInLaunch
                          .replaceFirst(r'$appName', Config.appName),
                ),
                MainText(
                  label: t(context).goodNew,
                ),
                MainText(
                  label: t(context).reserveUsername,
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
                              labelText: t(context).emailLabelForm,
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
                              : t(context).invalidUsername,
                          decoration: InputDecoration(
                            errorMaxLines: 2,
                            border: OutlineInputBorder(),
                            labelText: t(context).usernameLabelForm,
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
                                    ? t(context).slugAlreadyUse
                                    : null,
                                border: OutlineInputBorder(),
                                labelText: t(context).slugExample,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MainButton(
                        label: t(context).reserve.toUpperCase(),
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
                                        content:
                                            Text(t(context).errorRegistration),
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
