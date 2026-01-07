import 'package:flutter/material.dart';

class ClassicSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? leadingIcon;
  final Function(String)? onTextChange;
  final List<Widget>? trailingIcons;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  const ClassicSearchBar({
    super.key,
    required this.controller,
    this.hintText,
    this.leadingIcon,
    this.onTextChange,
    this.trailingIcons,
    this.hintStyle,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      hintText: hintText ?? "Search...",
      leading: leadingIcon,
      trailing: trailingIcons,
      onChanged: onTextChange,
      textStyle: WidgetStateProperty.all(textStyle),
      hintStyle: WidgetStateProperty.all(hintStyle),
      backgroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(2),
      shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0))),
    );
  }
}
