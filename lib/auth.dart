import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_machine_test/main.dart';
import 'package:flutter_machine_test/map.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String? token;
List geoLat = [], geoLon = [], contractor = [];
final Set<Marker> markers = {};

class Auth {
  Future logIn(var email, var password, BuildContext ctx) async {
    final response = await http.post(
        Uri.parse(
            'https://api.terrablender.com/terraprocess/api/v2/open/login'),
        body: jsonEncode({"username": email, "passcode": password}));
    var responseData = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print('Successful   ${responseData}');
      showDialog(
          barrierDismissible: false,
          context: ctx,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              backgroundColor: Colors.white,
              content: const Text('Logged In Successfully'),
              actions: [
                MaterialButton(
                  color: Colors.indigo.shade400,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  onPressed: () {
                    Navigator.pushReplacement(context,
                        CupertinoPageRoute(builder: (context) => MapScreen()));
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          });
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setString('token', responseData['session_token']);
    } else {
      var snackBar = const SnackBar(content: Text('Login unsuccessful'));
      ScaffoldMessenger.of(ctx).showSnackBar(snackBar);

      print('Failed');
    }
  }

  Future getLocation() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    token = pref.getString('token');

    try {
      var url = Uri.parse(
          'https://api.terrablender.com/terraprocess/api/v2/sys/data/lattest_excavation?geo=true');
      var response =
          await http.get(url, headers: {'Authentication': 'Bearer $token'});
      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        for (int i = 0; i < responseData.length; i++) {
          var fin = jsonDecode(responseData[i]['geojson']);
          geoLat.add(fin['geometry']['coordinates'][0]);
          geoLon.add(fin['geometry']['coordinates'][1]);
          contractor.add(fin['properties']['contractor'] ?? ' ');
          markers.add(
            Marker(
                markerId: const MarkerId('Contractor'),
                position: LatLng(geoLat[i], geoLon[i]),
                infoWindow: InfoWindow(
                    title: contractor[i],
                    snippet: '${geoLat[i]}, ${geoLon[i]}')),
          );
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
