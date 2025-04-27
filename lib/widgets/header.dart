import 'package:belanjain/components/colors.dart';
import 'package:flutter/material.dart';

class MyHeader extends StatelessWidget {
  final String title;
  final void Function()? onTap;

  const MyHeader({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onTap,
            icon: const Icon(
              Icons.arrow_back_outlined,
              color: Colors.white,
            )
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}