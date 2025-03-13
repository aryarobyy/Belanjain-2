import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String name;
  final IconData? prefixIcon;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final TextInputType inputType;
  final int? maxLine;
  final int? minLine;
  final String? hintText;
  final Color? textColor;
  final Color? outlineColor;

  const MyTextField({
    Key? key,
    required this.controller,
    required this.name,
    this.prefixIcon,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    required this.inputType,
    this.maxLine = 1,
    this.minLine = 1,
    this.hintText,
    this.textColor,
    this.outlineColor,
  }) : super(key: key);

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Material(
        color: Colors.transparent,
        child: TextField(
          enabled: true,
          controller: widget.controller,
          textCapitalization: widget.textCapitalization,
          keyboardType: widget.inputType == TextInputType.multiline
              ? TextInputType.multiline
              : widget.inputType,
          maxLines: widget.maxLine,
          minLines: widget.minLine,
          obscureText: _obscureText,
          textAlign: TextAlign.start,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon)
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
              icon: Icon(
                _obscureText
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : null,
            isDense: true,
            labelText: widget.name,
            hintText: widget.hintText,
            counterText: "",
            labelStyle: TextStyle(color: widget.textColor ?? Colors.grey),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: widget.outlineColor ?? Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.outlineColor ?? Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: widget.outlineColor ?? Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ),
    );
  }
}