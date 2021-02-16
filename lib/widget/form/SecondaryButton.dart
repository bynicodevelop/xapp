import 'package:flutter/material.dart';
import 'package:xapp/widget/form/MainButton.dart';

class SecondaryButton extends StatelessWidget {
  final Function onPressed;
  final String label;

  const SecondaryButton({
    Key key,
    @required this.label,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MainButton(
      label: label,
      onPressed: onPressed,
      color: Theme.of(context).accentColor,
    );
  }
}
