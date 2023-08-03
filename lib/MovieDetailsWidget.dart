import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'main.dart';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailsWidget extends StatefulWidget {
  final Map<String, dynamic> movieData;

  MovieDetailsWidget(this.movieData);

  @override
  _MovieDetailsWidgetState createState() => _MovieDetailsWidgetState();
}

class _MovieDetailsWidgetState extends State<MovieDetailsWidget> {
  bool isReported = false;

  String reportMovieMutation = r'''
  mutation ReportMovie($movieName: String!) {
    report(movie_name: $movieName) {
      is_reported
    }
  }
  ''';

  Future<int> reportMovie(String movieName) async {
    final GraphQLClient client = GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    );
    final MutationOptions options = MutationOptions(
      document: gql(reportMovieMutation),
      variables: {'movieName': movieName},
    );
    final QueryResult result = await client.mutate(options);
    if (result.hasException) {
      throw Exception('Mutation failed: ${result.exception.toString()}');
    }
    if (result.data != null && result.data!['report'] != null) {
      return result.data!['report']['is_reported'];
    } else {
      throw Exception('Invalid response data');
    }
  }

  void _openUrl() async {
    final openUrl = 'https://ss0809.github.io/cdn/subdir1/?moviename=' +
        widget.movieData['movie_name'] +
        '&streamtape_code=' +
        widget.movieData['streamtape_code'] +
        '&doodstream_code=' +
        widget.movieData['doodstream_code'];
    await launch(openUrl, forceSafariVC: false, forceWebView: false);
  }

  void _reporter() async {
    if (!isReported) {
      try {
        int reportedStatus = await reportMovie(widget.movieData['movie_name']);
        setState(() {
          isReported = true;
        });
        print('Reported Status: $reportedStatus');
        // You can perform additional actions here based on the reported status
      } catch (e) {
        print('Failed to report: $e');
      }
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            child: InteractiveViewer(
              boundaryMargin:
                  EdgeInsets.all(20.0), // Add some margin around the image
              minScale: 0.5, // Set the minimum scale of the image
              maxScale: 3.0, // Set the maximum scale of the image
              child: Image.network(
                "https://ucarecdn.com/$imageUrl/",
                fit: BoxFit.contain,
              ),
            ),
          ),
        );
      },
    );
  }
  void _showMovieDetailsOverlay(BuildContext context, List<Widget> imageWidgets) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          backgroundColor:Colors.black.withOpacity(0.8),
          body:  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       SizedBox(height: 180),
                        CarouselSlider(
                        items: imageWidgets,
                        options: CarouselOptions(
                          autoPlay: true,
                          enlargeCenterPage: true,
                          aspectRatio: 16 / 9,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        '${widget.movieData['movie_name']}',
                        style: TextStyle(
                          fontSize: 18, // Increase the font size
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFffffff),
                          fontFamily: "Merriweather",
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '(${widget.movieData['size_mb']} MB)',
                        style: TextStyle(
                          fontSize: 16, // Increase the font size
                          color: const Color(0xFFffffff),
                          fontFamily: "Merriweather",
                        ),
                      ),
                      SizedBox(height: 60),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _openUrl();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Increase padding
                              backgroundColor: const Color(0xFF009688),
                            ),
                            child: Text(
                              'Get Movie',
                              style: TextStyle(
                                fontSize: 14, // Increase the font size
                                color: const Color(0xFFffffff),
                                fontWeight: FontWeight.w200,
                                fontFamily: "Merriweather",
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: isReported
                                ? null
                                : _reporter, // Disable the button when already reported
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Increase padding
                              backgroundColor: isReported ? Colors.grey : Colors.red,
                            ),
                            child: Text(
                              isReported ? 'Reported' : 'Report',
                              style: TextStyle(
                                fontSize: 14, // Increase the font size
                                color: const Color(0xFFffffff),
                                fontWeight: FontWeight.w200,
                                fontFamily: "Merriweather",
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 60),
                      Text(
                        'Quality gets reduced during public encoding, \n Upgrade to PRO for best quality',
                        style: TextStyle(
                          fontSize: 12, // Increase the font size
                          color: const Color(0xFFffffff),
                          fontFamily: "Merriweather",
                        ),
                      ),
                 ],
             ),
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    if (!widget.movieData.containsKey('img_data')) {
      return Text('Invalid movie data');
    }

    final String movieName = widget.movieData['movie_name'];
    final String size_mb = widget.movieData['size_mb'] != null
        ? widget.movieData['size_mb']
        : "string";
    final String doodstream_code = widget.movieData['doodstream_code'] != null
        ? widget.movieData['doodstream_code']
        : "string";
    final String streamtape_code = widget.movieData['streamtape_code'] != null
        ? widget.movieData['streamtape_code']
        : "string";
    final List<Object?> imgData =
        widget.movieData['img_data'] as List<Object?>? ?? [];

    final List<Widget> imageWidgets = imgData
        .whereType<String>() // Filter out elements that are not of type String
        .map((imageUrl) {
      return GestureDetector(
        onLongPress: () => _showFullScreenImage(context, imageUrl),
        child: Image.network(
          "https://ucarecdn.com/$imageUrl/",
          fit: BoxFit.contain,
        ),
      );
    }).toList();

    final int initialPage = Random().nextInt(imageWidgets.length);

    return Column(
      children: [
        SizedBox(height: 20),
        GestureDetector(
          onTap: () => _showMovieDetailsOverlay(context ,imageWidgets ), // Show movie details overlay on tap
          child: imageWidgets[0], 
        ),
        SizedBox(height: 20),
        GestureDetector(
          onTap: () => _showMovieDetailsOverlay(context ,imageWidgets ), // Show movie details overlay on tap
          child: Text(
          '$movieName',
          style: new TextStyle(
              color: const Color(0xFFffffff),
              fontWeight: FontWeight.w800,
              fontFamily: "Merriweather"),
        ),
        ),
        
      ],
    );
  }
}
