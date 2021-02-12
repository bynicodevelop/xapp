import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MainButton extends StatefulWidget {
  final Function onPressed;
  final String label;

  const MainButton({
    Key key,
    @required this.onPressed,
    @required this.label,
  }) : super(key: key);

  @override
  _MainButtonState createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
      ),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 55.0,
        child: RaisedButton(
          onPressed: _loading
              ? null
              : () async {
                  setState(() => _loading = true);

                  await widget.onPressed();

                  setState(() => _loading = false);
                },
          child: _loading
              ? SpinKitThreeBounce(
                  color: Colors.white,
                  size: 15.0,
                )
              : Text(widget.label),
        ),
      ),
    );
  }
}
