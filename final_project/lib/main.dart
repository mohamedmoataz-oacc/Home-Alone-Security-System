import 'dart:html';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homa Alone Security System',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 4, 217, 114)),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Homa Alone Security System'),
      debugShowCheckedModeBanner: false,
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
  void _incrementCounter() {setState(() {_counter++;});}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column( 
        children: <Widget>[
          Text("$_counter"),
          Expanded(
            child: GridView.count(
              primary: true,
              padding: const EdgeInsets.all(20),
              childAspectRatio: 5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              crossAxisCount: 2,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  height: 20,
                  width: 20,
                  child: TextButton(
                    onPressed: _incrementCounter,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 54, 155, 244)),
                      foregroundColor: MaterialStateProperty.all(Colors.black)
                    ),
                    child: const Text("Divide"),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  height: 20,
                  width: 20,
                  child: TextButton(
                    onPressed: _incrementCounter,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 54, 155, 244)),
                      foregroundColor: MaterialStateProperty.all(Colors.black)
                    ),
                    child: const Text("Add"),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  height: 20,
                  width: 20,
                  child: TextButton(
                    onPressed: _incrementCounter,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 54, 155, 244)),
                      foregroundColor: MaterialStateProperty.all(Colors.black)
                    ),
                    child: const Text("Subtract"),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  height: 20,
                  width: 20,
                  child: TextButton(
                    onPressed: _incrementCounter,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 54, 155, 244)),
                      foregroundColor: MaterialStateProperty.all(Colors.black)
                    ),
                    child: const Text("Multiply"),
                  ),
                ),
              ],
            ),
          ),
        ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
