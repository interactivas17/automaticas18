// Gets serial port data (e.g. from Arduino) and sends to Wekinator
// By Rebecca Fiebrink: October 2017
// Includes public domain code adapted from Daniel Christopher 10/27/12 (instructables.com/id/Arduino-to-Processing-Serial-Communication-withou/)
// Sends to port 6448 using OSC message /wek/inputs
// Number of features varies according to number received via serial
//This patch expects to see each feature vector over serial, values separated by commas, ended with a newline

import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus


import processing.serial.*;
import controlP5.*;
import java.util.*;
import oscP5.*;
import netP5.*;

//Objects for display:
ControlP5 cp5;
PFont fBig;
CColor defaultColor;

//Serial port info:
int end = 10;    // the number 10 is ASCII for linefeed (end of serial.println), later we will look for this to break up individual messages
String serial;   // declare a new string called 'serial' . A string is a sequence of characters (data type know as "char")
int numPorts = 0;
Serial myPort;  // The serial port
boolean gettingData = false; //True if we've selected a port to read from

//Objects for sending OSC
OscP5 oscP5;
NetAddress dest;

int numFeatures = 0;
String featureString = "";

void setup() {
  size(300, 250);
  frameRate(100);

  //Set up display
  cp5 = new ControlP5(this);
  textAlign(LEFT, CENTER);
  fBig = createFont("Arial", 12);

  //Populate serial port options:
  List l = Arrays.asList(Serial.list());
  numPorts = l.size();
  cp5.addScrollableList("Port") //Create drop-down menu
    .setPosition(10, 60)
    .setSize(200, 100)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(l)
    ;
  defaultColor = cp5.getColor();

  //Set up OSC:
  oscP5 = new OscP5(this, 9000); //This port isn't important (we're not receiving OSC)
  dest = new NetAddress("127.0.0.1", 6448); //Send to port 6448
  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.

  // Either you can
  //                   Parent In Out
  //                     |    |  |
  //myBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.

  // or you can ...
  //                   Parent         In                   Out
  //                     |            |                     |
  //myBus = new MidiBus(this, "IncomingDeviceName", "OutgoingDeviceName"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.

  // or for testing you could ...
  //                 Parent  In        Out
  //                   |     |          |
  myBus = new MidiBus(this, 0, 1); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
}

//Called when new port (n-th) selected in drop-down
void Port(int n) {
  // println(n, cp5.get(ScrollableList.class, "Port").getItem(n));
  CColor c = new CColor();
  c.setBackground(color(255, 0, 0));

  //Color all non-selected ports the default color in drop-down list
  for (int i = 0; i < numPorts; i++) {
    cp5.get(ScrollableList.class, "Port").getItem(i).put("color", defaultColor);
  }

  //Color the selected item red in drop-down list
  cp5.get(ScrollableList.class, "Port").getItem(n).put("color", c);

  //If we were previously receiving on a port, stop receiving
  if (gettingData) {
    myPort.stop();
  }

  //Finally, select new port:
  myPort = new Serial(this, Serial.list()[n], 9600); //Using 9600 baud rate
  myPort.clear(); //Throw out first reading, in case we're mid-feature vector
  gettingData = true;
  serial = null; //Initialise serial string
  numFeatures = 0;
}

//Called in a loop at frame rate (100 Hz)
void draw() {
  background(240);
  textFont(fBig);
  fill(0);
  text("Serial to OSC by Rebecca Fiebrink", 10, 10);
  text("Select serial port:", 10, 40);
  text("Sending " + numFeatures + " values to port 6448, message /wek/inputs", 10, 180); 
  text("Feature values:", 10, 200);
  text(featureString, 25, 220);

  if (gettingData) {
    getData();
  }

  //delay(1000);
}

//Parses serial data to get button & accel values, also buffers accels if we're in button-segmented mode
void getData() {
  while (myPort.available() > 0 ) { 
    serial = myPort.readStringUntil(end);
  }
  if (serial != null) {  //if the string is not empty, print the following

    /*  Note: the split function used below is not necessary if sending only a single variable. However, it is useful for parsing (separating) messages when
     reading from multiple inputs in Arduino. Below is example code for an Arduino sketch
     */

    String[] a = split(serial, ',');  //a new array (called 'a') that stores values into separate cells (separated by commas specified in your Arduino program)
    numFeatures = a.length;
    sendFeatures(a);

    int channel = 0;
    int pitch = (int)Float.parseFloat(a[1]);
    int velocity = (int)Float.parseFloat(a[2]);

    myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
    //delay(50);
    myBus.sendNoteOff(channel, pitch, velocity); // Send a Midi nodeOff
    int channel2 = 1;
    int number = (int)Float.parseFloat(a[1]);
    int value = (int)Float.parseFloat(a[2]);

     myBus.sendControllerChange(channel2, number, value); // Send a controllerChange
  }
}

void sendFeatures(String[] s) {
  OscMessage msg = new OscMessage("/wek/inputs");
  StringBuilder sb = new StringBuilder();
  try {
    for (int i = 0; i < s.length; i++) {
      float f = Float.parseFloat(s[i]); 
      msg.add(f);
      sb.append(String.format("%.2f", f)).append(" ");
    }
    oscP5.send(msg, dest);
    featureString = sb.toString();
  } 
  catch (Exception ex) {
    println("Encountered exception parsing string: " + ex);
  }
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void controllerChange(int channel, int number, int value) {
  // Receive a controllerChange
  println();
  println("Controller Change:");
  println("--------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
}

//void delay(int time) {
//  int current = millis();
//  while (millis () < current+time) Thread.yield();
//}
