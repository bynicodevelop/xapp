import 'package:flutter/material.dart';

class TextInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) validator;
  final String label;

  const TextInput({
    Key key,
    @required this.controller,
    @required this.validator,
    @required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        decoration: InputDecoration(
          errorMaxLines: 2,
          border: OutlineInputBorder(),
          labelText: label,
        ),
      ),
    );
  }
}
