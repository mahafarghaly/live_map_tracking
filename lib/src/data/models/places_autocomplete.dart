class PlaceAutocompleteResponse {
  final List<Suggestion> suggestions;

  PlaceAutocompleteResponse({required this.suggestions});

  factory PlaceAutocompleteResponse.fromJson(Map<String, dynamic> json) {
    return PlaceAutocompleteResponse(
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((e) => Suggestion.fromJson(e))
          .toList() ??
          [],
    );
  }
}

class Suggestion {
  final PlacePrediction placePrediction;

  Suggestion({required this.placePrediction});

  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      placePrediction: PlacePrediction.fromJson(json['placePrediction']),
    );
  }
}

class PlacePrediction {
  final String place;
  final String placeId;
  final TextData text;
  final StructuredFormat structuredFormat;
  final List<String> types;

  PlacePrediction({
    required this.place,
    required this.placeId,
    required this.text,
    required this.structuredFormat,
    required this.types,
  });

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    return PlacePrediction(
      place: json['place'] ?? '',
      placeId: json['placeId'] ?? '',
      text: TextData.fromJson(json['text']),
      structuredFormat: StructuredFormat.fromJson(json['structuredFormat']),
      types: (json['types'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class TextData {
  final String text;

  TextData({required this.text});

  factory TextData.fromJson(Map<String, dynamic> json) {
    return TextData(text: json['text'] ?? '');
  }
}

class StructuredFormat {
  final MainText mainText;
  final SecondaryText secondaryText;

  StructuredFormat({required this.mainText, required this.secondaryText});

  factory StructuredFormat.fromJson(Map<String, dynamic> json) {
    return StructuredFormat(
      mainText: MainText.fromJson(json['mainText']),
      secondaryText: SecondaryText.fromJson(json['secondaryText']),
    );
  }
}

class MainText {
  final String text;

  MainText({required this.text});

  factory MainText.fromJson(Map<String, dynamic> json) {
    return MainText(text: json['text'] ?? '');
  }
}

class SecondaryText {
  final String text;

  SecondaryText({required this.text});

  factory SecondaryText.fromJson(Map<String, dynamic> json) {
    return SecondaryText(text: json['text'] ?? '');
  }
}
