import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'MovieDetailsWidget.dart';
import '_MovieListScreenState.dart';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';


final HttpLink httpLink = HttpLink('https://graphql-pyt9.onrender.com');

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {


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
  }
}

