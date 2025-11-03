class PlaceDetailsResponse {
  final String name;
  final String id;
  final List<String> types;
  final String formattedAddress;
  final List<AddressComponent> addressComponents;
  final Location location;

  PlaceDetailsResponse({
    required this.name,
    required this.id,
    required this.types,
    required this.formattedAddress,
    required this.addressComponents,
    required this.location,
  });

  factory PlaceDetailsResponse.fromJson(Map<String, dynamic> json) {
    return PlaceDetailsResponse(
      name: json['name'] ?? '',
      id: json['id'] ?? '',
      types: (json['types'] as List?)?.map((e) => e.toString()).toList() ?? [],
      formattedAddress: json['formattedAddress'] ?? '',
      addressComponents: (json['addressComponents'] as List?)
          ?.map((e) => AddressComponent.fromJson(e))
          .toList() ??
          [],
      location: Location.fromJson(json['location']),
    );
  }
}

class AddressComponent {
  final String longText;
  final String shortText;
  final List<String> types;

  AddressComponent({
    required this.longText,
    required this.shortText,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longText: json['longText'] ?? '',
      shortText: json['shortText'] ?? '',
      types: (json['types'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
