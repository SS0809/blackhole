import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink('https://graphql-pyt9.onrender.com');

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
    title: 'Blackhole',
    home: MovieListScreen(),
    ),
    ),
    );
  }
}
class MovieListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blackhole'),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(r'''
            query ExampleQuery {
              allMovieNames
            }
          '''),
        ),
        builder: (QueryResult result, {refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.data == null) {
            return Text('No data found');
          }

          final movieNames = result.data!['allMovieNames'] as List<dynamic>;

          if (movieNames.isEmpty) {
            return Text('No movies found');
          }

          return ListView.builder(
            itemCount: movieNames.length,
            itemBuilder: (context, index) {
              final movieName = movieNames[index];
              return Query(
                options: QueryOptions(
                  document: gql(r'''
                    query GetMovie($movieName: String!) {
                      movie(movie_name: $movieName) {
                        movie_name
                        streamtape_code
                        doodstream_code
                        img_data
                      }
                    }
                  '''),
                  variables: {'movieName': movieName},
                ),
                builder: (QueryResult? result, {refetch, FetchMore? fetchMore}) {
                  if (result?.hasException == true) {
                    return Text(result!.exception.toString());
                  }

                  final movieData = result?.data?['movie'];

                  return movieData != null ? MovieDetailsWidget(movieData) : Text('Movie not found');
                },
              );
            },
          );
        },
      ),
    );
  }
}


class MovieDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> movieData;

  MovieDetailsWidget(this.movieData);

  @override
  Widget build(BuildContext context) {
    if (movieData == null || !movieData.containsKey('img_data')) {
      return Text('Invalid movie data');
    }

    final String movieName = movieData['movie_name'];
    final String doodstreamCode = movieData['doodstream_code'];
    final String streamtapeCode = movieData['streamtape_code'];
    final List<Object?> imgData = movieData['img_data'] as List<Object?>? ?? []; // Handle null case
    void _openDoodstreamUrl() async {
      final doodstreamUrl = 'https://dooood.com/d/' + movieData['doodstream_code'];
      await launch(doodstreamUrl, forceSafariVC: false, forceWebView: false);
    }
    void _openStreamtapeUrl() async {
      final streamtapeUrl = 'https://streamtape.com/v/' + movieData['streamtape_code'];
      await launch(streamtapeUrl, forceSafariVC: false, forceWebView: false);
    }

    final List<Widget> imageWidgets = imgData.map((imageUrl) {
      return Image.network(
        "https://ucarecdn.com/$imageUrl/",
        fit: BoxFit.cover,
      );
    }).toList();

    final int initialPage = Random().nextInt(imgData.length);

    return Column(
      children: [
        SizedBox(height: 10),
        CarouselSlider(
          items: imageWidgets,
          options: CarouselOptions(
            initialPage: initialPage,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
          ),
        ),
        SizedBox(height: 10),
        Text('Movie Name: $movieName'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust the alignment as needed
          children: [
            ElevatedButton(
              onPressed: () {
                _openDoodstreamUrl();
              },
              child: Text('Doodstream'),
            ),
            ElevatedButton(
              onPressed: () {
                _openStreamtapeUrl();
              },
              child: Text('Streamtape'),
            ),
          ],
        ),

        SizedBox(height: 30),
      ],
    );
  }
}
