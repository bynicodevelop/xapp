import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

class LikeButton extends StatefulWidget {
  final Function onTap;
  final int likes;
  final bool hasLiked;

  const LikeButton({
    Key key,
    this.onTap,
    this.likes = 0,
    this.hasLiked = false,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            bottom: 10.0,
          ),
          child: GestureDetector(
            onTap: () async {
              setState(() => _loading = true);

              await widget.onTap();

              setState(() => _loading = false);
            },
            child: _loading
                ? SpinKitPumpingHeart(
                    color: Color(0xFFC2185B),
                    size: 60.0,
                  )
                : Icon(
                    widget.hasLiked ? Icons.favorite : Icons.favorite_outline,
                    size: 60,
                    color: !widget.hasLiked ? Colors.white : Color(0xFFC2185B),
                  ),
          ),
        ),
        Text(
          NumberFormat.compact().format(widget.likes),
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
