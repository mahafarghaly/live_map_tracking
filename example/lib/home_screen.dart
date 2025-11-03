import 'package:flutter/material.dart';
import 'package:live_map_tracking/live_map_tracking.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        endPoint: GeoPoint(lat: 30.55959, lng: 31.70826),
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
                              "packages/live_map_tracking/assets/images/marker.png", location:  GeoPoint(lat: 30.0444, lng: 31.2357),
                        ),
                      ),
                    ),
                  );
                },
                child: Text("Search on map"),
                color: Colors.yellow,
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
