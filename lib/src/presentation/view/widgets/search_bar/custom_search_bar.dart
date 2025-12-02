import 'package:flutter/material.dart';
import 'package:live_map_tracking/src/presentation/view/widgets/search_bar/classic_search_bar.dart';
import 'package:live_map_tracking/src/presentation/view/widgets/search_bar/rounded_search_bar.dart';

enum SearchBarType { classic, rounded }

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final IconData? icon;
  final Function(String)? onTextChange;
  final SearchBarType type;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText,
    this.icon,
    this.onTextChange,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SearchBarType.classic:
        return ClassicSearchBar(
          controller: controller,
          hintText: hintText,
          icon: icon,
          onTextChange: onTextChange,
        );
      case SearchBarType.rounded:
        return RoundedSearchBar(
          controller: controller,
          hintText: hintText,
          icon: icon,
          onTextChange: onTextChange,
        );
    }
  }
}
