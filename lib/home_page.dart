import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hawk_eye/example/animate_markers_through_polygon.dart';
import 'package:hawk_eye/example/listen_locations_updates.dart';

///
///Created By Aurosmruti (aurosmruti@smarttersstudio.com) on 11/23/2020 1:00 PM
///

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Home Page"),
            Image.asset('assets/car_png.png', height: 45,),
            RawMaterialButton(
              fillColor: Colors.yellow,
              child: Text('polygon map page'),
                onPressed: (){
              Get.to(FlutterMapMarkerAnimationExample());
            }),
            RawMaterialButton(
              child: Text("real time"),
                fillColor: Colors.red,
                onPressed:(){
              Get.to(FlutterMapMarkerAnimationRealTimeExample());
            })
          ],
        ),
      ),
    );
  }
}
