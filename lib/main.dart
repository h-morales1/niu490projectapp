import 'package:chatgpcheater/apihandler.dart';
import 'package:chatgpcheater/test_doc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String urlPrefix = "http://";
  String? baseUrl; // will be combination of urlPrefix + _serverIp.text
  ApiHandler handler = ApiHandler();
  FilePickerResult? result;
  String? _fileName;
  PlatformFile? pickedfile;
  bool isLoading = false;
  String? aiTraining;
  String? humanTraining;

  File? humanF;
  File? aiF;

  // input field for server ip (baseUrl)
  final _serverIp = TextEditingController();
  // input fields epochs and vector size
  final _epochs = TextEditingController();
  final _vectorSize = TextEditingController();

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
      File? hu;
      File? ai;
      // uploading
      setState(() {
        isLoading = true;
      });

      result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if(result != null) {
        _fileName = result!.files.first.name;
        if(trainHuman) {
          humanTraining = result!.paths.toString();
          humanF = File(result!.files.single.path!);
        } else {
          aiTraining = result!.paths.toString();
          aiF = File(result!.files.single.path!);
        }
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

  void _submit() {
    setState(() {
      // set the ip for the handler to talk to server
      String isolatedIp = _serverIp.text.toString();
      baseUrl = '$urlPrefix$isolatedIp';

      handler.setBaseUrl(baseUrl!);

    });

    // get data from input fields
    int vecSize = int.parse(_vectorSize.value.text.toString());
    int ep = int.parse(_epochs.value.text.toString());
    // make POST request to train model using data from input fields
    handler.trainModel(vecSize, ep, aiF!, humanF!);
  }

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
      handler.getHttp();
    });
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
              'Train Model: ',
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _serverIp,
                decoration: const InputDecoration(hintText: 'Server Ip'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _epochs,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Epochs',),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _vectorSize,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: 'Vector Size'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextButton(onPressed: () {
                pickFile(false); // select ai training zip
                }, child: const Text('Choose AI training zip'),),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextButton(onPressed: () {
                pickFile(true); // select human training zip
              }, child: const Text('Choose HUMAN training zip'),),
            ),
            ElevatedButton(onPressed: () {
              _submit();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TestDoc(title: "test")),
              );
            }, child: const Text('Submit'),)
          ],
        ),

      ),

    );
  }
}
