import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:live_map_tracking/src/data/models/places_autocomplete.dart';

class SearchState {
  final List<Suggestion> suggestions;
  final bool loading;
  final LatLng? origin;
  final LatLng? destination;
  final GeoPoint? location;
  const SearchState({
    this.suggestions = const [],
    this.loading = false,
    this.origin,
    this.destination,
    this.location
  });

  SearchState copyWith({
    List<Suggestion>? suggestions,
    bool? loading,
    LatLng? origin,
    LatLng? destination,
  GeoPoint? location,
  }) {
    return SearchState(
      suggestions: suggestions ?? this.suggestions,
      loading: loading ?? this.loading,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      location: location??this.location
    );
  }
}