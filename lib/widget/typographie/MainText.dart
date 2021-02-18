import 'package:flutter/material.dart';

class MainText extends StatelessWidget {
  final String label;
  const MainText({
    Key key,
    this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10.0,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyText2,
      ),
    );
  }
}
