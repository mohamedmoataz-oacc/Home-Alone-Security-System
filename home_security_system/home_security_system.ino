
#include <Keypad.h>
#include <ESP32Servo.h>
#include <LiquidCrystal.h>
#include <WiFi.h>
#include <time.h>
#include <FirebaseESP32.h>

#define FIREBASE_HOST "https://iot-training-final-project-default-rtdb.europe-west1.firebasedatabase.app"
#define FIREBASE_AUTH "AIzaSyDFtgk-FysXe3GTWVwTRvGILe9bBxRO8-A"

#define WIFI_SSID "MO"
#define WIFI_PASSWORD "m4m05909"

#define USER_EMAIL "cooladmin@oursecurehome.com"
#define USER_PASSWORD "v3rys3cur3p@$$w0rd"

#define ROW_NUM    4
#define COLUMN_NUM    4

#define PIN_IN1 7
#define PIN_IN2 8
#define PIN_ENA 9
#define BUZZER_PIN 5
#define SERVO_PIN 4
#define IR_PIN 35
#define TRIG_PIN 24
#define ECHO_PIN 34
#define PIR_PIN 21
#define LDR_PIN 20
#define BUTTON_PIN 22
#define LED_PIN 6

char keys[ROW_NUM][COLUMN_NUM] = {
    {'1', '2', '3', 'A'},
    {'4', '5', '6', 'B'},
    {'7', '8', '9', 'C'},
    {'*', '0', '#', 'D'}
};

byte pin_rows[ROW_NUM] = {13,12,14,27};
byte pin_column[COLUMN_NUM] = {26,25,33,32};
LiquidCrystal lcd(19, 23, 18, 17, 16, 15);

Keypad keypad = Keypad(makeKeymap(keys), pin_rows, pin_column, ROW_NUM, COLUMN_NUM);
Servo servo;

FirebaseData fbdo;
FirebaseJson json;
FirebaseAuth auth;
FirebaseConfig config;

char key = keypad.getKey();
String password = "";
String t_pass = "A001*4";

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

    servo.write(90);
}

int last[] = {0,0,0,0};
String last_buzzer = "0";
String last_dc = "1";
int last_button = 1;
float duration_us, distance_cm;
bool second_floor = false;
int led_state = 0;

void loop() {
	digitalWrite(TRIG_PIN, HIGH);
	delayMicroseconds(10);
	digitalWrite(TRIG_PIN, LOW);
	duration_us = pulseIn(ECHO_PIN, HIGH);
	distance_cm = 0.017 * duration_us;

	String current_buzzer = dbReadActuator("Buzzer");
	String current_dc = dbReadActuator("DC");
	String current_servo = dbReadActuator("Servo");
	int current_button = digitalRead(BUTTON_PIN);
	int current_ir = analogRead(IR_PIN);
	int current_pir = digitalRead(PIR_PIN);
	int current_us = distance_cm;
	int current_ldr = analogRead(LDR_PIN);

	Serial.print("IR: ");
	Serial.println(current_ir);
	Serial.print("PIR: ");
	Serial.println(current_pir);
	Serial.print("LDR: ");
	Serial.println(current_ldr);
	Serial.print("US: ");
	Serial.println(current_us);

	dbUpdate("IR", current_ir, false);
	dbUpdate("PIR", current_pir, false);
	dbUpdate("US", current_us, false);
	dbUpdate("LDR", current_ldr, false);

	// Entrance security system
    if (current_buzzer == "1" && last_buzzer == "0") {
		lcd.clear();
        lcd.print("Enter 6 digit");
        lcd.setCursor(0, 1);
        lcd.print("pin code: ");
	} else if (current_buzzer == "1") {
		key = keypad.getKey();
		if (key && password.length < 6) {
			password += key;
			lcd.print(key);
		}
		if (password.length == 6) {
			second_floor = false;
			if (password == t_pass) {
				lcd.clear();
				lcd.print("Welcome home!");
				dbUpdate("Buzzer", 0, true);
			} else {
				lcd.clear();
				lcd.print("Wrong pin!");
				password = "";
				last_buzzer = "0";
				delay(1000);
			}
		}
	}
	if (current_ir < 1000 && last[0] > 1000 && current_buzzer == "1") {
		digitalWrite(BUZZER_PIN, HIGH);
		lcd.clear();
		lcd.print("Someone broke");
		lcd.setCursor(0,1);
		lcd.print("into the house!");
	}

	// Ladder security system
	if (last_dc == "0" && current_dc == "1") {
		digitalWrite(PIN_IN1, LOW);
		digitalWrite(PIN_IN2, HIGH);
		analogWrite(PIN_ENA, 50);
		delay(500);
		digitalWrite(PIN_IN2, LOW);
	}
	if (current_pir == 1 && last[1] == 0 && second_floor && current_dc == "1") {
		digitalWrite(PIN_IN1, HIGH);
		digitalWrite(PIN_IN2, LOW);
		analogWrite(PIN_ENA, 100);
		delay(500);
		digitalWrite(PIN_IN1, LOW);
		dbUpdate("DC", 0, true);
	}

	// Room 1 security system
	if (current_button == 0 && last_button == 1) {
		led_state = (led_state + 1) % 2;
		digitalWrite(LED_PIN, led_state);
	}
	if (current_ldr > 1000 && last[2] < 1000) {
		second_floor = true;
		if (current_servo[0] == "1") {
			servo.write(180);
			delay(2000);
			servo.write(90);
		}
	}

	// Room 2 security system
	if (current_us < 10 && last[3] > 10) {
		second_floor = true;
		if (current_servo[1] == "1") {
			servo.write(0);
			delay(2000);
			servo.write(90);
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
