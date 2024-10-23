import 'package:flutter/material.dart';
import '../../../constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final String? obscureCharacter;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxChar;
  final String? Function(String?)? validator; // Add the validator parameter

  const CustomTextField({super.key,
    required this.controller,
    required this.keyboardType,
    required this.obscureText,
    this.obscureCharacter = '*',
    required this.hintText,
    this.prefixIcon,
    required this.suffixIcon,
    this.maxChar,
    this.validator,
  });


  @override
  Widget build(BuildContext context) {
    return TextFormField(style: const TextStyle(color: gpSecondaryColor,fontSize: 14),
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxChar,
      obscureText: obscureText!,
      obscuringCharacter: obscureCharacter!,
      decoration: InputDecoration(labelStyle: const TextStyle(fontWeight: FontWeight.bold,color: Color.fromARGB(140, 28, 63, 57),fontSize: 14),
        fillColor: gpPrimaryColor,
        labelText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: gpSecondaryColor,
            width: 2.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(width: 2.4,
            color: gpSecondaryColor,
          ),
        ),
        contentPadding: const EdgeInsets.all(10),
      ),
        validator: validator
    );
  }
}