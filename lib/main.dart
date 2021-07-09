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

    Widget registeredItem(registration) {
      return  Padding(
        padding: EdgeInsets.only(left: 15, right: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              child: Text(
                registration['name'],
                style: TextStyle(
                  decoration: TextDecoration.underline,
                  fontSize: 19,
                  fontWeight: FontWeight.w400,
                  height: 1,
                  color: Color(0xff333333)
                ),
              ),
              onPressed: () => _onOpenPressed(PresentationStyle.modal, registration['url']),
              style: ButtonStyle(
                minimumSize: MaterialStateProperty.all(Size.zero),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 22.5, horizontal: 0)),
              ),
            ),
            IconButton(
              icon: Icon(Icons.note_alt_outlined),
              iconSize: 25,
              splashRadius: 25,
              onPressed: () {
                setState(() {
                  registration['edit'] = true;
                });
              }
            ),
          ],
        )
      );
    }

    Widget registeredItemEdit(registration) {
      final editNameCo = TextEditingController(text: registration['name']);
      final editUrlCo = TextEditingController(text: registration['url']);
      return Row(
        children: [
          IconButton(
            icon: Icon(Icons.cancel),
            color: Colors.red,
            iconSize: 20,
            splashRadius: 18,
            onPressed: () {
              final deletedSettingValue = _settingValue.where((element) => element != registration).toList();
              setState(() {
                _settingValue = deletedSettingValue;
              });
            }
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(
                right: 5
              ),
              child: TextField(
                controller: editNameCo,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 0
                    )
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 0
                    )
                  ),
                  contentPadding: EdgeInsets.all(12),
                  hintText: '表示名を入力してください',
                ),
                style: TextStyle(
                  fontSize: 14,
                  height: 1
                ),
              ) ,
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.only(
                left: 5
              ),
              child: TextField(
                controller: editUrlCo,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 0
                    )
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.white,
                      width: 0
                    )
                  ),
                  contentPadding: EdgeInsets.all(12),
                  hintText: 'URLを入力してください',
                ),
                style: TextStyle(
                  fontSize: 14,
                  height: 1,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              child: Text(
                '更新',
                style: TextStyle(
                  fontSize: 12,
                  height: 1,
                ),
              ),
              onPressed: () {
                setState(() {
                  registration['name'] = editNameCo.text;
                  registration['url'] = editUrlCo.text;
                  registration['edit'] = false;
                });
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 26),
              ),
            ),
          ),
          TextButton(
            child: Text(
              'キャンセル',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xff828282),
                ),
              ),
            onPressed: () {
              setState(() {
                registration['edit'] = false;
              });
            },
          ),
        ],
      );
    }

    Widget registeredList() {
      final itemCount = _settingValue.length;
      return ListView.separated(
        itemBuilder: (BuildContext context, int index) {
          if(index == 0 || index == itemCount + 1) {
            return Container();
          } else if(_settingValue[index - 1]['edit']) {
            return registeredItemEdit(_settingValue[index - 1]);
          } else {
            return registeredItem(_settingValue[index - 1]);
          }
        },
        separatorBuilder: (context, index) => Divider(color: Color(0xffBDBDBD),),
        itemCount: itemCount + 2,
      );
    }

    return Scaffold (
      backgroundColor: Color(0xffE5E5E5),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 60,
        ),
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
              child: registeredList()
            ),
          ]
        )
      )
    );
  }
}