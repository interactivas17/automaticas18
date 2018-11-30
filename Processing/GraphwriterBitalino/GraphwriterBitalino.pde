//////////////////////////////////////////////////////////////
// Analog signal graph writer for BITalino
// plots 6 analog signals, received through the 
// Bluetooth on /dev/tty.BITalino-DevB (or similar)
// samplerate has been fixed to 10 samples/sec (but can be 
// changed below) and all 6 available signals are sent
// 
// The screen can be paused using the spacebar
// pressing the space again resumes running
// 'c' clears the screen
// 'r' starts recording the values in a file
// 's' stops recording.
// everytime 'r' has been pressed a new
// file 'values1.txt' with consequetive number will be made
// (cc-by-sa) Edwin Dertien, 2016
//////////////////////////////////////////////////////////////
import processing.serial.*;
import oscP5.*;
import netP5.*;
//OSC and Net
NetAddress remote;
OscP5 oscP5;
String OscPacket;
PrintWriter output;
int lines = 6;
int PORTNUMBER = 3;
int scaling = 4;
char buffer[] = new char[8];
String outputBuff = "";
PFont fontA;
int linecolor[] = {0, 40, 80, 120, 160, 200, 240, 1}; //HSB color mode
int value[] = new int[lines];
int filenr;
int diffValue[] = new int[lines];
int NEWLINE = '\n';

int cursor1, cursor2;
int offset = 0;
float timescaling = 1;
float amplitude = 1;
String mode="RUN";
int n=21;
Serial port;
////////////////////////////////////////////////////////////////////////
void setup() {
  size(533, 286);
  println("Available serial ports:");
  //OSC
  oscP5 = new OscP5(this,12000);
  remote = new NetAddress("127.0.0.1", 5005);
  for (int i = 0; i<Serial.list ().length; i++){ 
    print("[" + i + "] ");
    println(Serial.list()[i]);
  }
  port = new Serial(this, Serial.list()[0], 115200);   //PUERTO BITALINO
  frameRate(20);  // delay of 50 ms, 20Hz update
  colorMode(HSB);
  fontA = loadFont("SansSerif-10.vlw");
  textFont(fontA, 10);
  //smooth();
  background(255);
  drawscreen();
  port.write(0);
  delay(50);
  int cmd = 3;  // 0 for 1 sample/sec, 1 for 10 samples/sec, 2 for 100 samples/sec, 3 for 1000 samples/sec
  port.write((cmd << 6) | 0x03); // 10 samples/sec 
  delay(50);
  int channelmask = 0x3F;
  port.write(channelmask<<2 | 0x01);
}
void draw() {
// serial handler:  
  while (port.available () > 0) {
    serialEvent(port.read()); // read data
  }
  outputBuff="" + millis();  // timestamp as first value in data file
// setup the screen
  stroke(255);
  fill(255);
  rect(300, 0, 100, 12);
  stroke(0);
  fill(0);
  text("time "+(millis()-500)/1000 +" s", 300, 12);
// draw the lines
  for (int z=0; z<lines; z++) {
    stroke(linecolor[z], 255, 255);
    line(n-1, (height-12-offset)-diffValue[z]/scaling, n, (height-12-offset)-value[z]/scaling); //draw line
    outputBuff += ("," + value[z]);
  }
  if (mode=="RECORD") {
    output.println(outputBuff); 
    print(".");                  // show in the box we're recording
  }
  if (mode!="PAUSE") n++;
  if (n>width) {                 // cursor at the end of the screen
    n=21;                        // start of the screen (allow space for legenda)
    background(255);             // clear screen
    drawscreen();
  }
  for (int z=0; z<lines; z++) {  // for drawing the line segments
    diffValue[z]=value[z];       // store previous values
  }
  
}

void drawscreen() {

  stroke(255, 0, 0);
  line(20, height-11, width, height-11);
  line(20, 13, width, 13);
  line(20, 0, 20, height);
  fill(255, 0, 0);
  text("0.0", 2, height-7+offset);
  text(nf(2.5/amplitude, 1, 1), 2, (height/2)+offset);
  text(nf(5.0/amplitude, 1, 1), 2, 23+offset);
  text("amplitude x "+nf(amplitude, 1, 1), 50, 12);
  text("time x "+nf(timescaling, 1, 1), 150, 12);
  text("offset "+offset+ " px", 220, 12);

  text("0 (s)", 21, height-1);
  for (int n=1; n<6; n++) {
    text(nf((5*n)/timescaling, 0, 0), 100*n+21, height-1);
  }
}

int counter;
void serialEvent(int serialdata) { 
  if (counter<7) {
    //print(serialdata);
    OscPacket+=str(serialdata)+',';
    //print(',');
    buffer[counter] = (char)serialdata;
    counter++;
  } else {
    
    //print(serialdata);
    buffer[counter] = (char)serialdata;
    print(OscPacket);
    counter = 0;
    // check CRC

    int crc = buffer[7] & 0x0F;
    buffer[7] &= 0xF0;  // clear CRC bits in frame
    int x = 0;
    for (int i = 0; i < 8; i++) {
      for (int bit = 7; bit >= 0; bit--){
        x <<= 1;
        if ((x & 0x10) > 0)  x = x ^ 0x03;
        x ^= ((buffer[i] >> bit) & 0x01);
      }
    }
    if (crc != (x & 0x0F))  println(" - crc mismatch");
    else {println(" - crc ok");
    value[0] = ((buffer[6] & 0x0F) << 6) | (buffer[5] >> 2);
    value[1] = ((buffer[5] & 0x03) << 8) | (buffer[4]);
    value[2] = ((buffer[3]       ) << 2) | (buffer[2] >> 6);
    value[3] = ((buffer[2] & 0x3F) << 4) | (buffer[1] >> 4);
    value[4] = ((buffer[1] & 0x0F) << 2) | (buffer[0] >> 6);
    value[5] = ((buffer[0] & 0x3F));    
      
    //Send OSC message
    OscMessage msg = new OscMessage("/vitalin/status");
    msg.add(OscPacket);
    oscP5.send(msg,remote);
    OscPacket="";
    }
  }
}

void keyPressed() {
  // toggle pause/run with spacebar
  if (key==' ' && mode=="RUN") mode="PAUSE";
  else if (key==' ' && mode=="PAUSE") mode="RUN";
  if (key=='r' && mode!="RECORD") {
    mode="RECORD";
    print("Start recording...");
    filenr++;
    output = createWriter("values"+filenr+".txt");
  }
  if (key=='s') {
    mode="STOP";
    println("ready!");
    output.flush(); // Write the remaining data
    output.close(); // Finish the file
  }
  if (key=='c') {
    n=0; 
    background(255);
  }
  if (key=='w') scaling -=0.1;
  if (key=='z') scaling +=0.1;
  if (key=='2') { // simulation!!
    int cmd = 1 ;
    port.write((cmd << 6) | 0x03); // 10 samples/sec 
    delay(50);
    int channelmask = 0x3F;
    port.write(channelmask<<2 | 0x02);
  } 
  if (key=='0') port.write(0); // stop!
  if (key=='1') { // real signals
    int cmd = 1;  // 0 for 1 sample/sec, 1 for 10 samples/sec, 2 for 100 samples/sec, 3 for 1000 samples/sec
    port.write((cmd << 6) | 0x03); // 10 samples/sec 
    delay(50);
    int channelmask = 0x3F;
    port.write(channelmask<<2 | 0x01);
  }
}
