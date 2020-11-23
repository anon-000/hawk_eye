///
///Created By Aurosmruti (aurosmruti@smarttersstudio.com) on 11/23/2020 1:41 PM
///

import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

class LatLngStream {
    final _controller = StreamController<LatLng>();

    Stream<LatLng> get stream => _controller.stream;

    void addLatLng(latLng) => _controller.sink.add(latLng);

    dispose() {
        _controller.close();
    }
}