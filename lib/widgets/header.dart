import 'package:belanjain/components/colors.dart';
import 'package:belanjain/screen/index.dart';
import 'package:flutter/material.dart';

class MyHeader extends StatelessWidget {
  final String title;
  final void Function()? onTapLeft;
  final void Function()? onTapRight;
  final IconData? iconRight;

  const MyHeader({
    Key? key,
    required this.title,
    required this.onTapLeft,
    this.onTapRight,
    this.iconRight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: primaryColor,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: whiteColor,
            ),
            onPressed: onTapLeft,
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: Icon(iconRight),
            onPressed: onTapRight,
          ),
        ],
      ),
    );

  }
}