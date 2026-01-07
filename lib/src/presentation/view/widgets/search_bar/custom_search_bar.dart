import 'package:flutter/material.dart';
import 'package:live_map_tracking/src/presentation/view/widgets/search_bar/classic_search_bar.dart';
import 'package:live_map_tracking/src/presentation/view/widgets/search_bar/rounded_search_bar.dart';

enum SearchBarType { classic, rounded }

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Widget? leadingIcon;
  final List<Widget>? trailingIcons;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final Function(String)? onTextChange;
  final SearchBarType type;

  const CustomSearchBar({
    super.key,
    required this.controller,
    this.hintText,
    this.onTextChange,
    required this.type, this.leadingIcon, this.trailingIcons, this.hintStyle, this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case SearchBarType.classic:
        return ClassicSearchBar(
          controller: controller,
          hintText: hintText,
          leadingIcon: leadingIcon,
          trailingIcons: trailingIcons,
          onTextChange: onTextChange,
        );
      case SearchBarType.rounded:
        return RoundedSearchBar(
          controller: controller,
          hintText: hintText,
          textStyle: textStyle,
          hintStyle: hintStyle,
          leadingIcon: leadingIcon,
          trailingIcons: trailingIcons,
          onTextChange: onTextChange,
        );
    }
  }
}
