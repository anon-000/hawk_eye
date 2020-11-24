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


final startPosition = LatLng(18.488213, -69.959186);
final newStartPosition = LatLng(20.286523, 85.834676);

//Run over the polygon position
final polygonz = <LatLng>[
  startPosition,
  LatLng(18.489338, -69.947091),
  LatLng(18.495351, -69.949366),
  LatLng(18.497477, -69.947596),
  LatLng(18.498932, -69.948615),
  LatLng(18.498473, -69.950779),
  LatLng(18.498373, -69.958779),
  LatLng(18.488600, -69.959574),
];



final newRoute = <LatLng>[
  newStartPosition,
  LatLng(20.286523, 85.834676), //nicco park square
  LatLng(20.287503, 85.843098), // bayababa math
  LatLng(20.289506, 85.842723), // rupali square
  LatLng(20.288480, 85.834430), // dm school square
  LatLng(20.292022, 85.833882), // chai biscuit
  LatLng(20.293058, 85.842337), // rd college cha dokan
  LatLng(20.296097, 85.842101), // vani bihar square
  LatLng(20.296832, 85.833282), // acharya bihar square
];

class FlutterMapMarkerAnimationExample extends StatefulWidget {
  @override
  _FlutterMapMarkerAnimationExampleState createState() =>
      _FlutterMapMarkerAnimationExampleState();
}

class _FlutterMapMarkerAnimationExampleState
    extends State<FlutterMapMarkerAnimationExample> {
  double rad = 50.0;
  bool radiusForward = true;
  //Markers collection, proper way
  final Map<MarkerId, Marker> _markers = Map<MarkerId, Marker>();

  MarkerId sourceId = MarkerId("SourcePin");

  LatLngInterpolationStream _latLngStream = LatLngInterpolationStream(
    movementDuration: Duration(milliseconds: 2000),
  );

  StreamSubscription<LatLngDelta> subscription;

  final Completer<GoogleMapController> _controller = Completer();

   CameraPosition _cameraPosition = CameraPosition(
    target: newStartPosition,
    zoom: 15,
  );

  Future<ui.Image> getImageFromPath() async {
    final imageFile = NetworkImage('https://i.imgur.com/zYmVgq8.png',);
    final Completer<ui.Image> completer = Completer();
    imageFile
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      if (!completer.isCompleted) completer.complete(info.image);
    }));
    return completer.future;
  }

  setMarkers(LatLng latLng, double rotation, double radius) async {
    final Size size = Size(100, 100);
    ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    Canvas canvas = Canvas(pictureRecorder);
//      final double shadowWidth = 15.0;
//      final double borderWidth = 3.0;

//      final double imageOffset = shadowWidth + borderWidth;
    Paint paint = Paint()..color = radiusForward ? Colors.yellow.withOpacity(0.5) :Colors.orange.withOpacity(0.5);

    /// Marker
//    final path = Path()
//      ..moveTo(size.width / 2, size.height)
//      ..cubicTo(-12, size.height / 2 + 8, 0, 0, size.width / 2, 0)
//      ..cubicTo(size.width, 0, size.width + 12, size.height / 2 + 8,
//          size.width / 2, size.height);
    final path = Path();

    /// yellow circle
    canvas.drawOval(
      Rect.fromLTWH(0, 0, size.width + radius, size.height+ radius),
      paint,
    );
    canvas.drawShadow(path, Colors.grey, 4, true);

    /// marker red
//    paint = Paint()..color = radiusForward? Colors.orange : Colors.yellow;
//    path
//      ..moveTo(size.width / 2 + radius/2, size.height + radius/2)
//      ..lineTo(size.width / 4 + 10 + radius/2, size.height+ radius/2)
//      ..lineTo(size.width/4+ radius/2, size.height - 10+ radius/2)
//      ..lineTo(size.width/4+ radius/2, size.height/2+20+ radius/2)
//      ..lineTo(radius/2, size.height/2+20+ radius/2)
//      ..lineTo(size.width/4+ radius/2, size.height/2-20+ radius/2)
//      ..lineTo(size.width/4+ radius/2, 10+ radius/2)
//      ..lineTo(size.width/4+10+ radius/2, radius/2)
//      ..lineTo(3*(size.width)/4 - 10 + radius/2, 0 + radius/2)
//      ..lineTo(3*(size.width)/4 + radius/2, 10 + radius/2)
//      ..lineTo(3*(size.width)/4 + radius/2, size.height/2-20 + radius/2)
//      ..lineTo(size.width + radius/2, size.height/2+20 + radius/2)
//      ..lineTo(3*(size.width)/4 + radius/2, size.height/2+20 + radius/2)
//      ..lineTo(3*(size.width)/4 + radius/2, size.height - 10 + radius/2)
//      ..lineTo(3*(size.width)/4 - 10 + radius/2, size.height + radius/2)
//      ..lineTo(size.width / 2 + radius/2, size.height + radius/2);
//
//    canvas.drawShadow(path, Colors.grey, 4, true);
//    canvas.drawPath(path, paint);

    /// to draw image marker from network image
    Rect rect = Rect.fromLTWH(radius/2, radius/2, size.width, size.height);
    ui.Image image = await getImageFromPath();
    paintImage(canvas: canvas, image: image, rect: rect, fit: BoxFit.contain,);

    /// Convert canvas to image
    ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt() + radius.toInt(), size.height.toInt() + radius.toInt());

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
      _cameraPosition = CameraPosition(
        target: latLng,
        zoom: 15
      );
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

      if(rad > 250.0){
        radiusForward = false;
        rad -= 3;
      }else if(rad < 50.0){
        radiusForward = true;
        rad = 50.0;
      }else{
        if(radiusForward){
          rad += 3;
        }else{
          rad -= 3;
        }
      }
      print('radius : $rad');
      setMarkers(delta.from, delta.rotation, rad);

      if (newRoute.isNotEmpty) {
        //Pop the last position
        _latLngStream.addLatLng(newRoute.removeLast());
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
              initialCameraPosition: _cameraPosition,

              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);

                setMarkers(newStartPosition, 0 , rad);

                _latLngStream.addLatLng(newStartPosition);
                //Add second position to start position over
                Future.delayed(const Duration(milliseconds: 3000), () {
                  _latLngStream.addLatLng(newRoute.removeLast());
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
                          newRoute.addAll(<LatLng>[
                            newStartPosition,
                            LatLng(20.286523, 85.834676), //nicco park square
                            LatLng(20.287503, 85.843098), // bayababa math
                            LatLng(20.289506, 85.842723), // rupali square
                            LatLng(20.288480, 85.834430), // dm school square
                            LatLng(20.292022, 85.833882), // chai biscuit
                            LatLng(20.293058, 85.842337), // rd college cha dokan
                            LatLng(20.296097, 85.842101), // vani bihar square
                            LatLng(20.296832, 85.833282), // acharya bihar square
                          ]);
                        });
                        print(newRoute.toString());
                        _latLngStream.addLatLng(newRoute.removeLast());
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
