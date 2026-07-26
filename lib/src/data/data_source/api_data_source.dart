import '../../core/network/api_constants.dart';
import '../../core/network/dio_factory.dart';
import '../models/places_autocomplete.dart';
import '../models/places_details.dart';

class ApiDataSource {
  final DioFactory dioFactory;

  ApiDataSource(this.dioFactory);

  Future<PlaceAutocompleteResponse> searchPlaces(String input) async {
    if (input.isEmpty) {
      return PlaceAutocompleteResponse(suggestions: []);
    }
    try {
      final response = await dioFactory.post(
        ApiConstants.autocomplete,
        data: {
          "input": input,
          "includedPrimaryTypes": [
            "street_address",
            "premise",
            "subpremise",
            "route",
          ],
        },
      );
      if (response.data == null ||
          response.data is! Map<String, dynamic> ||
          response.data['suggestions'] == null) {
        return PlaceAutocompleteResponse(suggestions: []);
      }

      return PlaceAutocompleteResponse.fromJson(response.data);
    } catch (e) {
      print("Place not found...$e");
      return PlaceAutocompleteResponse(suggestions: []);
    }
  }

  Future<PlaceDetailsResponse> getPlaceDetails(String placeId) async {
    final response = await dioFactory.get(
      "${ApiConstants.placeDetails}$placeId",
    );
    return PlaceDetailsResponse.fromJson(response.data);
  }
}
