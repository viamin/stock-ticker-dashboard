#include <Arduino.h>
#include <Servo.h>

Servo bellServo;
const int strikePosition = 90;  // Angle for hitting the bell
const int restPosition = 0;     // Starting angle

void setup() {
  bellServo.attach(9);          // Attach servo to pin 9
  bellServo.write(restPosition); // Set to rest position
  delay(1000);                  // Wait for setup
}

void loop() {
  bellServo.write(strikePosition); // Move to strike position
  delay(100);                      // Short pause for striking
  bellServo.write(restPosition);   // Return to rest
  delay(1000);                     // Wait before striking again
}
