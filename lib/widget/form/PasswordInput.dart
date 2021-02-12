import 'package:flutter/material.dart';

class PasswordInput extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) validator;
  final String label;

  const PasswordInput({
    Key key,
    @required this.controller,
    @required this.validator,
    @required this.label,
  }) : super(key: key);

  @override
  _PasswordInputState createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  bool _isSecret = true;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: TextFormField(
        obscureText: _isSecret,
        controller: widget.controller,
        validator: widget.validator,
        decoration: InputDecoration(
          errorMaxLines: 2,
          border: OutlineInputBorder(),
          labelText: widget.label,
          suffixIcon: InkWell(
            onTap: () => setState(() => _isSecret = !_isSecret),
            child: Icon(!_isSecret ? Icons.visibility : Icons.visibility_off),
          ),
        ),
      ),
    );
  }
}
