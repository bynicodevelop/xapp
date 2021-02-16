import 'package:flutter/material.dart';

class LinkButton extends StatelessWidget {
  final Function onPressed;
  final String label;

  const LinkButton({
    Key key,
    this.onPressed,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      child: Text(
        this.label,
        style: Theme.of(context).textTheme.bodyText2.copyWith(
              fontStyle: FontStyle.italic,
            ),
      ),
      onPressed: onPressed,
    );
  }
}
