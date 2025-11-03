

import '../data_source/api_data_source.dart';
import '../models/places_autocomplete.dart';
import '../models/places_details.dart';

class PlacesRepository {
  final ApiDataSource remoteDataSource;

  PlacesRepository(this.remoteDataSource);

  Future<PlaceAutocompleteResponse> searchPlaces(String query) =>
      remoteDataSource.searchPlaces(query);

  Future<PlaceDetailsResponse> getPlaceDetails(String placeId) =>
      remoteDataSource.getPlaceDetails(placeId);
}
