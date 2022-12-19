import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_machine_test/auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(73.8215083, 18.6378567), zoom: 10);
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  bool loading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Auth().getLocation();
    Future.delayed(Duration(seconds: 2), () {
      loading = false;
    setState(() {
      
    });
    });
  }

  MapType _currentMapType = MapType.normal;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to Google Map'),
          centerTitle: true,
          elevation: 10,
          backgroundColor: const Color.fromRGBO(143, 148, 251, .6),
        ),
        body: loading?const Center(child: CupertinoActivityIndicator()):
        Stack(
          children: <Widget>[
            GoogleMap(
                markers: markers,
                mapType: _currentMapType,
                onMapCreated: _onMapCreated,
                initialCameraPosition: _initialPosition),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.topRight,
                child: FloatingActionButton(
                  onPressed: _onMapTypeButtonPressed,
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: const Color.fromRGBO(143, 148, 251, .6),
                  child: const Icon(Icons.map, size: 30.0),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: FloatingActionButton(
                  onPressed: () {
                    setState(() {});
                    _goTo();
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: const Color.fromARGB(209, 137, 64, 233),
                  child: const Icon(Icons.gps_not_fixed_outlined, size: 30.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  Future<void> _goTo() async {
    double? lat = geoLat[0];
    double? long = geoLon[0];
    GoogleMapController controller = await _controller.future;
    controller
        .animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat!, long!), 0));
  }
}
