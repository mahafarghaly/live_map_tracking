import 'package:flutter/material.dart';
import 'package:live_map_tracking/src/presentation/controllers/search_controller.dart';
import 'package:live_map_tracking/src/presentation/view/widgets/search_bar/custom_search_bar.dart';
import '../../../data/models/places_autocomplete.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchRoutesScreen extends ConsumerStatefulWidget {
  const SearchRoutesScreen({super.key, required this.apiKey, this.prefixSearchIcon, this.suffixSearchIcons, this.hintStyle, this.textStyle, this.hintText});
  final String? hintText;
  final Widget? prefixSearchIcon;
  final List<Widget>? suffixSearchIcons;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
final String apiKey;
  @override
  ConsumerState<SearchRoutesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends ConsumerState<SearchRoutesScreen> {
  final _originController = TextEditingController();
  final _destController = TextEditingController();

  bool _isOriginActive = true;

  void _onTextChange(String value) {
    if (value.isEmpty) {
      ref.read(searchControllerProvider(widget.apiKey).notifier).clearSuggestions();
    } else {
      ref.read(searchControllerProvider(widget.apiKey).notifier).searchPlaces(value);
    }
  }

  Future<void> _onSelectSuggestion(Suggestion suggestion) async {
    await ref
        .read(searchControllerProvider(widget.apiKey).notifier)
        .selectPlaceRoute(
          suggestion.placePrediction.placeId,
          isOrigin: _isOriginActive,
        );

    if (_isOriginActive) {
      _originController.text =
          suggestion.placePrediction.structuredFormat.mainText.text;
    } else {
      _destController.text =
          suggestion.placePrediction.structuredFormat.mainText.text;
    }
    ref.read(searchControllerProvider(widget.apiKey).notifier).clearSuggestions();

    final state = ref.read(searchControllerProvider(widget.apiKey));
    if (state.destination != null) {
      Navigator.pop(context, {
        'origin': state.origin,
        'destination': state.destination,
      });
      ref.read(searchControllerProvider(widget.apiKey).notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider(widget.apiKey));

    return Scaffold(
      appBar: AppBar(title: const Text("Search Route")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _originController,
                  hintText:widget.hintText,
                  leadingIcon: widget.prefixSearchIcon,
                  trailingIcons:widget.suffixSearchIcons,
                  hintStyle: widget.hintStyle,
                  textStyle: widget.textStyle,
                  onTextChange: (v) {
                    setState(() => _isOriginActive = true);
                    _onTextChange(v);
                  },  type: SearchBarType.classic,
                ),
                const SizedBox(height: 16),
                CustomSearchBar(
                  controller: _destController,
                  hintText:widget.hintText,
                  leadingIcon: widget.prefixSearchIcon,
                  trailingIcons:widget.suffixSearchIcons,
                  hintStyle: widget.hintStyle,
                  textStyle: widget.textStyle,
                  onTextChange: (v) {
                    setState(() => _isOriginActive = false);
                    _onTextChange(v);
                  },
                  type: SearchBarType.classic,
                ),
              ],
            ),
          ),
          if (state.loading) const LinearProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemCount: state.suggestions.length,
              itemBuilder: (context, index) {
                final s = state.suggestions[index];
                return ListTile(
                  title: Text(s.placePrediction.structuredFormat.mainText.text),
                  subtitle: Text(
                    s.placePrediction.structuredFormat.secondaryText.text,
                  ),
                  onTap: () => _onSelectSuggestion(s),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
