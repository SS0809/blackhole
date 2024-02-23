import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class SystemInfo extends StatefulWidget {
  @override
  _SystemInfoState createState() => _SystemInfoState();
}

class _SystemInfoState extends State<SystemInfo> {
  int currentAssetIndex = 0;

  void changeAsset(int newIndex) {
    setState(() {
      currentAssetIndex = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swipe right
          changeAsset((currentAssetIndex - 1) % assetList.length);
        } else if (details.primaryVelocity! < 0) {
          // Swipe left
          changeAsset((currentAssetIndex + 1) % assetList.length);
        }
      },
      child: Query(
        options: QueryOptions(
          document: gql(r'''
          query ExampleQuery {
            totalsize ,
            version
          }
          '''),
        ),
        builder: (QueryResult result, {refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading || result.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          var totalSize = result.data?['totalsize'] ;
          var versiondata = result.data?['version'] as String?;

          var textt = totalSize != null
              ? 'Total Server Storage: $totalSize MB \n Version: $versiondata'
              : 'Server Size not available';

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(assetList[currentAssetIndex]),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3), BlendMode.dstATop),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'BLACKHOLE \n',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 64,
                      fontFamily: 'ProtestRevolution',
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 220, 0, 0),
                    child: Text(
                      '\n' + textt,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'ProtestRiot',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Define your asset list somewhere outside the widget
List<String> assetList = ['assets/asset1.jpg', 'assets/asset4.png','assets/car2.jpg','assets/car3.jpg',];
