import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '_MovieListScreenState.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';





Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}


bool isDark = false;
int currentAssetIndex = 0;
List<String> assetList = ['assets/asset1.jpg', 'assets/asset4.png','assets/car2.jpg','assets/car3.jpg'];
var server_url = dotenv.env['SERVER'] ?? '';
final HttpLink httpLink = HttpLink(server_url + 'graphql');
Decoration buildGradientDecoration() {
  return /*BoxDecoration(
    gradient: LinearGradient(
      colors: [Colors.black38, Colors.black38], // Customize your gradient colors here
      begin: Alignment.topLeft,
      end: Alignment.bottomCenter,
    ),
  );*/
    BoxDecoration(
      image: DecorationImage(
        image: AssetImage(assetList[currentAssetIndex]),
        fit: BoxFit.cover,
        colorFilter: isDark ? ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop) : ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.dstATop) ,
      ),
    );
}


void _launchURL() async {
  var url = "https://ss0809.github.io/blackhole/docs?version=" + version_new;
  await launch(url, forceSafariVC: false, forceWebView: false);
}
void online_test_url() async {
  Future<void> fetchStatus() async {
    try {
      final response =
      await http.get(Uri.parse(server_url));
      if (response.statusCode == 200) {
        print('fetched');
        return; // Exit the function once the 200 response is received.
      }
      print('running');
      await Future.delayed(Duration(seconds: 10));
      fetchStatus();
    } catch (e) {
      print('error');
    }
  }
  fetchStatus();
}

Future<String> fetchversion() async {
  final GraphQLClient client = GraphQLClient(
    cache: GraphQLCache(),
    link: httpLink,
  );

  final QueryOptions options = QueryOptions(
    document: gql(
      r'''
          query MovieSearch {
            version
          }
        ''',
    ),
  );

  final QueryResult result = await client.query(options);

  if (result.hasException) {
    throw Exception(result.exception.toString());
  }

  return result.data?['version'] as String;
}

String version_new = 'new';
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  bool isDark = false; // Local state to track theme

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }
/*  @override
  Widget build(BuildContext context) {
    return Container();


class MyApp extends StatelessWidget {
    void _launchURL() async {
    var url = "https://ss0809.github.io/blackhole/docs?version=" + version_new;
    await launch(url, forceSafariVC: false, forceWebView: false);
  }
*/

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchversion(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final String? version = snapshot.data;
        print('Version: $version');
        online_test_url();
        version_new = version ?? 'new';
        if (version == 'v3.0.0') {
          final ValueNotifier<GraphQLClient> client =
          ValueNotifier<GraphQLClient>(
            GraphQLClient(
              cache: GraphQLCache(),
              link: httpLink,
            ),
          );
          return GraphQLProvider(
            client: client,
            child: CacheProvider(
              child: MaterialApp(
                theme: !isDark
                    ? ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.deepPurple,
                  primaryColor: Colors.white,
                  canvasColor: Colors.black,
                  textTheme: TextTheme(
                    bodyText1: TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontFamily: 'ProtestRevolution',
                    ),// Adjust text color as needed
                    bodyText2: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontFamily: 'ProtestRiot',
                  ),
                    // Add more text styles if necessary
                  ),
                )
                    : ThemeData(
                  brightness: Brightness.light,
                  primarySwatch: Colors.deepPurple,
                  primaryColor: Colors.black,
                  canvasColor: Colors.black,
                  textTheme: TextTheme(
                      bodyText1: TextStyle(
                        color: Colors.black,
                        fontSize: 64,
                        fontFamily: 'ProtestRevolution',
                      ),
                      bodyText2: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'ProtestRiot',
                      ),
                  ),
                ),

                title: 'Blackhole',
                home: MovieListScreen(isDark , toggleTheme),
              ),
            ),
          );
        } else {
          return MaterialApp(
            theme: new ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              primaryColor: Colors.blue,
              canvasColor: const Color(0xFF303030),
            ),
            title: 'Blackhole',
            home: Scaffold(
              appBar: AppBar(
                title: Text("App Outdated"),
              ),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/asset3.png', width: 300, height: 300),
                    SizedBox(height: 20),
                    Text(
                      "Your app version is outdated.\nPlease update to the latest version.",
                      textAlign: TextAlign.center,
                      style: new TextStyle(
                          color: const Color(0xFFffffff),
                          fontWeight: FontWeight.w200,
                          fontFamily: "Merriweather"),
                    ),
                    ElevatedButton(
                      onPressed: _launchURL,
                      child: Text("Update Now"),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

}