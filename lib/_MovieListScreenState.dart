import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'MovieDetailsWidget.dart';
import 'SystemInfo.dart';

List<Widget> _screens = [
  SystemInfo(),
];

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  final int initialItemCount = 4;
  int currentItemCount = 0;

  @override
  void initState() {
    super.initState();
    currentItemCount = initialItemCount;
    _scrollController.addListener(_scrollListener);

    _screens.add(_buildMovieList());
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        currentItemCount += 4; // Load four more items
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
              setState(() {
                _isSearchVisible = !_isSearchVisible;
              });
            },
          ),
        ],
      ),
      body: _isSearchVisible ? _buildSearchField() : _screens![_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'System',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Feed',
          ),
        ],
      ),
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
          return Center(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Accessing the server'),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
           ),
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
