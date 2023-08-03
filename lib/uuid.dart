import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';

class login extends StatefulWidget {
  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {
  Future createuuid() async {
    try {
      final response =  await http.get(Uri.parse('https://original-google.onrender.com/createuuid'));
      if (response.statusCode == 200) {
       // print(response.body);
        return response.body;
      }
    } catch (e) {
      print('error');
    }
    return 'error';
}
  Future fetchtoken(uuid) async {
    try {
      print('running');
      final response =  await http.get(Uri.parse('https://original-google.onrender.com/fetchtoken?uuid='+uuid));
      if (response.statusCode == 200) {
       // print(response.body);
        return response.body;
      }
    } catch (e) {
      print('error');
    }
    return 'error';
}
  Future<Map<String, dynamic>> googledata(String access_token) async {
    try {
      print('running');
      final response =
          await http.get(Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo?access_token=' + access_token));
      if (response.statusCode == 200) {
        // Parse the response JSON and return the data as a map.
        Map<String, dynamic> responseData = json.decode(response.body);
        return responseData;
      }
    } catch (e) {
      print('error');
    }
    return {};
  }
  
  void logi(BuildContext context) async {
      if (await _requestPermission()) {
      var appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
      var box = await Hive.openBox('myBox');
     // await Hive.deleteBoxFromDisk('myBox');
/* ALGORITHM
      if(access_token)call google api 
      else call create and extract uuid {launch url with uuid}
      and fetch for access_token with uuid
*/
//1st step 
  var accessToken = box.get('access_token');
  if (accessToken != null) {
      print('Access Token Found: $accessToken');
       Future<Map<String, dynamic>> responseData  = googledata(accessToken);
       responseData.then((data) {
    // Inside this callback, `data` will be the resolved Map<String, dynamic>.
    print('Name: ${data['name']}');
    print('Email: ${data['email']}');
 ScaffoldMessenger.of(context).showSnackBar(
     SnackBar(
  content: Row(
    children: [
      Expanded(
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(data['picture']), // Replace with the actual image URL
            ),
            SizedBox(width: 8),
           Text(
              '${data['name']}',
              style: TextStyle(fontSize: 16),
            ),
            /*Text(
              'Access Token Found: $accessToken',
              style: TextStyle(fontSize: 16),
            ),*/
          ],
        ),
      ),
    ],
  ),
  duration: Duration(seconds: 2), // Adjust the duration as you like
),

    );  });
  } else {
    print('running else ');
//2nd step
     String uuidResponse = await createuuid();
    if(uuidResponse != null){
      var url = 'https://ss0809.github.io/Dark_Matter?uuid='+uuidResponse.replaceAll('"', '');
     await launch(url , forceSafariVC: false, forceWebView: false);
    }
          print(fetchtoken(uuidResponse.replaceAll('"', ''))); //  Instance of 'Future<dynamic>'
    while(fetchtoken(uuidResponse.replaceAll('"', ''))!='null'){
//3rd step
     String Tokenresponse = await fetchtoken(uuidResponse.replaceAll('"', ''));//"h"
     if(Tokenresponse != 'null'){
     Tokenresponse = Tokenresponse.replaceAll('"', '');
     box.put('access_token', Tokenresponse);
     print(box.get('access_token'));
     break;
     } await Future.delayed(Duration(seconds: 2));
     }
  }
    }
  }
  Future<bool> _requestPermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        children: [
          ElevatedButton(
            onPressed: () {
              logi(context);
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              backgroundColor: const Color(0xFF009688),
            ),
            child: Text(
              'Login with Google',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFFffffff),
                fontWeight: FontWeight.w200,
                fontFamily: "Merriweather",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
