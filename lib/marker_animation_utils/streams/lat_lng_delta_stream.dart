///
///Created By Aurosmruti (aurosmruti@smarttersstudio.com) on 11/23/2020 1:40 PM
///

import 'dart:async';
import 'package:hawk_eye/data_model/lat_lng_delta.dart';


class LatLngDeltaStream {
    final _controller = StreamController<LatLngDelta>();

    Stream<LatLngDelta> get stream => _controller.stream;

    void addLatLng(LatLngDelta delta) => _controller.sink.add(delta);

    dispose() {
        _controller.close();
    }
}