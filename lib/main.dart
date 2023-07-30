import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'MovieDetailsWidget.dart';
import '_MovieListScreenState.dart';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:url_launcher/url_launcher.dart';

final HttpLink httpLink = HttpLink('https://graphql-pyt9.onrender.com');

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  void _launchURL() async {
    const url = "https://ss0809.github.io/blackhole/";
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false, forceWebView: false);
    } else {
      throw "Could not launch $url";
    }
  }

  Future<String> fetchMovieSearch() async {
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
      future: fetchMovieSearch(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        final String? version = snapshot.data;
        print('Version: $version');

        if (version == 'v1.0') {
          final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
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
                  accentColor: const Color(0xFF64ffda),
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
              accentColor: const Color(0xFF64ffda),
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
                    Text(
                      "Your app version is outdated.\nPlease update to the latest version.",
                      textAlign: TextAlign.center,
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
