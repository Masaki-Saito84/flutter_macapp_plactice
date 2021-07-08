import 'package:flutter/material.dart';
import 'package:flutter_macos_webview/flutter_macos_webview.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: Text(
              registration['name'],
            ),
            onPressed: () => _onOpenPressed(PresentationStyle.modal, registration['url']),
          ),
          IconButton(
            icon: Icon(Icons.note_alt_outlined),
            onPressed: () {
              setState(() {
                registration['edit'] = true;
              });
            }
          ),
        ],
      );
    }

    Widget _builderRegistrationEditList(registration) {
      final editNameCo = TextEditingController(text: registration['name']);
      final editUrlCo = TextEditingController(text: registration['url']);
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Ink(
            decoration: ShapeDecoration(
              color: Colors.red,
              shape: CircleBorder(),
            ),
            child: IconButton(
              icon: Icon(Icons.close),
              color: Colors.white,
              onPressed: () {
                final deletedSettingValue = _settingValue.where((element) => element != registration).toList();
                setState(() {
                  _settingValue = deletedSettingValue;
                });
              }
            ),
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: editNameCo,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: '表示名を入力してください',
              ),
            ) ,
          ),
          Expanded(
            flex: 1,
            child: TextField(
              controller: editUrlCo,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'URLを入力してください',
              ),
            ),
          ),
          ElevatedButton(
            child: Text('更新'),
            onPressed: () {
              setState(() {
                registration['name'] = editNameCo.text;
                registration['url'] = editUrlCo.text;
                registration['edit'] = false;
              });
            }
          ),
          TextButton(
            child: Text('キャンセル'),
            onPressed: () {
              setState(() {
                registration['edit'] = false;
              });
            }
          ),
        ],
      );
    }

    return Scaffold (
      body: Container(
        alignment: Alignment.center,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: nameCo,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: '表示名を入力してください',
                    ),
                ) ,
                ),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: urlCo,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'URLを入力してください',
                    ),
                  ),
                ),
                OutlinedButton(
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
                  if(_settingValue[index]['edit']) {
                    return _builderRegistrationEditList(_settingValue[index]);
                  } else {
                    return _builderRegistrationList(_settingValue[index]);
                  }
                }
              )
            ),
          ]
        )
      )
    );
  }
}
