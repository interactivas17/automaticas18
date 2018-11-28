// Code originally from http://www.instructables.com/id/Arduino-to-Processing-Serial-Communication-withou/
// by https://www.instructables.com/member/thelostspore/
// Code was shared under public domain https://creativecommons.org/licenses/publicdomain/

// This code reads analog inputs from pins A0 and A1 and sends these values out via serial
// You can add or remove pins to read from, but be sure they are separated by commas, and print a
// newline character at the end of each loop()

#define AnalogPin0 A0 //Declare an integer variable, hooked up to analog pin 0
#define AnalogPin1 A1 //Declare an integer variable, hooked up to analog pin 1
#define AnalogPin2 A2
#define AnalogPin3 A3 //Declare an integer variable, hooked up to analog pin 0
#define AnalogPin4 A4 //Declare an integer variable, hooked up to analog pin 1
#define AnalogPin5 A5
#define AnalogPin6 A6
#define AnalogPin7 A7

void setup() {
  Serial.begin(9600); //Begin Serial Communication with a baud rate of 9600
  delay(50);

}

void loop() {
  //New variables are declared to store the readings of the respective pins
  int Myo_0 = analogRead(AnalogPin0);
  int Myo_1 = analogRead(AnalogPin1);
  int Myo_2 = analogRead(AnalogPin2);
  int Myo_3 = analogRead(AnalogPin3);
  int Fforce_0 = analogRead(AnalogPin4);
  int Fforce_1 = analogRead(AnalogPin5);
  int Fforce_2 = analogRead(AnalogPin6);
  int Fforce_3 = analogRead(AnalogPin7);

  /*The Serial.print() function does not execute a "return" or a space
      Also, the "," character is essential for parsing the values,
      The comma is not necessary after the last variable.*/

  Serial.print(Myo_0, DEC);
  Serial.print(",");
  Serial.print(Myo_1, DEC);
  Serial.print(",");
  Serial.print(Myo_2, DEC);
  Serial.print(",");
  Serial.print(Myo_3, DEC);
  Serial.print(",");
  Serial.print(Fforce_0, DEC);
  Serial.print(",");
  Serial.print(Fforce_1, DEC);
  Serial.print(",");
  Serial.print(Fforce_2, DEC);
  Serial.print(",");
  Serial.print(Fforce_3, DEC);
  Serial.println();
  //delay(500); // For illustration purposes only. This will slow down your program if not removed
}
