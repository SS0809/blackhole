import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart'; // For permission handling
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

List<String> feedItems = [];
List<String> feedId = [];

class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color backgroundColor;
  final IconData icon;

  const CustomFloatingActionButton({
    required this.onPressed,
    required this.backgroundColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: CircleBorder(),
      elevation: 4.0,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: backgroundColor,
        child: Icon(icon),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blackhole',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Blackhole Downloader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    var driveurl;
  String serverurl = 'original-google.onrender.com';
  Color fabColor = Colors.blue;
  Map<String, bool> buttonStatusMap = {};
  Timer? periodicTimer; // Timer instance

    void getfiles() async {
    try {
      var uri = Uri.https(serverurl, '/getfiles');
      http.Response response = await http.get(uri);
      if (response.statusCode == 200) {
        debugPrint(response.body.toString());
        feedId.clear();
        feedItems.clear();
        List<dynamic> jsonList = json.decode(response.body.toString());
        for (var item in jsonList) {
          if (item['mimeType'] != 'application/vnd.google-apps.folder') {
            String name = item['name'];
            String id = item['id'];
            feedItems.add('$name'); /*$name - $id*/
            feedId.add('$id');
          }
        }
        print(feedItems);
        setState(() {
          driveurl = response.body.toString();
          buttonStatusMap =
              Map.fromIterable(feedId, key: (id) => id, value: (_) => true);
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void online_test_url() {
    void fetchStatus() async {
      try {
        final response = await http.get(Uri.parse('https://' + serverurl));
        if (response.statusCode == 200) {
          setState(() {
            fabColor = Colors.green;
          });
        } else {
          setState(() {
            fabColor = Colors.red;
          });
        }
      } catch (e) {
        setState(() {
          fabColor = Colors.red;
        });
      }
    }

    periodicTimer = Timer.periodic(Duration(seconds: 30), (_) {
      fetchStatus();
      print('periodicTimer');
    });
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      String fileUrl = "https://platinumlist.net/guide/wp-content/uploads/2023/03/IMG-worlds-of-adventure.webp"; // Replace with the actual file URL
      _downloadFile(fileUrl);

    });
  }

  Future<void> _downloadFile(String fileUrl) async {
    Dio dio = Dio();
    try {
      // Request permission to write to external storage
      await _requestStoragePermission();

      var tempDir = await getExternalStorageDirectory();
      String savePath = tempDir!.path + "/example.webp"; // Change the file name and extension accordingly
      print(savePath);

      await dio.download(fileUrl, savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              // Print download progress
              print((received / total * 100).toStringAsFixed(0) + "%");
            }
          });

      print("File downloaded successfully!");
    } catch (e) {
      print("Error during file download: $e");
    }
  }

  Future<void> _requestStoragePermission() async {
    // Request permission to write to external storage
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
  }

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: feedItems.length,
                itemBuilder: (context, index) {
                  String id = feedId[index];
                  bool isButtonEnabled = buttonStatusMap[id] ?? true;
                  return Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(
                            feedItems[index],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed:  _incrementCounter,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isButtonEnabled ? Colors.blue : Colors.grey,
                              ),
                              child: Text('Download'), /*$index*/
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
                  floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomFloatingActionButton(
            onPressed: online_test_url,
            backgroundColor: fabColor,
            icon: Icons.power,
          ),
          SizedBox(height: 12), // Adjust the spacing between the FABs
          CustomFloatingActionButton(
            onPressed: getfiles,
            backgroundColor: Colors.orange, // Set the desired background color
            icon: Icons.file_copy_sharp, // Set the desired icon
          ),
        ],
      ),
    );
  }
}

