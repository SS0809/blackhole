import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'MovieDetailsWidget.dart';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';




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

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  bool _isSearchVisible = false; // Track whether search field is visible
  final TextEditingController _searchController = TextEditingController();

  // Define a scroll controller to handle scroll events
  ScrollController _scrollController = ScrollController();

  // Define the number of items to show initially
  final int initialItemCount = 4;

  // The current number of items to show in the list
  int currentItemCount = 0;

  @override
  void initState() {
    super.initState();
    // Set the initial number of items to show
    currentItemCount = initialItemCount;

    // Add a scroll listener to the ScrollController
    _scrollController.addListener(_scrollListener);
  }

  // Function to handle scroll events
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // If the user reaches the end of the list, load more items
      setState(() {
        currentItemCount += 4; // Load four more items
      });
    }
  }

  @override
  void dispose() {
    // Dispose of the scroll controller to avoid memory leaks
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blackhole'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Toggle the search field visibility
              setState(() {
                _isSearchVisible = !_isSearchVisible;
              });
            },
          ),
        ],
      ),
      body: _isSearchVisible ? _buildSearchField() : _buildMovieList(),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search movies...',
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              // Clear the search query when the clear icon is clicked
              _searchController.clear();
            },
          ),
        ),
        onChanged: (query) {
          // Perform search as the user types (optional)
          // _performSearch();
        },
        onSubmitted: (query) {
          // Perform search when the user submits the search query
          _performSearch();
        },
      ),
    );
  }

  Widget _buildMovieList() {
    return Query(
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
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Accessing the server'),
              const SpinKitFadingCircle(
                color: Colors.white,
              ),
            ],
          );
        }

        final movieNames = result.data!['allMovieNames'] as List<dynamic>;

        if (movieNames.isEmpty) {
          return Text('Fetching the Movie');
        }

        return ListView.builder(
          controller: _scrollController, // Assign the scroll controller
          itemCount: min(currentItemCount, movieNames.length),
          itemBuilder: (context, index) {
            final movieName = movieNames[index];
            return Query(
              options: QueryOptions(
                document: gql(r'''
                  query GetMovie($movieName: String!) {
                    movie(movie_name: $movieName) {
                      movie_name
                      size_mb
                      img_data
                      doodstream_code
                      streamtape_code
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
                return movieData != null
                    ? MovieDetailsWidget(movieData)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Fetching the Movie'),
                          const SpinKitDoubleBounce(
                            color: Colors.white,
                          ),
                        ],
                      );
              },
            );
          },
        );
      },
    );
  }

  void _performSearch() {
    // Hide the search field and clear the search query
    setState(() {
      _isSearchVisible = false;
      _searchController.clear();
    });
  }
}
