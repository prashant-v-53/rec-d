import 'package:flutter/material.dart';

class StarsWidget extends StatefulWidget {
  final int activeStars;
  final bool small;
  StarsWidget({this.activeStars, this.small = false});
  @override
  _StarsWidgetState createState() => _StarsWidgetState();
}

class _StarsWidgetState extends State<StarsWidget> {
  Size size;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Container(
      child: stars(),
      padding: EdgeInsets.all(widget.small ? 0 : size.height * 0.02),
    );
  }

  Widget stars() {
    int starCount = 1;
    final children = <Widget>[];
    for (var i = 1; i <= widget.activeStars; i++) {
      if (widget.small) {
        children.add(
          Icon(
            Icons.star,
            color: Colors.white,
            size: 20,
          ),
        );
      } else {
        children.add(Icon(
          Icons.star,
          color: Colors.white,
          size: 30.0,
        ));
      }
      starCount++;
    }
    if (starCount > 0) {
      for (var i = starCount; i <= 5; i++) {
        if (widget.small) {
          children.add(Icon(
            Icons.star,
            color: Colors.grey.withOpacity(0.5),
            size: 30,
          ));
        } else {
          children.add(Icon(
            Icons.star,
            color: Colors.grey.withOpacity(
              0.5,
            ),
            size: 30,
          ));
        }
        starCount++;
      }
    }

    return new Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }
}
