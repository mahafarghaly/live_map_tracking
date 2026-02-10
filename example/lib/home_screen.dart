import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:live_map_tracking/live_map_tracking.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String apiKey = "AIzaSyAs8BLH_1qb-AMD63_Pf25ffSFYuGOt1Zw";
    final List<Map<String, dynamic>> rawPoints = [
      {"lat": 30.55549, "lng": 31.70253},
      {"lat": 30.55441, "lng": 31.7031},
      {"lat": 30.55441, "lng": 31.7031},
    ];
    final tripPoints = rawPoints.map((map) => GeoPoint.fromMap(map)).toList();
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () {
                  navigationTo(
                    context,
                    Scaffold(
                      body: StaticRoute(
                        directionList: tripPoints,
                        statIcon:
                            "packages/live_map_tracking/assets/images/marker_green.png",
                        endIcon:
                            "packages/live_map_tracking/assets/images/marker.png",
                      ),
                    ),
                  );
                },
                child: Text("Static Route"),
                color: Colors.yellow,
              ),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: () {
                  navigationTo(
                    context,
                    Scaffold(
                      body: LiveTracking(
                        stream: fakeLocationStream().asBroadcastStream(),
                        startIcon:
                            "packages/live_map_tracking/assets/images/marker_green.png",
                        endIcon:
                            "packages/live_map_tracking/assets/images/marker.png",
                        movingIcon:
                            "packages/live_map_tracking/assets/images/car.png",
                        endPoint: GeoPoint(
                          lat: 30.55959,
                          lng: 31.70826,
                        ), //31.216021733655023, 29.940172853316405
                        polylineLiveColor: Colors.red,
                        polyLineWidth: 10,
                        polyLineLiveWidth: 5,
                        apikey: apiKey,
                      ),
                    ),
                  );
                },
                child: Text("Live Tracking"),
                color: Colors.yellow,
              ),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: () {
                  navigationTo(
                    context,
                    Scaffold(
                      body: Scaffold(
                        body: SearchOnMap(
                          statIcon:
                              "packages/live_map_tracking/assets/images/marker_green.png",
                          endIcon:
                              "packages/live_map_tracking/assets/images/marker.png",
                          currentLocation: GeoPoint(lat: 30.0444, lng: 31.2357),
                          onPlaceSelected: (address, location) {
                            print("@@Selected place: $address");
                            print("@@LatLng: ${location.lat}, ${location.lng}");
                          },
                          pinIcon:
                              "packages/live_map_tracking/assets/images/marker_blue.png",
                          enableRoute: true,
                          apiKey: apiKey,
                          initialCameraPosition: GeoPoint(
                            lat: 39.8283,
                            lng: -98.5795,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: Text("Search on map"),
                color: Colors.yellow,
              ),
              SizedBox(height: 20),
              MaterialButton(
                onPressed: () {
                  navigationTo(
                    context,
                    Scaffold(
                      body: TrackingZone(
                        apiKey: apiKey,
                        destinationLocation: GeoPoint(
                          lat: 37.411,
                          lng: -122.071,
                        ),
                        sourceIcon:
                            "packages/live_map_tracking/assets/images/source_marker.png",
                        destinationIcon:
                            "packages/live_map_tracking/assets/images/destination_marker.png",
                        locationStream: Geolocator.getPositionStream(
                          locationSettings: const LocationSettings(
                            accuracy: LocationAccuracy.high,
                            distanceFilter: 100,
                          ),
                        ),
                        checkPermission: () async {
                          LocationPermission permission =
                              await Geolocator.checkPermission();
                          if (permission == LocationPermission.denied) {
                            await Geolocator.requestPermission();
                          }
                          if (permission == LocationPermission.deniedForever) {
                            throw Exception(
                              'Location permission permanently denied',
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
                color: Colors.yellow,
                child: Text("Tracking Zone"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Stream<GeoPoint> fakeLocationStream() async* {
    double lat = 30.55549;
    double lng = 31.70253;

    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(seconds: 1));
      yield GeoPoint(lat: lat + i * 0.0002, lng: lng + i * 0.0003);
    }
    //Start = LatLng(30.55549, 31.70253)
    //
    // End = LatLng(30.55929, 31.70823)
  }

  static void navigationTo(BuildContext context, Widget widget) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => widget));
  }
}
