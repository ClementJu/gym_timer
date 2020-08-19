import 'package:flutter/material.dart';

class PreferenceTitle extends StatelessWidget {
  final String title;
  final double leftPadding, topPadding, rightPadding, bottomPadding;
  final TextStyle style;
  final Color backgroundColor;
  final Border border;

  PreferenceTitle(
      this.title,
      {
        this.leftPadding = 10.0,
        this.topPadding = 20.0,
        this.rightPadding = 0.0,
        this.bottomPadding = 0.0,
        this.style,
        this.backgroundColor,
        this.border
      }
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: border ?? Border(),
        color: backgroundColor ?? Colors.transparent
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(leftPadding, topPadding, rightPadding, bottomPadding),
        child: Text(
          title,
          style: style ??
              TextStyle(
                  color: Theme.of(context).accentColor,
                  fontWeight: FontWeight.bold),
        ),
      )
    );
  }
}
