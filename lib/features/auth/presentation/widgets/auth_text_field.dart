import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AuthTextField extends StatefulWidget {
  const AuthTextField({
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    super.key,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.autofillHints,
    this.helperText,
    this.errorText,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;

  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Iterable<String>? autofillHints;
  final String? helperText;
  final String? errorText;
  final int maxLines;

  @override
  State<AuthTextField> createState() {
    return _AuthTextFieldState();
  }
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();

    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: _isObscured,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      autofillHints: widget.autofillHints,
      cursorColor: AppColors.blue,
      style: const TextStyle(
        color: AppColors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText,
        helperText: widget.helperText,
        errorText: widget.errorText,
        labelStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.78),
        ),
        hintStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.48),
        ),
        helperStyle: TextStyle(
          color: AppColors.textSecondary.withValues(alpha: 0.7),
          fontSize: 11.5,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: AppColors.textSecondary,
          size: 21,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _isObscured ? 'Show password' : 'Hide password',
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
                icon: Icon(
                  _isObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.textSecondary,
                ),
              )
            : null,
        filled: true,
        fillColor: AppColors.white.withValues(alpha: 0.075),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: _createBorder(AppColors.white.withValues(alpha: 0.26)),
        focusedBorder: _createBorder(
          AppColors.blue.withValues(alpha: 0.88),
          width: 1.35,
        ),
        errorBorder: _createBorder(const Color(0xFFFF8A9B)),
        focusedErrorBorder: _createBorder(const Color(0xFFFF8A9B), width: 1.35),
        errorStyle: const TextStyle(color: Color(0xFFFFB3BE), fontSize: 11.5),
      ),
    );
  }

  OutlineInputBorder _createBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(17),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
