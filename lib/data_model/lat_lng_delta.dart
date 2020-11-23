import 'package:google_maps_flutter/google_maps_flutter.dart' show LatLng;

///
///Created By Aurosmruti (aurosmruti@smarttersstudio.com) on 11/23/2020 1:38 PM
///

class LatLngDelta {
    final LatLng from;
    final LatLng to;
    double rotation;

    LatLngDelta({this.from, this.to, this.rotation});
}