import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  final String label;

  Heading({
    Key key,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 20.0,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.headline1,
      ),
    );
  }
}
