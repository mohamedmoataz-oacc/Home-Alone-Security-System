import 'package:flutter/material.dart';
import 'main.dart';
class welcome extends StatefulWidget {
  const welcome({Key? key}) : super(key: key);

  @override
  State<welcome> createState() => _State();
}

class  _State extends State<welcome > {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('Home Alone Security System',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w500,
          ),),
        centerTitle: true,
        backgroundColor: Color(0xff1db0e7),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'img/alone2.jpg',  // Replace with the actual path to your image file
              width: 400,
              height: 400,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Feel safe wherever you are ',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 30,
            ),

            MaterialButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>  const MyHomePage(title: 'Home Alone Security System')));
              },
              child: const Text('home security',style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w500,
              ),),
              color: Color(0xff193dbd),
              textColor: Colors.white,
              minWidth: 300,
              height: 60,
            ),
            const SizedBox(
              height: 70,
            ),
          ],
        ),
      ),
    );
  }
}

