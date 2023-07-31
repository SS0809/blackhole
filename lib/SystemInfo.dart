import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
class SystemInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(r'''
        query ExampleQuery {
          totalsize
        }
        '''),
      ),
      builder: (QueryResult result, {refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading || result.data == null) {
          return  Center(
            child: CircularProgressIndicator(),
          );
        }
        var totalSize = result.data?['totalsize']?['total_size'] as String? , textt;

        if (totalSize != null) {
          textt = 'Server Total Size: $totalSize MB';
        } else {
          textt = 'Server Size not available';
        }
        return Center(
          child: Text(textt),
        );
      },
    );
  }
}