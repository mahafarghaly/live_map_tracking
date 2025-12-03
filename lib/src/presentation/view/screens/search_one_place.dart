import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../live_map_tracking.dart';
import '../../../data/models/places_autocomplete.dart';
import '../../controllers/search_controller.dart';
import '../widgets/search_bar/custom_search_bar.dart';

class SearchOnePlaceScreen extends ConsumerStatefulWidget {
  const SearchOnePlaceScreen({ required this.apiKey,this.onPlaceSelected ,super.key});
  final String apiKey;
  final Function(String address, GeoPoint location)? onPlaceSelected;

  @override
  ConsumerState<SearchOnePlaceScreen> createState() =>
      _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends ConsumerState<SearchOnePlaceScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider(widget.apiKey));

    return Scaffold(
      appBar: AppBar(title: const Text("Search a Place")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  hintText: 'search a place',
                  icon: Icons.location_on,
                  onTextChange: (v) {
                    _onTextChange(v);
                  },
                  type: SearchBarType.rounded,
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

  void _onTextChange(String value) {
    if (value.isEmpty) {
      ref.read(searchControllerProvider(widget.apiKey).notifier).clearSuggestions();
    } else {
      ref.read(searchControllerProvider(widget.apiKey).notifier).searchPlaces(value);
    }
  }

  Future<void> _onSelectSuggestion(Suggestion suggestion) async {
    final selectedPlaceAddress = await ref
        .read(searchControllerProvider(widget.apiKey).notifier)
        .getSelectedPlace(suggestion.placePrediction.placeId);
    _searchController.text =
        suggestion.placePrediction.structuredFormat.mainText.text;
    ref.read(searchControllerProvider(widget.apiKey).notifier).clearSuggestions();
    final state = ref.read(searchControllerProvider(widget.apiKey));
    if (widget.onPlaceSelected != null) {
      widget.onPlaceSelected!(
        selectedPlaceAddress,
        state.location ?? GeoPoint(lat: 0, lng: 0),
      );
    }
    if (mounted) Navigator.pop(context);
  }
}
