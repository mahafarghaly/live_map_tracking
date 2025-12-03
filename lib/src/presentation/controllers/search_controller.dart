import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/live_map_tracking.dart';
import 'package:live_map_tracking/src/core/network/dio_factory.dart';
import 'package:live_map_tracking/src/data/repository/places_repository.dart';
import '../../data/data_source/api_data_source.dart';
import '../../data/models/search_state.dart';

final searchControllerProvider = StateNotifierProvider.family<
    SearchController,
    SearchState,
    String>(
      (ref, apiKey) => SearchController(apiKey: apiKey),
);

class SearchController extends StateNotifier<SearchState> {
  late final PlacesRepository _placesRepository;
  final String apiKey;
  SearchController({required this.apiKey})
      : super(const SearchState()) {
    _placesRepository = PlacesRepository(
      ApiDataSource(DioFactory(apiKey)),
    );
  }
  Future<void> searchPlaces(String input) async {
    if (input.isEmpty) return;
    state = state.copyWith(loading: true);
    final response = await _placesRepository.searchPlaces(input);
    state = state.copyWith(suggestions: response.suggestions, loading: false);
  }

  Future<void> selectPlaceRoute(
    String placeId, {
    required bool isOrigin,
  }) async {
    final details = await _placesRepository.getPlaceDetails(placeId);
    final loc = LatLng(details.location.latitude, details.location.longitude);

    if (isOrigin) {
      state = state.copyWith(origin: loc);
    } else {
      state = state.copyWith(destination: loc);
    }
  }

  Future<String> getSelectedPlace(String placeId) async {
    final details = await _placesRepository.getPlaceDetails(placeId);
    final loc = GeoPoint(
      lat: details.location.latitude,
      lng: details.location.longitude,
    );
    state = state.copyWith(location: loc);
    return details.formattedAddress;
  }

  void clearSuggestions() => state = state.copyWith(suggestions: []);

  void reset() {
    state = const SearchState();
  }

  Future<List<LatLng>> drawRoutePolyline(
    String apikey,
    LatLng start,
    LatLng end,
  ) async {
    PolylinePoints polylinePoints = PolylinePoints(apiKey: apikey);

    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      final route = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
      return route;
    } else {
      print('Polyline error: ${result.errorMessage}');
      return [];
    }
  }
}
