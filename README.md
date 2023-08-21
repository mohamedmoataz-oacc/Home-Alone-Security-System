# Home-Alone-Security-System
<img src="https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg" alt="Awesome Badge"/> [![GitHub Anmol](https://img.shields.io/github/followers/mohamedmoataz-oacc?label=follow&style=social)](https://github.com/mohamedmoataz-oacc)
<br><br>A minimized IOT based security system inspired from the movie Home Alone

Our project idea was inspired from the movie "Home Alone", where a kid is left alone in a house and some thieves try to break into the house, so he hides some pranks all over the house to beat those thieves.
We are doing the same! We are going to build a house that has some sensors and actuators in each room. Whenever a sensor senses presence in a room, it activates the actuator to prank the thieves and eventually kick them out of the house.
But we don't want the security system to be activated when the kid enters any room, that's why we are going to make him a mobile application to be able to control the security system of each room and turn it on or off.

### Project functionalities
* An Ultrasonic sensor detects when a room's door is opened, and a servo motor activates to drop something on the person who entered the room.
* A LED is put in a room and a push button to turn it on and off, when it is turned on an LDR senses the presence of light and therefore knows that someone entered the room, so it activates the servo to hit the thief with a stick.
* A PIR sensor is put besides the ladder, to sense if somebody is getting down the ladder. It activates a DC motor to pull a rope and hamper the thief.
* An IR sensor is put at the entrance, along with a keypad, an LCD and a buzzer. The LCD tells the person trying to enter the house that he should enter the correct 6 digit pin code before entering to turn off the entrance security alarm.
* Every one of those is going to send readings to a firebase real time database and can be controlled from a mobile application.
