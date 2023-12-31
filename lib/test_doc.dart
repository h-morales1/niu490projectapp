import 'package:chatgpcheater/apihandler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';


class TestDoc extends StatefulWidget {
  const TestDoc({super.key, required this.title, required this.baseUrl});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final String? baseUrl;

  String? getBaseUrl() {
    return baseUrl;
  }

  @override
  State<TestDoc> createState() => _TestDocState();
}

class _TestDocState extends State<TestDoc> {
  String urlPrefix = "http://";
  //String? baseUrl; // will be combination of urlPrefix + _serverIp.text
  ApiHandler handler = ApiHandler();
  FilePickerResult? result;
  String? _fileName;
  PlatformFile? pickedfile;
  bool isLoading = false;
  String? aiTraining;
  String? humanTraining;
  File? humanF;
  File? aiF;
  File? test_file;
  //late Future<Map<String, double>> data;
  var scores = [];

  Color humanIconColor = Colors.grey;
  Color aiIconColor = Colors.grey;

  void pickFile(bool trainHuman) async {
    try{

      //var status = await Permission.manageExternalStorage.status;
      /*if(status.isDenied) {
        Map<Permission, PermissionStatus> statuses = await [
          //Permission.storage,
          Permission.manageExternalStorage,
        ].request();
      }*/
      PermissionStatus res = await Permission.photos.request();
      PermissionStatus r = await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      await Permission.mediaLibrary.request();
      print(res.isGranted);
      print(r.isGranted);
      // uploading
      setState(() {
        isLoading = true;
      });

      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      // make sure a file got selected
      if(result != null) {
        _fileName = result!.files.first.name;
        // assign selected test doc to test_file
        test_file = File(result!.files.single.path!);
      }

      // upload done
      setState(() {
        isLoading = false;
      });


    }catch(e){
      // do something in case of file pick error
      print(e);
    }
  }

  /*
    Upload Test document (txt) to server
    Return results
   */
  Future<void> _submit(String? ip) async {
    setState(() {
      // set the ip for the handler to talk to server
      //String isolatedIp = _serverIp.text.toString();
      //baseUrl = '$urlPrefix$isolatedIp';

      handler.setBaseUrl(ip!);

    });

    // get data from input fields
    //int vecSize = int.parse(_vectorSize.value.text.toString());
    //int ep = int.parse(_epochs.value.text.toString());
    // make POST request to train model using data from input fields
    //handler.trainModel(vecSize, ep, aiF!, humanF!);
    await handler.testModel(test_file!);
    scores = await handler.getResults();
    print(scores[0]);
    print("test $scores");
    setState(() {
      if(scores[0] > scores[1]){
        aiIconColor = Colors.green;
        humanIconColor = Colors.grey;
      } else {
        humanIconColor = Colors.green;
        aiIconColor = Colors.grey;
      }
    });
    //data = (await handler.getResults()) as Future<Map<String, double>>;
  }


  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Test Model: ',
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextButton(onPressed: () {
                pickFile(true); // select human training zip
              }, child: const Text('Choose Document to test'),),
            ),
            ElevatedButton(onPressed: () {
              _submit(widget.baseUrl);
            }, child: const Text('Submit'),),
            const SizedBox(
              width: 10.0,
              height: 40.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Results: "),
               Icon(
                 Icons.adb,
                 color: aiIconColor,
                 size: 50.0,
               ) ,
                Icon(
                  Icons.accessibility,
                  color: humanIconColor,
                  size: 50.0,
                ),
              ],
            ),
          ],
        ),

      ),

    );
  }
}