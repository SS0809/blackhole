import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'main.dart';
class SystemInfo extends StatefulWidget {
  @override
  _SystemInfoState createState() => _SystemInfoState();
}

class _SystemInfoState extends State<SystemInfo> {

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
            decoration: buildGradientDecoration(),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    'BLACKHOLE \n',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 220, 0, 0),
                    child: Text(
                      '\n' + textt,
                      style: Theme.of(context).textTheme.bodyText2,
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

