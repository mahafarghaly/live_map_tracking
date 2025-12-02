import 'package:flutter/material.dart';

class RoundedSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? icon;
  final Function(String)? onTextChange;

  const RoundedSearchBar({
    super.key,
    required this.controller,
    this.hintText,
    this.icon,
    this.onTextChange,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      ),
      controller: controller,
      hintText: hintText ?? "Search...",
      leading: Icon(icon ?? Icons.search),
      onChanged: onTextChange,
      backgroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(2),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
      ),

    );
  }
}
