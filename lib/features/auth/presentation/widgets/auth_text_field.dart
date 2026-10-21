import 'package:flutter/material.dart';

import '../../../../shared/design_system/app_colors.dart';

/// Labelled rounded field. Grey at rest, white with a green ring on focus.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.focusNode,
    this.obscureText = false,
    this.enabled = true,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool obscureText;
  final bool enabled;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffixIcon;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _focused = false;

  static OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Focus(
          canRequestFocus: false,
          onFocusChange: (focused) => setState(() => _focused = focused),
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            enabled: widget.enabled,
            autofocus: widget.autofocus,
            obscureText: widget.obscureText,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            validator: widget.validator,
            onFieldSubmitted: widget.onFieldSubmitted,
            style: const TextStyle(fontSize: 16, color: AppColors.ink),
            cursorColor: AppColors.ink,
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(color: AppColors.hint, fontSize: 16),
              filled: true,
              fillColor: _focused ? AppColors.surface : AppColors.fieldFill,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              suffixIcon: widget.suffixIcon,
              enabledBorder: _border(Colors.transparent),
              disabledBorder: _border(Colors.transparent),
              focusedBorder: _border(AppColors.brand, 1.5),
              errorBorder: _border(AppColors.error),
              focusedErrorBorder: _border(AppColors.error, 1.5),
              errorStyle: const TextStyle(color: AppColors.error),
            ),
          ),
        ),
      ],
    );
  }
}
