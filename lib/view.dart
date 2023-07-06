import 'dart:io';
import 'dart:math';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqlite121d/main.dart';

class Data_Entry extends StatefulWidget {
  Map? m;

  Data_Entry([this.m]);

  @override
  State<Data_Entry> createState() => _Data_EntryState();
}

class _Data_EntryState extends State<Data_Entry> {
  TextEditingController name_controller = TextEditingController();
  TextEditingController contact_controller = TextEditingController();
  final ImagePicker picker = ImagePicker();
  XFile? image;
  bool t = false;
  String ima_name = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.m != null) {
      name_controller.text = widget.m!['name'];
      contact_controller.text = widget.m!['contact'];
      ima_name = widget.m!['image'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Data Entry"),
        backgroundColor: Colors.grey,
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: TextField(
                controller: name_controller,
                decoration: InputDecoration(
                    hintText: "Enter Name", border: OutlineInputBorder()),
              ),
            ),
            Container(
              margin: EdgeInsets.all(10),
              child: TextField(
                controller: contact_controller,
                decoration: InputDecoration(
                    hintText: "Enter Contact", border: OutlineInputBorder()),
              ),
            ),
            Row(
              children: [
                Container(
                  margin: EdgeInsets.all(20),
                  height: 100,
                  width: 100,
                  color: Colors.purple,
                  child: (t) ? Image.file(File(image!.path)) : null,
                ),
                ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("Select from"),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    image = await picker.pickImage(
                                        source: ImageSource.camera);
                                    t = true;
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                  child: Text("Camera")),
                              TextButton(
                                  onPressed: () async {
                                    image = await picker.pickImage(
                                        source: ImageSource.gallery);
                                    t = true;
                                    Navigator.pop(context);
                                    setState(() {});
                                  },
                                  child: Text("Gallary")),
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Upload Photo"))
              ],
            ),
            ElevatedButton(
                onPressed: () async {
                  String name = name_controller.text;
                  String contact = contact_controller.text;

                  ima_name = "myimag${Random().nextInt(1000)}.jpg";

                  var path =
                      await ExternalPath.getExternalStoragePublicDirectory(
                          ExternalPath.DIRECTORY_DOWNLOADS);
                  HomeScreen.dir = Directory(path);
                  if (await HomeScreen.dir!.exists()) {
                    HomeScreen.dir!.create();
                  }
                  File file = File("${HomeScreen.dir!.path}/${ima_name}");
                  file.writeAsBytes(await image!.readAsBytes());
                  print("path ${file.path}");
                  if (widget.m != null) {
                    String sql =
                        "update data set name = '$name', contact = '$contact', image='$ima_name' where id = '${widget.m!['id']}'";
                    HomeScreen.database!.rawUpdate(sql);
                  } else {
                    String sql =
                        "insert into data values(null,'$name','$contact','$ima_name')";
                    HomeScreen.database!.rawInsert(sql);
                  }
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return HomeScreen();
                    },
                  ));
                  setState(() {});
                },
                child: Text("Submit")),
          ],
        ),
      ),
    );
  }
}
