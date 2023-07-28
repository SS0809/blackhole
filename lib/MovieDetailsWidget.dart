import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class MovieDetailsWidget extends StatelessWidget {
  final Map<String, dynamic> movieData;

  MovieDetailsWidget(this.movieData);

  void _openDoodstreamUrl() async {
    final doodstreamUrl = 'https://dooood.com/d/' + movieData['doodstream_code'];
    await launch(doodstreamUrl, forceSafariVC: false, forceWebView: false);
  }

  void _openStreamtapeUrl() async {
    final streamtapeUrl = 'https://streamtape.com/v/' + movieData['streamtape_code'];
    await launch(streamtapeUrl, forceSafariVC: false, forceWebView: false);
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
              boundaryMargin: EdgeInsets.all(20.0), // Add some margin around the image
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
    final String doodstreamCode = (movieData['doodstream_code']==null)?'ok':movieData['doodstream_code'];
    final String streamtapeCode = (movieData['streamtape_code']==null)?'ok':movieData['streamtape_code'];
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
    })
        .toList();

    final int initialPage = Random().nextInt(imageWidgets.length);

    return Column(
      children: [
        SizedBox(height: 40),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
