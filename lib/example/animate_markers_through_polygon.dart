///
///Created By Aurosmruti (aurosmruti@smarttersstudio.com) on 11/23/2020 2:16 PM
///


import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hawk_eye/data_model/lat_lng_delta.dart';
import 'package:hawk_eye/marker_animation_utils/lat_lng_interpolation.dart';

final startPosition = LatLng(18.488213, -69.959186);

//Run over the polygon position
final polygon = <LatLng>[
    startPosition,
    LatLng(18.489338, -69.947091),
    LatLng(18.495351, -69.949366),
    LatLng(18.497477, -69.947596),
    LatLng(18.498932, -69.948615),
    LatLng(18.498373, -69.958779),
    LatLng(18.488600, -69.959574),
];

class FlutterMapMarkerAnimationExample extends StatefulWidget {
    @override
    _FlutterMapMarkerAnimationExampleState createState() =>
        _FlutterMapMarkerAnimationExampleState();
}

class _FlutterMapMarkerAnimationExampleState
    extends State<FlutterMapMarkerAnimationExample> {
    //Markers collection, proper way
    final Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();

    MarkerId sourceId = MarkerId("SourcePin");

    LatLngInterpolationStream _latLngStream = LatLngInterpolationStream(
        movementDuration: Duration(milliseconds: 2000),
    );

    StreamSubscription<LatLngDelta> subscription;

    final Completer<GoogleMapController> _controller = Completer();

    final CameraPosition _kSantoDomingo = CameraPosition(
        target: startPosition,
        zoom: 15,
    );

    @override
    void initState() {
        subscription =
            _latLngStream.getLatLngInterpolation().listen((LatLngDelta delta) {
                LatLng from = delta.from;
                print("To: -> ${from.toJson()}");
                LatLng to = delta.to;
                print("From: -> ${to.toJson()}");
                double angle = delta.rotation;
                print("Angle: -> $angle");
                //Update the animated marker
                setState(() {
                    Marker sourceMarker = Marker(
                        markerId: sourceId,
                        rotation: delta.rotation,
                        position: LatLng(
                            delta.from.latitude,
                            delta.from.longitude,
                        ),
                    );
                    _markers[sourceId] = sourceMarker;
                });

                if (polygon.isNotEmpty) {
                    //Pop the last position
                    _latLngStream.addLatLng(polygon.removeLast());
                }
            });

        super.initState();
    }

    @override
    Widget build(BuildContext context) {
        return Scaffold(
            body: SafeArea(
                child: Stack(
                  children: [
                    GoogleMap(
                        mapType: MapType.normal,
                        markers: Set<Marker>.of(_markers.values),
                        initialCameraPosition: _kSantoDomingo,
                        onMapCreated: (GoogleMapController controller) {
                            _controller.complete(controller);

                            setState(() {
                                Marker sourceMarker = Marker(
                                    markerId: sourceId,
                                    position: startPosition,
                                );
                                _markers[sourceId] = sourceMarker;
                            });

                            _latLngStream.addLatLng(startPosition);
                            //Add second position to start position over
                            Future.delayed(const Duration(milliseconds: 3000), () {
                                _latLngStream.addLatLng(polygon.removeLast());
                            });
                        },
                    ),
                      Positioned(
                          bottom: 20,
                          right: 0,
                          left: 0,
                          child: Center(
                            child: Card(
                                color: Colors.white.withOpacity(0.9),
                              elevation: 0.4,
                              child: FlatButton(
                                  child: Text("Reset"),
                              onPressed: (){
                                  setState(() {
                                      polygon.addAll(<LatLng>[
                                          startPosition,
                                          LatLng(18.489338, -69.947091),
                                          LatLng(18.495351, -69.949366),
                                          LatLng(18.497477, -69.947596),
                                          LatLng(18.498932, -69.948615),
                                          LatLng(18.498373, -69.958779),
                                          LatLng(18.488600, -69.959574),
                                      ]);
                                  });
                                  print(polygon.toString());
                                  _latLngStream.addLatLng(polygon.removeLast());

                              },
                      ),
                            ),
                          ))
                  ],
                ),
            ),
        );
    }

    @override
    void dispose() {
        subscription.cancel();
        super.dispose();
    }
}