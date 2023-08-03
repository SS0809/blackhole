import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '_MovieListScreenState.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

final HttpLink httpLink = HttpLink('https://graphql-pyt9.onrender.com');

void main() {
  runApp(MyApp());
}

String version_new = 'new';

class MyApp extends StatelessWidget {
    void _launchURL() async {
    var url = "https://ss0809.github.io/blackhole/docs?version=" + version_new;
    await launch(url, forceSafariVC: false, forceWebView: false);
  }

void online_test_url() async {
  Future<void> fetchStatus() async {
    try {
      final response =
          await http.get(Uri.parse('https://' + 'original-google.onrender.com'));
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
        if (version == 'v2.1.0') {
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
                theme: new ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.blue,
                  primaryColor: const Color(0xFF212121),
                  //accentColor: const Color(0xFF64ffda),
                  canvasColor: const Color(0xFF303030),
                ),
                title: 'Blackhole',
                home: MovieListScreen(),
              ),
            ),
          );
        } else {
          return MaterialApp(
            theme: new ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.blue,
              primaryColor: const Color(0xFF212121),
              //accentColor: const Color(0xFF64ffda),
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
