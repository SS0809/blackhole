import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'MovieDetailsWidget.dart';
import 'SystemInfo.dart';
import 'uuid.dart';
import 'main.dart';
import 'search.dart';

List<Widget> _screens = [
  SystemInfo(),
];
class MovieListScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  // Constructor
  MovieListScreen(this.isDark, this.toggleTheme);

  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}



class _MovieListScreenState extends State<MovieListScreen> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();
  final int initialItemCount = 4;
  int currentItemCount = 0;

  @override
  void initState() {
    super.initState();
    currentItemCount = initialItemCount;

    _screens.add(_MovieListView());
    _screens.add(_SeriesListView());
    _screens.add(login());
  }

  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      currentItemCount = initialItemCount;
    });
  }

  void searchmovie_telegram() async {
    var url = "https://t.me/blackhole_movie_bot";
    await launch(url, forceSafariVC: false, forceWebView: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: Text('Blackhole'),
        actions: [
          IconButton(
            onPressed: widget.toggleTheme,
            icon: Icon(
              widget.isDark
                  ? Icons.brightness_2_outlined
                  : Icons.wb_sunny_outlined,
            ),
          ),
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

      body: _isSearchVisible ? SearchBarApp() : _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,color: Colors.white,),
            label: 'System',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage_rounded,color: Colors.white,),
            label: 'Movies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storage_rounded,color: Colors.white,),
            label: 'Series',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.download,color: Colors.white,),
            label: 'Pro',
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

  void _performSearch() {
    // Hide the search field and clear the search query
    setState(() {
      _isSearchVisible = false;
      _searchController.clear();
    });
  }
}

class _MovieListView extends StatefulWidget {
  @override
  __MovieListViewState createState() => __MovieListViewState();
}

class __MovieListViewState extends State<_MovieListView> {
  final ScrollController _scrollController = ScrollController();
  final int initialItemCount = 4;
  int currentItemCount = 0;

  @override
  void initState() {
    super.initState();
    currentItemCount = initialItemCount;
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double tolerance = 5; // Adjust the tolerance value as needed

    if (maxScroll - currentScroll <= tolerance) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
 decoration: buildGradientDecoration(),
  child: Query(
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
          controller: _scrollController,
          itemCount: min(currentItemCount, movieNames.length),
          itemBuilder: (context, index) {
            final movieName = movieNames[index];

            return FutureBuilder(
              future: Future.delayed(Duration(milliseconds: 400 )),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While waiting for the delay, show a loading indicator or placeholder
                  return  SpinKitDoubleBounce(
                    color: Colors.white,
                  );
                } else {
                  // Use the delayed result to fetch the movie data
                  return Query(
                    options: QueryOptions(
                      document: gql(r'''
                query GetMovie($movieName: String!) {
                  movie(movie_name: $movieName) {
                    movie_name
                    size_mb
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
                }
              },
            );
          },
        );

      },
    ),);
  }
}



class _SeriesListView extends StatefulWidget {
  @override
  __SeriesListViewState createState() => __SeriesListViewState();
}

class __SeriesListViewState extends State<_SeriesListView> {
  final ScrollController _scrollController = ScrollController();
  final int initialItemCount = 4;
  int currentItemCount = 0;

  @override
  void initState() {
    super.initState();
    currentItemCount = initialItemCount;
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    double maxScroll = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double tolerance = 50; // Adjust the tolerance value as needed

    if (maxScroll - currentScroll <= tolerance) {
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

  @override
  Widget build(BuildContext context) {
        return Container(
 decoration: buildGradientDecoration(),
  child: Query(
      options: QueryOptions(
        document: gql(r'''
          query ExampleQuery {
            allSeriesNames
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

        final seriesNames = result.data!['allSeriesNames'] as List<dynamic>;
        if (seriesNames.isEmpty) {
          return Text('Fetching the Movie');
        }

        return ListView.builder(
          controller: _scrollController, // Assign the scroll controller
          itemCount: min(currentItemCount, seriesNames.length),
          itemBuilder: (context, index) {
            String seriesName = seriesNames[index];
            return Query(
              options: QueryOptions(
                document: gql(r'''
          query GetMovie($seriesName: String!) {
            series(series_name: $seriesName) {
              series_name
              moviename_ref
              img_data
            }
          }
        '''),
                variables: {'seriesName': seriesName},
              ),
              builder: (QueryResult? result, {refetch, FetchMore? fetchMore}) {
                if (result?.hasException == true) {
                  return Text(result!.exception.toString());
                }
                final movieData = result?.data?['series'];
                final movieName = movieData; // Use children instead of name here
                 final children = movieData?['moviename_ref']?['children'];
                 final name = movieData?['series_name'];
                final String img_data = movieData?['img_data'] != null ? ("https://ucarecdn.com/" + movieData?['img_data'] + "/") : "";
                return movieName != null
                    ? SeriesDetailsWidget(name , children , img_data)//full data is parsed
                    : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Fetching the Movie'),
                    const SpinKitDoubleBounce(
                      color: Colors.white,
                    ),
                  ],
                );
              });
          },
        );

      },
    ),);
  }
}
