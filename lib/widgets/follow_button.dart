import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final Function()? function;
  final Color backgroundColor;
  final Color borderColor;
  final String text;
  final Color textColor;
  final double height;
  final EdgeInsetsGeometry margin;
  
  const FollowButton({
    super.key,
    this.function,
    required this.backgroundColor,
    required this.borderColor,
    required this.text,
    required this.textColor,
    this.height = 36,
    this.margin = const EdgeInsets.only(top: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,      
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: TextButton(
          onPressed: function,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
              side: BorderSide(color: borderColor),
            ),
            backgroundColor: backgroundColor,
          ),
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}