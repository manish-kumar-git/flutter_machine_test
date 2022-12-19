import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_machine_test/auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Set<Marker> _markers = Set();
  CameraPosition _initialPosition =
      CameraPosition(target: LatLng(20.5937, 78.9629), zoom: 10);
  Completer<GoogleMapController> _controller = Completer();

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
     Auth().getLocation();
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
        body: Stack(
          children: <Widget>[
            GoogleMap(
                markers: _markers,
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
                   
                    _goToNewYork();
                  },
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Color.fromARGB(209, 137, 64, 233),
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

  Future<void> _goToNewYork() async {
    double? lat = geoLat;
    double? long = geoLon;
    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(LatLng(lat!, long!), 10));
    setState(() {
      _markers.add(
        Marker(
          markerId: MarkerId('newyork'),
          position: LatLng(lat, long),
          infoWindow: InfoWindow(title: contractor,snippet: '$lat, $long')
        ),
      );
    });
  }
}
