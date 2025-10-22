import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final int? maxLength;

  const TextFieldInput({
    super.key, 
    required this.hintText,
    this.isPass = false,
    required this.textEditingController,
    required this.textInputType,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextField(
      controller: textEditingController,
      maxLines: isPass ? 1 : maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),        
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? '' : null, 
      ),
      keyboardType: textInputType,
      obscureText: isPass,
      onChanged: onChanged,
    );
  }
}