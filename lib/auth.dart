import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_machine_test/main.dart';
import 'package:flutter_machine_test/map.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

String? token, contractor;
double? geoLat, geoLon;

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
                    Navigator.pushReplacement(context, CupertinoPageRoute(builder: (context)=>MapScreen()));
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

      var fin = jsonDecode(responseData[0]['geojson']);
      
      if (response.statusCode == 200) {
        geoLat = fin['geometry']['coordinates'][0];
      geoLon = fin['geometry']['coordinates'][1];
      contractor = fin['properties']['contractor'];
        print("SUCCESSS   $fin ");
      }
    } catch (e) {
      print(e);
    }
  }
}
