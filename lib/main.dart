import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqlite121d/view.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: HomeScreen(),
  ));
}

class HomeScreen extends StatefulWidget {
  static Database? database;
  static Directory? dir;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool temp = false;
  List<Map> list = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    get_Database();
    Select_data();
    get_permission();

    setState(() {});
  }

  Select_data() async {
    temp = true;
    String sql = "select * from data";
    list = await HomeScreen.database!.rawQuery(sql);
    print("list : $list");
    setState(() {});
  }

  get_Database() async {
// Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'Contact.db');

// open the database
    HomeScreen.database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE data (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT,contact TEXT, image TEXT)');
        });
  }

  get_permission() async {
    var status = await Permission.storage.status;
    var status1 = await Permission.mediaLibrary.status;
    if (status.isDenied && status1.isDenied) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.storage,
        Permission.mediaLibrary,
      ].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contact Book"),
        backgroundColor: Colors.grey,
      ),
      body: (temp)
          ? Card(
        child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            String imgpath =
                "${HomeScreen.dir!.path}/${list[index]['image']}";
            File f = File(imgpath);
            return ListTile(
              tileColor: Colors.white12,
              title: Text("${list[index]['name']}"),
              subtitle: Text("${list[index]['contact']}"),
              leading: CircleAvatar(
                backgroundImage: FileImage(f),
              ),
              trailing: Wrap(
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return Data_Entry(list[index]);
                          },
                        ));
                      },
                      icon: Icon(Icons.edit)),
                  IconButton(
                      onPressed: () {
                        String sql =
                            "delete from data where id = '${list[index]['id']}'";
                        HomeScreen.database!.rawDelete(sql);
                        print("delete : ${sql}");
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) {
                            return HomeScreen();
                          },
                        ));
                        setState(() {});
                      },
                      icon: Icon(Icons.delete)),
                ],
              ),
            );
          },
        ),
      )
          : Text(""),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return Data_Entry();
            },
          ));
        },
      ),
    );
  }
}