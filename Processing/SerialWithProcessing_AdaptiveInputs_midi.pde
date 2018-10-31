// Gets serial port data (e.g. from Arduino) and sends to Wekinator
// By Rebecca Fiebrink: October 2017
// Includes public domain code adapted from Daniel Christopher 10/27/12 (instructables.com/id/Arduino-to-Processing-Serial-Communication-withou/)
// Sends to port 6448 using OSC message /wek/inputs
// Number of features varies according to number received via serial
//This patch expects to see each feature vector over serial, values separated by commas, ended with a newline

import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus


int channel = 0;
int pitch = 0;
int velocity = 127;

int number = 0;
int value = 90;

// escalas

// Matriz de escalas
// primera matriz: pentatónica menor C
// segunda matriz: mayor natural C
// tercera matriz: menor dorica C
// cuarta matriz: escala hexatona C
int scale = 0; //por defecto pentatonica menor
int notes[][] = {{0,3,5,7,10,12,15,17,19,22,24,27,29,31,34,36,39,41,43,46,48,51,53,55,58,60,63,65,67,70,72,75,77,79,82,84,87,89,91,94,96,99,101,103,106,108,111,113,115,118,120,123,125,127}
,{0,2,4,5,7,9,11,12,14,16,17,19,21,23,24,26,28,29,31,33,35,36,38,40,41,43,45,47,48,50,52,53,55,57,59,60,62,64,65,67,69,71,72,74,76,77,79,81,83,84,86,88,89,91,93,95,96,98,100,101,103,105,107,108,110,112,113,115,117,119,120,122,124,125,127}
,{0,2,3,5,7,9,10,12,14,15,17,19,21,22,24,26,27,29,31,33,34,36,38,39,41,43,45,46,48,50,51,53,55,57,58,60,62,63,65,67,69,70,72,74,75,77,79,81,82,84,86,87,89,91,93,94,96,98,99,101,103,105,106,108,110,111,113,115,117,118,120,122,123,125,127}
,{0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,64,66,68,70,72,74,76,78,80,82,84,86,88,90,92,94,96,98,100,102,104,106,108,110,112,114,116,118,120,122,124,126}}; 


//int strength[] = {0, 20, 40, 80, 127}; //mapping to select only few amount of velocities
int midicontrol [] = {20, 40, 60, 80, 90};


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


     if (Float.parseFloat(a[1])>15) {
       pitch = (int)map(Float.parseFloat(a[1]), 0, 950, 0, 4);
     } else {
       pitch = 0;
     }


    if (Float.parseFloat(a[1])>15) {
      velocity = 127; // (int)map(Float.parseFloat(a[2]), 0, 950, 0, 4);
    } else {
      velocity = 0;
    }
  


  myBus.sendNoteOn(channel, notes[pitch], velocity); // Send a Midi noteOn
  delay(200);
  //myBus.sendNoteOff(channel, pitch, velocity); // Send a Midi nodeOff


  if (Float.parseFloat(a[2])>15) {
    value = (int)map(Float.parseFloat(a[2]), 0, 950, 0, 4);
  } else {
    value = 0;
  }


  myBus.sendControllerChange(channel, number, midicontrol [value]); // Send a controllerChange
  //delay(2000);
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
