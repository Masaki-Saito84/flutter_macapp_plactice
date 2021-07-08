import 'package:flutter/cupertino.dart';
import 'package:flutter_macos_webview/flutter_macos_webview.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: LauncherHome(),
    );
  }
}

class LauncherHome extends StatefulWidget {
  @override
  _LauncherHomeState createState() => _LauncherHomeState();
}

Future<void> _onOpenPressed(PresentationStyle presentationStyle, String targetUrl) async {
  final webview = FlutterMacOSWebView(
    onOpen: () => print('Opened'),
    onClose: () => print('Closed'),
    onPageStarted: (url) => print('Page started: $url'),
    onPageFinished: (url) => print('Page finished: $url'),
    onWebResourceError: (err) {
      print(
        'Error: ${err.errorCode}, ${err.errorType}, ${err.domain}, ${err.description}',
      );
    },
  );

  await webview.open(
    url: targetUrl,
    presentationStyle: presentationStyle,
    userAgent:
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_13_6) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/12.0 Safari/605.1.15',
  );
}

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      home: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            child: Text('Open as modal'),
            onPressed: () => _onOpenPressed(PresentationStyle.modal),
          ),
        ],
      ),
    );
  }
}
