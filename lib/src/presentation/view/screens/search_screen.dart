import 'package:flutter/material.dart';
import 'package:live_map_tracking/src/presentation/controllers/search_controller.dart';
import 'package:live_map_tracking/src/presentation/view/widgets/custom_search_bar.dart';
import '../../../data/models/places_autocomplete.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class SearchPlacesScreen extends ConsumerStatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  ConsumerState<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends ConsumerState<SearchPlacesScreen> {
  final _originController = TextEditingController();
  final _destController = TextEditingController();

  bool _isOriginActive = true;

  void _onTextChange(String value) {
    if (value.isEmpty) {
      ref.read(searchControllerProvider.notifier).clearSuggestions();
    } else {
    ref.read(searchControllerProvider.notifier).searchPlaces(value);
    }
  }

  Future<void> _onSelectSuggestion(Suggestion suggestion) async {
    await ref.read(searchControllerProvider.notifier).selectPlace(
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
  ref.read(searchControllerProvider.notifier).clearSuggestions();

    final state = ref.read(searchControllerProvider);
    if (state.destination != null) {
      Navigator.pop(context, {
        'origin': state.origin,
        'destination': state.destination,
      });
      ref.read(searchControllerProvider.notifier).reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Search Route")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CustomSearchBar(controller: _originController,hintText: 'From (optional)',
                  icon:Icons.trip_origin ,
                    onTextChange: (v) {
                      setState(() => _isOriginActive = true);
                      _onTextChange(v);
                    },),
                const SizedBox(height: 16),
               CustomSearchBar(controller: _destController,hintText: 'To (required)',
                   icon:Icons.location_on ,onTextChange:(v) {
                   setState(() => _isOriginActive = false);
                   _onTextChange(v);
                 },)
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
                  subtitle:
                  Text(s.placePrediction.structuredFormat.secondaryText.text),
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
