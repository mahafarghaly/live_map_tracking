import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:live_map_tracking/src/data/models/places_autocomplete.dart';

class SearchState {
  final List<Suggestion> suggestions;
  final bool loading;
  final LatLng? origin;
  final LatLng? destination;

  const SearchState({
    this.suggestions = const [],
    this.loading = false,
    this.origin,
    this.destination,
  });

  SearchState copyWith({
    List<Suggestion>? suggestions,
    bool? loading,
    LatLng? origin,
    LatLng? destination,
  }) {
    return SearchState(
      suggestions: suggestions ?? this.suggestions,
      loading: loading ?? this.loading,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
    );
  }
}