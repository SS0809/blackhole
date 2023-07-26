import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:math';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final HttpLink httpLink = HttpLink('https://1c85-49-35-138-84.ngrok-free.app');

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
          title: 'Movie App',
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
        title: Text('Movie App'),
      ),
      body: Query(
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
          variables: {'movieName': 'FastX'}, // Replace with the movie name you want to fetch.
        ),
        builder: (QueryResult? result, {refetch, FetchMore? fetchMore}) { // Add '?' after QueryResult and FetchMore
          if (result?.hasException == true) { // Check if result is not null before accessing hasException
            return Text(result!.exception.toString()); // Use null assertion operator (!) to indicate that result is not null
          }

          final movieData = result?.data?['movie']; // Use null-aware operators (?) to safely access data

          return movieData != null ? MovieDetailsWidget(movieData) : Text('Movie not found');
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
    // Ensure movieData is not null and contains the required fields.
    if (movieData == null || !movieData.containsKey('img_data')) {
      return Text('Invalid movie data');
    }

    // Extract the required data from the movieData map.
    final String movieName = movieData['movie_name'];
    final String doodstreamCode = movieData['doodstream_code'];
    final String streamtapeCode = movieData['streamtape_code'];
    final List<Object?> imgData = movieData['img_data'] as List<Object?>;

    // Generate a random index to access a UUID from imgData list.
    final int randomIndex = Random().nextInt(imgData.length);
    final String imageUrl = "https://ucarecdn.com/" + (imgData[randomIndex] as String)+ "/";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover, // Optional: Adjust the image fit within the container
            ),
          ),
          SizedBox(height: 10),
          Text('Movie Name: $movieName'),
          Text('Doodstream Code: $doodstreamCode'),
          Text('Streamtape Code: $streamtapeCode'),
        ],
      ),
    );
  }
}
