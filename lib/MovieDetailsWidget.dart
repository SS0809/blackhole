import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MovieDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> movieData;

  MovieDetailsWidget(this.movieData);

  void _openUrl() async {
    final openUrl = 'https://dooood.com/d/' + movieData['movie_name'];
    await launch(openUrl, forceSafariVC: false, forceWebView: false);
  }

  void _reporter() async {
    final _reporterUrl = ''; // Add the URL for reporting here
    await launch(_reporterUrl, forceSafariVC: false, forceWebView: false);
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
    if (movieData == null || !movieData.containsKey('img_data')) {
      return Text('Invalid movie data');
    }

    final String movieName = movieData['movie_name'];
    final String size_mb =
        movieData['size_mb'] != null ? movieData['size_mb'] : "string";
    final List<Object?> imgData = movieData['img_data'] as List<Object?>? ?? [];

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
        Text('Movie Name: $movieName'),
        Text('Size: $size_mb MB'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                _openUrl();
              },
              child: Text('Get Movie'),
            ),
            ElevatedButton(
              onPressed: () {
                _reporter();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Report'),
            ),
          ],
        ),
      ],
    );
  }
}
