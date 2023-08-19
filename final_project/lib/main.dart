import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      home: const MyHomePage(title: 'Home Alone Security System'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> rooms = ["Entrance: On", "Room 1: On", "Room 2: On", "Ladder: On"];
  void controlRoom(int room_num) {
    bool isOn = false;
    String room_name = rooms[room_num];
    if (room_name[room_name.length - 1] == "n") isOn = true;
    else if (room_name[room_name.length - 1] == "f") isOn = false;

    setState(() {
      if (isOn) rooms[room_num] = room_name.substring(0,room_name.length - 2) + "Off";
      else rooms[room_num] = room_name.substring(0,room_name.length - 3) + "On";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(child: Column( 
        children: <Widget>[
          const Text(
            "The readings",
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold
            ),//text color
          ),
          if (kIsWeb) Expanded(
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
                    onPressed: () => controlRoom(0),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 54, 155, 244)),
                      foregroundColor: MaterialStateProperty.all(Colors.black)
                    ),
                    child: Text(rooms[0]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  height: 20,
                  width: 20,
                  child: TextButton(
                    onPressed: () => controlRoom(1),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 54, 155, 244)),
                      foregroundColor: MaterialStateProperty.all(Colors.black)
                    ),
                    child: Text(rooms[1]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  height: 20,
                  width: 20,
                  child: TextButton(
                    onPressed: () => controlRoom(2),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 54, 155, 244)),
                      foregroundColor: MaterialStateProperty.all(Colors.black)
                    ),
                    child: Text(rooms[2]),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.white,
                  height: 20,
                  width: 20,
                  child: TextButton(
                    onPressed: () => controlRoom(3),
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(const Color.fromARGB(255, 54, 155, 244)),
                      foregroundColor: MaterialStateProperty.all(Colors.black)
                    ),
                    child: Text(rooms[3]),
                  ),
                ),
              ],
            ),
          ),
        ]
      ),)
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
