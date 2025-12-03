import 'package:flutter/material.dart';

class ClassicSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? icon;
  final Function(String)? onTextChange;

  const ClassicSearchBar({
    super.key,
    required this.controller,
    this.hintText,
    this.icon,
    this.onTextChange,
  });

  @override
  Widget build(BuildContext context) {
  return SearchBar(
      controller: controller,
      hintText: hintText ?? "Search...",
      leading: Icon(icon ?? Icons.search,color: Color(0xffA4A7AE),),
      onChanged: onTextChange,
      backgroundColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(2),
      shape: WidgetStateProperty.all<OutlinedBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );

  }
}
