import 'package:flutter/material.dart';

/// Themed form field used by Login and Sign up. Errors show under the field.
/// Set [obscure] for password fields; it adds a show/hide toggle.
class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? Function(String?)? validator;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.validator,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      validator: widget.validator,
      obscureText: widget.obscure && _hidden,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: widget.label,
        prefixIcon: Icon(widget.icon),
        suffixIcon: widget.obscure
            ? IconButton(
                tooltip: _hidden ? 'Show password' : 'Hide password',
                icon: Icon(
                  _hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
      ),
    );
  }
}
