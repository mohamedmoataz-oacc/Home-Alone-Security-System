#include <Keypad.h>
#include <ESP32Servo.h>
#include <LiquidCrystal.h>
#include <WiFi.h>
#include <time.h>
#include <FirebaseESP32.h>

#define FIREBASE_HOST // YOUR DB LINK GOES HERE
#define FIREBASE_AUTH // YOUR API KEY GOES HERE

#define WIFI_SSID // YOUR WIFI GOES HERE
#define WIFI_PASSWORD // YOUR WIFI PASSWORD GOES HERE

#define USER_EMAIL // YOUR USER EMAIL GOES HERE
#define USER_PASSWORD // YOUR USER PASSWORD GOES HERE

#define ROW_NUM    2
#define COLUMN_NUM    3

#define PIN_IN1 1
#define PIN_IN2 17
#define PIN_ENA 3
#define BUZZER_PIN 15
#define SERVO_PIN 4
#define IR_PIN 35
#define TRIG_PIN 25
#define ECHO_PIN 32
#define PIR_PIN 33
#define LDR_PIN 34
#define BUTTON_PIN 16
#define LED_PIN 2

char keys[ROW_NUM][COLUMN_NUM] = {
    {'4', '5', '6'},
    {'7', '8', '9'}
};

byte pin_rows[ROW_NUM] = {27,26};
byte pin_column[COLUMN_NUM] = {14,12,13};
LiquidCrystal lcd(22, 23, 18, 5, 21, 19);

Keypad keypad = Keypad(makeKeymap(keys), pin_rows, pin_column, ROW_NUM, COLUMN_NUM);
Servo servo;

FirebaseData fbdo;
FirebaseJson json;
FirebaseAuth auth;
FirebaseConfig config;

char key = keypad.getKey();
String password = "";
String t_pass = "868686";
int wrong_password_counter = 0;

// int dbReadSensor(String data_field) {
//     if (Firebase.getInt(fbdo, "/sensors/" + data_field)) return fbdo.to<int>();
//     else {
//         Serial.print("Error reading from Firebase: ");
//         Serial.println(fbdo.errorReason());
//     }
//     return 0;
// }

String dbReadActuator(String data_field) {
    if (Firebase.getString(fbdo, "/actuators/" + data_field)) return fbdo.to<String>();
    else {
        Serial.print("Error reading from Firebase: ");
        Serial.println(fbdo.errorReason());
    }
    return "";
}

void dbUpdate(String data_field, int newValue, bool act) {
    FirebaseJson json;
    String path;
    if (act) {
        String n = String(newValue);
        json.set(data_field, n);
        path = "/actuators";
    } else {
        json.set(data_field, newValue);
        path = "/sensors";
    }

    
    if (Firebase.updateNode(fbdo, path, json)) {
        Serial.println("Data updated successfully");
    } else {
        Serial.print("Error updating data: ");
        Serial.println(fbdo.errorReason());
    }
}

void setup() {
    Serial.begin(115200);
    lcd.begin(16, 2);
    pinMode(IR_PIN, INPUT);
    pinMode(PIR_PIN, INPUT);
    pinMode(ECHO_PIN, INPUT);
    pinMode(LDR_PIN, INPUT);
    pinMode(BUTTON_PIN, INPUT_PULLUP);
    pinMode(LED_PIN, OUTPUT);
    pinMode(TRIG_PIN, OUTPUT);
    pinMode(BUZZER_PIN, OUTPUT);
    pinMode(PIN_IN1, OUTPUT);
    pinMode(PIN_IN2, OUTPUT);
    pinMode(PIN_ENA, OUTPUT);
    servo.attach(SERVO_PIN);

    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    lcd.print("Connecting to");
    lcd.setCursor(0,1);
    lcd.print("Wi-Fi...");

    while (WiFi.status() != WL_CONNECTED)
    {
        Serial.print(".");
        delay(300);
    }
    Serial.println();
    lcd.clear();
    lcd.print("Connected");

    config.api_key = FIREBASE_AUTH;
    config.database_url = FIREBASE_HOST;
    auth.user.email = USER_EMAIL;
    auth.user.password = USER_PASSWORD;

    Firebase.begin(&config, &auth);
    Firebase.reconnectWiFi(true);

    Firebase.setReadTimeout(fbdo, 1000 * 60);
    Firebase.setwriteSizeLimit(fbdo, "tiny");
    
    Serial.println("------------------------------------");
    Serial.println("Connected...");

    for (int i = 0; i <= 90; i++) {
      servo.write(i);
      delay(15);
    }
}

int last[] = {0,0,0,0};
int last_button = 1;
int led_state = 0;
String last_buzzer = "0";
String last_dc = "1";
float duration_us, distance_cm;
bool second_floor = false;
bool rope = false;
bool redo_pass = false;

int actuators_counter = 0;
String current_buzzer = "1";
String current_dc = "1";
String current_servo = "11";

int current_ir = 4095;
int current_button = 1;
int current_pir = 0;
int current_us = 15;
int current_ldr = 0;

void loop() {
  switch (actuators_counter) {
    case 0:
      current_buzzer = dbReadActuator("Buzzer");
      break;
    case 1:
      current_dc = dbReadActuator("DC");
      break;
    case 2:
      current_servo = dbReadActuator("Servo");
      break;
  }

  actuators_counter = (actuators_counter + 1) % 3;

  current_ir = analogRead(IR_PIN);

  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  duration_us = pulseIn(ECHO_PIN, HIGH);
  distance_cm = 0.017 * duration_us;

  current_button = digitalRead(BUTTON_PIN);
  current_pir = digitalRead(PIR_PIN);
  current_us = distance_cm;
  current_ldr = analogRead(LDR_PIN);
  

	Serial.print("IR: ");
	Serial.println(current_ir);
	Serial.print("PIR: ");
	Serial.println(current_pir);
	Serial.print("LDR: ");
	Serial.println(current_ldr);
	Serial.print("US: ");
	Serial.println(current_us);

	// Entrance security system
    if ((current_buzzer == "1" && last_buzzer == "0") || redo_pass) {
      redo_pass = false;
		lcd.clear();
        lcd.print("Enter 6 digit");
        lcd.setCursor(0, 1);
        lcd.print("pin code: ");
	} else if (current_buzzer == "1") {
		key = keypad.getKey();
		if (key && password.length() < 6) {
			password += key;
			lcd.print(key);
      Serial.print(key);
		}
		if (password.length() == 6) {
			second_floor = false;
			if (password == t_pass) {
				lcd.clear();
				lcd.print("Welcome home!");
				dbUpdate("Buzzer", 0, true);
				digitalWrite(BUZZER_PIN, LOW);
        password = "";
			} else {
				lcd.clear();
				lcd.print("Wrong pin!");
				password = "";
				wrong_password_counter++;
        redo_pass = true;
				delay(1000);
			}
		}
	} else digitalWrite(BUZZER_PIN, LOW);
	
	if (((current_ir < 1000 && last[0] > 1000) || wrong_password_counter >= 3) && current_buzzer == "1") {
    dbUpdate("IR", current_ir, false);
		digitalWrite(BUZZER_PIN, HIGH);
		lcd.clear();
		lcd.print("Someone broke");
		lcd.setCursor(0,1);
		lcd.print("into the house!");
	}

	// Ladder security system
	if (last_dc == "0" && current_dc == "1" && rope) {
		digitalWrite(PIN_IN1, LOW);
		digitalWrite(PIN_IN2, HIGH);
		analogWrite(PIN_ENA, 100);
		delay(2000);
		digitalWrite(PIN_IN2, LOW);
		rope = false;
	}
	if (current_pir == 1 && last[1] == 0 && second_floor && current_dc == "1") {
    dbUpdate("PIR", 1, false);
		digitalWrite(PIN_IN1, HIGH);
		digitalWrite(PIN_IN2, LOW);
		analogWrite(PIN_ENA, 100);
		delay(2000);
		digitalWrite(PIN_IN1, LOW);
		dbUpdate("DC", 0, true);
    dbUpdate("PIR", 0, false);
		rope = true;
	}

	// Room 1 security system
	if (current_button == 0 && last_button == 1) {
		led_state = (led_state + 1) % 2;
		digitalWrite(LED_PIN, led_state);
	}
	if (current_ldr > 1000 && last[2] < 1000) {
		second_floor = true;
    dbUpdate("LDR", current_ldr, false);
		if (current_servo[0] == '1') {
			for (int i = 90; i <= 180; i++) {
        servo.write(i);
        delay(15);
      }
			delay(2000);
			for (int i = 180; i >= 90; i--) {
        servo.write(i);
        delay(15);
      }
		}
	} else if (current_ldr < 1000 && last[2] > 1000) dbUpdate("LDR", current_ldr, false);

	// Room 2 security system
	if (current_us < 10 && last[3] > 10) {
		second_floor = true;
    dbUpdate("US", current_us, false);
		if (current_servo[1] == '1') {
			for (int i = 90; i >= 0; i--) {
        servo.write(i);
        delay(15);
      }
			delay(2000);
			for (int i = 0; i <= 90; i++) {
        servo.write(i);
        delay(15);
      }
		}
	}

	last_buzzer = current_buzzer;
	last_dc = current_dc;
	last_button = current_button;
	last[0] = current_ir;
	last[1] = current_pir;
	last[2] = current_ldr;
	last[3] = current_us;
}
