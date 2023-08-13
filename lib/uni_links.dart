import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

bool _initialUriIsHandled = false;


class login extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<login> {
  Uri? _initialUri;
  Uri? _latestUri;
  Object? _err;

  StreamSubscription? _sub;

  final _scaffoldKey = GlobalKey();
  final _cmdStyle = const TextStyle(
      fontFamily: 'Courier', fontSize: 12.0, fontWeight: FontWeight.w700);

  @override
  void initState() {
    super.initState();
    _handleIncomingLinks();
    _handleInitialUri();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _handleIncomingLinks() {
    if (!kIsWeb) {
      _sub = uriLinkStream.listen((Uri? uri) {
        if (!mounted) return;
        print('got uri: $uri');
        setState(() {
          _latestUri = uri;
          _err = null;
        });
      }, onError: (Object err) {
        if (!mounted) return;
        print('got err: $err');
        setState(() {
          _latestUri = null;
          if (err is FormatException) {
            _err = err;
          } else {
            _err = null;
          }
        });
      });
    }
  }
  Future<void> _handleInitialUri() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;
      _showSnackBar('_handleInitialUri called');
      try {
        final uri = await getInitialUri();
        if (uri == null) {
          print('no initial uri');
        } else {
          print('got initial uri: $uri');
        }
        if (!mounted) return;
        setState(() => _initialUri = uri);
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        if (!mounted) return;
        print('malformed initial uri');
        setState(() => _err = err);
      }
    }
  }
  void login() async {
    final openUrl = 'https://ss0809.github.io/Dark_Matter/';
    await launch(openUrl, forceSafariVC: false, forceWebView: false);
  }
  @override
  Widget build(BuildContext context) {
    final queryParams = _latestUri?.queryParametersAll.entries.toList();

    return Scaffold(
      key: _scaffoldKey,
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8.0),
        children: [
          if (_err != null)
            ListTile(
              title: const Text('Error', style: TextStyle(color: Colors.red)),
              subtitle: Text('$_err'),
            ),
          ListTile(
            title: const Text('Initial Uri'),
            subtitle: Text('$_initialUri'),
          ),
          if (!kIsWeb) ...[
            ListTile(
              title: const Text('Latest Uri'),
              subtitle: Text('$_latestUri'),
            ),
            ListTile(
              title: const Text('Latest Uri (path)'),
              subtitle: Text('${_latestUri?.path}'),
            ),
            ExpansionTile(
              initiallyExpanded: true,
              title: const Text('Latest Uri (query parameters)'),
              children: queryParams == null
                  ? const [ListTile(dense: true, title: Text('null'))]
                  : [
                      for (final item in queryParams)
                        ListTile(
                          title: Text(item.key),
                          trailing: Text(item.value.join(', ')),
                        )
                    ],
            ),
               ElevatedButton(
                            onPressed: () {
                              login();
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Increase padding
                              backgroundColor: const Color(0xFF009688),
                            ),
                            child: Text(
                              'Login with Google',
                              style: TextStyle(
                                fontSize: 14, // Increase the font size
                                color: const Color(0xFFffffff),
                                fontWeight: FontWeight.w200,
                                fontFamily: "Merriweather",
                              ),
                            ),
               ),
          ],
        ],
      ),
    );
  }



  void _showSnackBar(String msg) {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final context = _scaffoldKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
        ));
      }
    });
  }
}
