import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_macos_webview/flutter_macos_webview.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

class RegisteredValues {
  final String? name;
  final String? url;
  final int? edit;

  RegisteredValues({
    this.name,
    this.url,
    this.edit,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'edit': edit,
    };
  }

  static Future<Database> get database async {
    final Future<Database> _database = openDatabase(
      join(await getDatabasesPath(), 'registeredValues_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE registeredValues(name TEXT PRIMARY KEY, url TEXT, edit INTEGER)"
        );
      },
      version: 1,
    );
    return _database;
  }

  static Future<void> insertValues(RegisteredValues registeredValues) async {
    final Database db = await database;
    await db.insert(
      'registeredValues',
      registeredValues.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<List<RegisteredValues>> getValuesList() async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('registeredValues');
    return List.generate(maps.length, (i) {
      return RegisteredValues(
        name: maps[i]['name'],
        url: maps[i]['url'],
        edit: maps[i]['edit'],
      );
    });
  }

  static Future<void> updataValues(RegisteredValues registeredValues) async {
    final db = await database;
    await db.update(
      'registeredValues',
      registeredValues.toMap(),
      where: "name = ?",
      whereArgs: [registeredValues.name],
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  static Future<void> deleteValues(String name) async {
    final db = await database;
    await db.delete(
      'registeredValues',
      where: "name = ?",
      whereArgs: [name],
    );
  }

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

  List<RegisteredValues> _registeredValuesList = [];

  Future<void> _initRegisteredValuesList() async {
    _registeredValuesList = await RegisteredValues.getValuesList();
  }

  Future<void> _fetchState() async {
    final List<RegisteredValues> _fetchedValuesList = await RegisteredValues.getValuesList();
    setState(() {
      _registeredValuesList = _fetchedValuesList;
    });
  }

  Widget registeredItem(registration) {
    return  Padding(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            child: Text(
              registration.name,
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontSize: 19,
                fontWeight: FontWeight.w400,
                height: 1,
                color: Color(0xff333333)
              ),
            ),
            onPressed: () => _onOpenPressed(PresentationStyle.modal, registration.url),
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
            onPressed: () async {
              RegisteredValues _updateValues = RegisteredValues(
                name: registration.name,
                url: registration.url,
                edit: 1,
              );
              await RegisteredValues.updataValues(_updateValues);
              _fetchState();
            }
          ),
        ],
      )
    );
  }

  Widget registeredItemEdit(registration) {
    final editNameController = TextEditingController(text: registration.name);
    final editUrlController = TextEditingController(text: registration.url);
    return Row(
      children: [
        IconButton(
          icon: Icon(Icons.cancel),
          color: Colors.red,
          iconSize: 20,
          splashRadius: 18,
          onPressed: () async {
            await RegisteredValues.deleteValues(registration.name);
            _fetchState();
          }
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(
              right: 5
            ),
            child: TextField(
              controller: editNameController,
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
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: EdgeInsets.only(
              left: 5
            ),
            child: TextField(
              controller: editUrlController,
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
            onPressed: () async {
              RegisteredValues _updateValues = RegisteredValues(
                name: editNameController.text,
                url: editUrlController.text,
                edit: 0,
              );
              await RegisteredValues.updataValues(_updateValues);
              _fetchState();
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
          onPressed: () async {
            RegisteredValues _updateValues = RegisteredValues(
              name: registration.name,
              url: registration.url,
              edit: 0,
            );
            await RegisteredValues.updataValues(_updateValues);
            _fetchState();
          },
        ),
      ],
    );
  }

  Widget registeredListView() {
    final itemCount = _registeredValuesList.length;
    return ListView.separated(
      itemBuilder: (BuildContext context, int index) {
        if(index == 0 || index == itemCount + 1) {
          return Container();
        } else if(_registeredValuesList[index - 1].edit! != 0) {
          return registeredItemEdit(_registeredValuesList[index - 1]);
        } else {
          return registeredItem(_registeredValuesList[index - 1]);
        }
      },
      separatorBuilder: (BuildContext context, int index) => Divider(color: Color(0xffBDBDBD),),
      itemCount: itemCount + 2,
    );
  }


  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

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
                  child: Padding(
                    padding: EdgeInsets.only(
                      right:5
                    ),
                    child: TextField(
                      controller: nameController,
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
                        contentPadding: EdgeInsets.symmetric(vertical: 23, horizontal: 20),
                        hintText: '表示名を入力してください',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                      ),
                    ),
                  )
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 15,
                    ),
                    child: TextField(
                      controller: urlController,
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
                        contentPadding: EdgeInsets.symmetric(vertical: 23, horizontal: 20),
                        hintText: 'URLを入力してください',
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                OutlinedButton(
                  child: Text(
                    '追加する',
                    style: TextStyle(
                      fontSize: 12,
                    )
                  ),
                  onPressed: () async {
                    if (nameController.text != '' && urlController.text != '') {
                      RegisteredValues _insertValues = RegisteredValues(
                        name: nameController.text,
                        url: urlController.text,
                        edit: 0
                      );
                      await RegisteredValues.insertValues(_insertValues);
                      _fetchState();
                    }
                    nameController.clear();
                    urlController.clear();
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.blue),
                    padding: EdgeInsets.all(24),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 12),
                child: FutureBuilder(
                  future: _initRegisteredValuesList(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return registeredListView();
                  }
                )
              )
            ),
          ]
        )
      )
    );
  }
}
