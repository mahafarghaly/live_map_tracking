import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? icon;
  final Function(String)? onTextChange;
  const CustomSearchBar({super.key, required this.controller, this.hintText, this.icon, this.onTextChange});

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
        hintText: hintText??"",
      leading:Icon(icon),
      onChanged:onTextChange,
    );
  }
}
