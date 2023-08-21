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
  List<String> data = ["", "", "", ""]; // Contains 4 strings because we show 4 notifications on screen
  int turn = 0;
  List<int> last = [0,0,0,0];

  void setMessages(Map<String, int> sensorsValues, Map<String, String> actuatorsValues) {

    void insertToData(String message) {
      if (turn < 4) {
        data[turn] = message;
        turn++;
      } else {
        for (int i = 0; i < 3; i++) {
          data[i] = data[i + 1];
        }
        data[3] = message;
      }
    }

    if (sensorsValues["IR"]! < 1000 && last[0] > 1000) {
      insertToData("Somebody has entered the house");
      if (actuatorsValues["Buzzer"]! == "1") {
        insertToData("Buzzer activated!");
      }
    }
    if (sensorsValues["PIR"]! < 1000 && last[1] > 1000) {
      insertToData("Somebody is near the ladder");
      if (actuatorsValues["DC"]! == "1") {
        insertToData("DC motor activated!");
      }
    }
    if (sensorsValues["US"]! < 20 && last[2] > 20) {
      insertToData("Somebody has entered room 2");
      if (actuatorsValues["Servo"]![1] == "1") {
        insertToData("Servo activated!");
      }
    }
    if (sensorsValues["LDR"]! > 1000 && last[3] < 1000) {
      insertToData("Somebody turned on the lights in room 1");
      if (actuatorsValues["Servo"]![0] == "1") {
        insertToData("Servo activated!");
      }
    } else if (sensorsValues["LDR"]! < 1000 && last[3] > 1000) {
      insertToData("Lights were turned off in room 1");
    }
  }

  var actuatorsValues;
  bool flag = false;
  void monitorSensors() {
    if (flag) return;
    flag = true;
		DatabaseReference ref = FirebaseDatabase.instance.ref();
		ref.onValue.listen((DatabaseEvent event) {
      var value = Map<String, dynamic>.from(event.snapshot.value as Map);
      var sensorsValues = Map<String, int>.from(value["sensors"] as Map);
      actuatorsValues = Map<String, String>.from(value["actuators"] as Map);
			setMessages(sensorsValues, actuatorsValues);

      if (actuatorsValues["Buzzer"]! == "0" && rooms[0][rooms[0].length - 1] == "n") controlRoom(0);
      if (actuatorsValues["DC"]! == "0" && rooms[3][rooms[3].length - 1] == "n") controlRoom(3);
			
      last[0] = sensorsValues["IR"]!;
      last[1] = sensorsValues["PIR"]!;
      last[2] = sensorsValues["US"]!;
      last[3] = sensorsValues["LDR"]!;
			setState(() {});
		});
	}

  void changeRoomState(int roomNum, bool turnOn) {
    DatabaseReference ref = FirebaseDatabase.instance.ref();

    String state = "0";
    if (turnOn) state = "1";

    void upd(String path, String value) {
      ref.update({
        path: value
      }).asStream();
    }

    if (roomNum == 0) upd("actuators/Buzzer", state);
    else if (roomNum == 1) upd("actuators/Servo", state + actuatorsValues["Servo"][1]);
    else if (roomNum == 2) upd("actuators/Servo", actuatorsValues["Servo"][0] + state);
    else if (roomNum == 3) upd("actuators/DC", state);
  }

  List<String> rooms = ["Entrance: On", "Room 1: On", "Room 2: On", "Ladder: On"];
  void controlRoom(int roomNum) {
    bool isOn = false;
    String roomName = rooms[roomNum];
    if (roomName[roomName.length - 1] == "n") isOn = true;

    if (isOn) {
      rooms[roomNum] = roomName.substring(0,roomName.length - 2) + "Off";
      changeRoomState(roomNum, false);
    }
    else {
      rooms[roomNum] = roomName.substring(0,roomName.length - 3) + "On";
      changeRoomState(roomNum, true);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // List of containers containing the buttons that contol the rooms
    List<Widget> grid_containers = [];
    for (int i = 0; i < 4; i++) {
      grid_containers.add(
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
            child: Text(rooms[i]),
          ),
        )
      );
    }

    // List of all widgets in the column, which are the 4 Text notifications
    // and the grid containing the buttons
    List<Widget> column_list = [
      if (kIsWeb) Expanded(
        child: GridView.count(
          primary: true,
          padding: const EdgeInsets.all(20),
          childAspectRatio: 5,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          crossAxisCount: 2,
          children: grid_containers
        ),
      ),
    ];
    for (int i = 3; i >= 0; i--) {
      column_list.insert(0,
        Text(
          data[i],
          style: const TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold
          ),//text color
        )
      );
    }

    monitorSensors();  // Call the function that monitors the sensors and display notifications

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column( 
          children: column_list
        )
      )
    );
  }
}
