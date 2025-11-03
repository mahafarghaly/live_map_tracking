import 'package:flutter_riverpod/legacy.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:live_map_tracking/src/core/network/dio_factory.dart';
import '../../data/data_source/api_data_source.dart';
import '../../data/models/search_state.dart';


final searchControllerProvider =
StateNotifierProvider<SearchController, SearchState>(
        (ref) => SearchController());


class SearchController extends StateNotifier<SearchState> {
  final ApiDataSource _remote = ApiDataSource(DioClient());

  SearchController() : super(const SearchState());

  Future<void> searchPlaces(String input) async {
    if (input.isEmpty) return;
    state = state.copyWith(loading: true);
    final response = await _remote.searchPlaces(input);
    state = state.copyWith(suggestions: response.suggestions, loading: false);
  }

  Future<void> selectPlace(String placeId, {required bool isOrigin}) async {
    final details = await _remote.getPlaceDetails(placeId);
    final loc = LatLng(details.location.latitude, details.location.longitude);

    if (isOrigin) {
      state = state.copyWith(origin: loc);
    } else {
      state = state.copyWith(destination: loc);
    }
  }

  void clearSuggestions() => state = state.copyWith(suggestions: []);
  void reset() {
    state = const SearchState();
  }

}
