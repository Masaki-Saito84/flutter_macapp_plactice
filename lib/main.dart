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

class _LauncherHomeState extends State<LauncherHome> {

  List _settingValue = [];
  @override
  Widget build(BuildContext context) {
    final nameCo = TextEditingController();
    final urlCo = TextEditingController();

    Widget _builderRegistrationList(registration) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: CupertinoButton(
              child: Text(registration['name']),
              onPressed: () => _onOpenPressed(PresentationStyle.modal, registration['url'])
            ),
          ),
          Expanded(
            flex: 1,
            child: CupertinoButton(
              child: Text('編集'),
              onPressed: () {
                setState(() {
                  registration['edit'] = true;
                });
              }
            ),
          ),
        ],
      );
    }
    return CupertinoApp (
      debugShowCheckedModeBanner: false,
      home: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: CupertinoTextField(
                    placeholder: '表示名を入力してください',
                    controller: nameCo,
                ) ,
                ),
                Expanded(
                  flex: 2,
                  child: CupertinoTextField(
                    placeholder: 'URLを入力してください',
                    controller: urlCo,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: CupertinoButton(
                    child: Text('追加する'),
                    onPressed: () {
                      setState(() {
                        if (nameCo.text != '' && urlCo.text != '') {
                          _settingValue.add({'name': nameCo.text, 'url': urlCo.text, 'edit': false});
                        }
                      });
                      nameCo.clear();
                      urlCo.clear();
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _settingValue.length,
                itemBuilder: (context, index) {
                    return _builderRegistrationList(_settingValue[index]);
                }
              )
            ),
          ]
        )
      )
    );
  }
}
