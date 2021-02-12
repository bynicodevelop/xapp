import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Stat extends StatelessWidget {
  static const LEFT = 'left';
  static const RIGHT = 'right';

  final String label;
  final String align;
  final int number;

  const Stat({
    Key key,
    this.number,
    this.label,
    this.align,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          align == 'left' ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          NumberFormat.compact().format(number),
          style: Theme.of(context).textTheme.subtitle2.copyWith(
                fontSize: 20.0,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.caption.copyWith(
                fontSize: 16.0,
              ),
        ),
      ],
    );
  }
}
