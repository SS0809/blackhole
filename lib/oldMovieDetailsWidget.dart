import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'main.dart';
import 'package:url_launcher/url_launcher.dart';

class oldMovieDetailsWidget extends StatefulWidget {
  final Map<String, dynamic> movieData;

  oldMovieDetailsWidget(this.movieData);

  @override
  _MovieDetailsWidgetState createState() => _MovieDetailsWidgetState();
}

class _MovieDetailsWidgetState extends State<oldMovieDetailsWidget> {
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
        CarouselSlider(
          items: imageWidgets,
          options: CarouselOptions(
            initialPage: initialPage,
            autoPlay: true,
            enlargeCenterPage: true,
            aspectRatio: 16 / 9,
          ),
        ),
        Text(
          'Movie Name: $movieName',
          style: new TextStyle(
              color: const Color(0xFFffffff),
              fontWeight: FontWeight.w200,
              fontFamily: "Merriweather"),
        ),
        Text(
          'Size: $size_mb MB',
          style: new TextStyle(
              color: const Color(0xFFffffff),
              fontWeight: FontWeight.w200,
              fontFamily: "Merriweather"),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _openUrl();
              },
              child: Text(
                'Get Movie',
                style: new TextStyle(
                    color: const Color(0xFFffffff),
                    fontWeight: FontWeight.w200,
                    fontFamily: "Merriweather"),
              ),
            ),
            ElevatedButton(
              onPressed: isReported
                  ? null
                  : _reporter, // Disable the button when already reported
              style: ElevatedButton.styleFrom(
                backgroundColor: isReported
                    ? Colors.grey
                    : Colors.red, // Change color if reported
              ),
              child: Text(isReported
                  ? 'Reported'
                  : 'Report'), // Change text if reported
            ),
          ],
        ),
      ],
    );
  }
}