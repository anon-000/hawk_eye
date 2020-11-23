///
///Created By Aurosmruti (aurosmruti@smarttersstudio.com) on 11/23/2020 2:16 PM
///

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hawk_eye/data_model/lat_lng_delta.dart';
import 'package:hawk_eye/marker_animation_utils/lat_lng_interpolation.dart';
import 'dart:ui' as ui;

import 'package:hawk_eye/marker_animation_utils/utils/math_util.dart';

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

  Future<ui.Image> getImageFromPath() async {
    final imageFile = NetworkImage('');
    final Completer<ui.Image> completer = Completer();
    imageFile
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      if (!completer.isCompleted) completer.complete(info.image);
    }));
    return completer.future;
  }

  setMarkers(LatLng latLng, double rotation) async {
    final Size size = Size(100, 100);
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
//      final double shadowWidth = 15.0;
//      final double borderWidth = 3.0;

//      final double imageOffset = shadowWidth + borderWidth;
    Paint paint = Paint()..color = Colors.yellow.withOpacity(0.5);

    /// Marker
//    final path = Path()
//      ..moveTo(size.width / 2, size.height)
//      ..cubicTo(-12, size.height / 2 + 8, 0, 0, size.width / 2, 0)
//      ..cubicTo(size.width, 0, size.width + 12, size.height / 2 + 8,
//          size.width / 2, size.height);
    final path = Path();

    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width + 200, size.height+ 200),
      paint,
    );

    paint = Paint()..color = Colors.red;
    path
      ..moveTo(size.width / 2 + 100, size.height + 100)
      ..lineTo(size.width / 4 + 10 + 100, size.height+ 100)
      ..lineTo(size.width/4+ 100, size.height - 10+ 100)
      ..lineTo(size.width/4+ 100, size.height/2+20+ 100)
      ..lineTo(100.0, size.height/2+20+ 100)
      ..lineTo(size.width/4+ 100, size.height/2-20+ 100)
      ..lineTo(size.width/4+ 100, 10+ 100.0)
      ..lineTo(size.width/4+10+ 100, 0 + 100.0)
      ..lineTo(3*(size.width)/4 - 10 + 100.0, 0 + 100.0)
      ..lineTo(3*(size.width)/4 + 100.0, 10 + 100.0)
      ..lineTo(3*(size.width)/4 + 100.0, size.height/2-20 + 100.0)
      ..lineTo(size.width + 100.0, size.height/2+20 + 100.0)
      ..lineTo(3*(size.width)/4 + 100.0, size.height/2+20 + 100.0)
      ..lineTo(3*(size.width)/4 + 100.0, size.height - 10 + 100.0)
      ..lineTo(3*(size.width)/4 - 10 + 100.0, size.height + 100.0)
      ..lineTo(size.width / 2 + 100.0, size.height + 100.0);

    canvas.drawShadow(path, Colors.grey, 4, true);
    canvas.drawPath(path, paint);

    /// Convert canvas to image
    ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt() + 200, size.height.toInt() + 200);

    /// Convert image to bytes
    ByteData byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    Uint8List uint8List = byteData.buffer.asUint8List();

    setState(() {
      _markers[sourceId] = Marker(
          markerId: sourceId,
          visible: true,
          icon: BitmapDescriptor.fromBytes(uint8List),
          position: latLng,
          rotation: rotation,
          anchor: Offset(0.5, 0.5),
          infoWindow: InfoWindow(title: 'car'));
    });
//    pictureRecorder = ui.PictureRecorder();
//    canvas = Canvas(pictureRecorder);
//    canvas.drawShadow(path, Colors.grey, 4, true);
//    canvas.drawPath(path, paint);
//
//    /// Oval for the image
//    Rect oval =
//        Rect.fromLTWH(25, 10.5, size.width - (25 * 2), size.height - (25 * 2));
//
//    /// Add path for oval image
//    canvas.clipPath(Path()..addOval(oval));
//
//    ui.Image image = await getImageFromPath();
//    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);
//
//    /// Convert canvas to image
//    markerAsImage = await pictureRecorder
//        .endRecording()
//        .toImage(size.width.toInt(), size.height.toInt());
//
//    /// Convert image to bytes
//    byteData = await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
//    uint8List = byteData.buffer.asUint8List();
//    _markers[sourceId] = Marker(
//        markerId: sourceId,
//        visible: true,
//        icon: BitmapDescriptor.fromBytes(uint8List),
//        position: latLng,
//        rotation: rotation,
//        infoWindow: InfoWindow(title: 'car'));
  }

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
      setMarkers(delta.from, delta.rotation);
//      setState(() {
//        Marker sourceMarker = Marker(
//          markerId: sourceId,
//          rotation: delta.rotation,
//          position: LatLng(
//            delta.from.latitude,
//            delta.from.longitude,
//          ),
//        );
//        _markers[sourceId] = sourceMarker;
//      });

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

                setMarkers(startPosition, 0);

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
                      onPressed: () {
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
