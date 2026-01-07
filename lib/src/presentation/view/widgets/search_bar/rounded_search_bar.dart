import 'package:flutter/material.dart';

class RoundedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? leadingIcon;
  final List<Widget>? trailingIcons;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Function(String)? onTextChange;
  const RoundedSearchBar({
    super.key,
    required this.controller,
    this.hintText,
    this.onTextChange,
    this.leadingIcon,
    this.trailingIcons,
    this.hintStyle,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)),
      controller: controller,
      hintText: hintText ?? "Search...",
      textStyle: WidgetStateProperty.all(textStyle),
      hintStyle: WidgetStateProperty.all(hintStyle),
      leading: leadingIcon,
      trailing: trailingIcons,
      onChanged: onTextChange,
      backgroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(2),
      shape: WidgetStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0))),
    );
  }
}
