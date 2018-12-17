/* --------------------------------------------------------------------------
 * SimpleOpenNI User Test
 * --------------------------------------------------------------------------
 * Processing Wrapper for the OpenNI/Kinect 2 library
 * http://code.google.com/p/simple-openni
 * --------------------------------------------------------------------------
 * prog:  Max Rheiner / Interaction Design / Zhdk / http://iad.zhdk.ch/
 * date:  12/12/2012 (m/d/y)
 * ----------------------------------------------------------------------------
 */

//esta es la parte de OSC

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress dest;
NetAddress dest2;


// data to send to wekinator
FloatList wings;

int numBones = 12;
int numUsers = 6;

PVector[][] usedBones = new PVector[numBones][numUsers];

import SimpleOpenNI.*;

SimpleOpenNI  context;
color[]       userClr = new color[]{ color(255, 0, 0), 
  color(0, 255, 0), 
  color(0, 0, 255), 
  color(255, 255, 0), 
  color(255, 0, 255), 
  color(0, 255, 255)
};

PVector com = new PVector();                                   
PVector com2d = new PVector();                                   

//int startLoop = 0;


void setup()
{
  //startLoop= millis();

  size(640, 480, P3D);

  context = new SimpleOpenNI(this);
  if (context.isInit() == false)
  {
    println("Can't init SimpleOpenNI, maybe the camera is not connected!"); 
    exit();
    return;
  }

  // enable depthMap generation 
  context.enableDepth();

  // enable skeleton generation for all joints
  context.enableUser();

  background(200, 0, 0);

  stroke(0, 0, 255);
  strokeWeight(3);
  smooth();  

  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this, 9000);
  dest = new NetAddress("192.168.2.30", 10000);
  dest2 = new NetAddress("192.168.0.144", 10000);

  //initialize the FloatList
  wings = new FloatList(4);

  for (int i = 0; i < numBones; i++) {
    for (int j = 0; j < numUsers; j++) {
      usedBones[i][j] = new PVector();
    }
  }


  //frameRate(12);
}



void draw()
{
  // update the cam
  context.update();

  // draw depthImageMap
  //image(context.depthImage(),0,0);
  image(context.userImage(), 0, 0);

  // draw the skeleton if it's available
  int[] userList = context.getUsers();
  for (int i=0; i<userList.length; i++)
  {
    if (context.isTrackingSkeleton(userList[i]))
    {
      stroke(userClr[ (userList[i] - 1) % userClr.length ] );
      drawSkeleton(userList[i]);

      if (userList.length == 1) {

        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_HEAD, usedBones[4][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, usedBones[5][0]);

        float distHand = PVector.dist(usedBones[0][0], usedBones[1][0]);
        float angleLeft = PVector.angleBetween(usedBones[0][0], usedBones[2][0]);
        float angleRigth = PVector.angleBetween(usedBones[1][0], usedBones[3][0]);
        float angleBody = PVector.angleBetween(usedBones[4][0], usedBones[5][0]);

        sendOsc(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody));
        println(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody), userList.length);
      } else if (userList.length == 2) {

        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_HEAD, usedBones[4][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, usedBones[5][0]);

        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_HEAD, usedBones[4][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_TORSO, usedBones[5][1]);

        float distHand = PVector.dist(usedBones[0][0], usedBones[1][0]);
        float angleLeft = PVector.angleBetween(usedBones[0][0], usedBones[2][0]);
        float angleRigth = PVector.angleBetween(usedBones[1][0], usedBones[3][0]);
        float angleBody = PVector.angleBetween(usedBones[4][0], usedBones[5][0]);

        float distHand2 = PVector.dist(usedBones[0][1], usedBones[1][1]);
        float angleLeft2 = PVector.angleBetween(usedBones[0][1], usedBones[2][1]);
        float angleRigth2 = PVector.angleBetween(usedBones[1][1], usedBones[3][1]);
        float angleBody2 = PVector.angleBetween(usedBones[4][1], usedBones[5][1]);

        distHand = (distHand + distHand2)/2;
        angleLeft = (angleLeft + angleLeft2)/2;
        angleRigth = (angleRigth + angleRigth2)/2;
        angleBody = (angleBody + angleBody2)/2;

        sendOsc(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody));

        println(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody), userList.length);
      } else if (userList.length == 3) {

        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_HEAD, usedBones[4][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, usedBones[5][0]);

        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_HEAD, usedBones[4][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_TORSO, usedBones[5][1]);

        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_HEAD, usedBones[4][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_TORSO, usedBones[5][2]);

        float distHand = PVector.dist(usedBones[0][0], usedBones[1][0]);
        float angleLeft = PVector.angleBetween(usedBones[0][0], usedBones[2][0]);
        float angleRigth = PVector.angleBetween(usedBones[1][0], usedBones[3][0]);
        float angleBody = PVector.angleBetween(usedBones[4][0], usedBones[5][0]);

        float distHand2 = PVector.dist(usedBones[0][1], usedBones[1][1]);
        float angleLeft2 = PVector.angleBetween(usedBones[0][1], usedBones[2][1]);
        float angleRigth2 = PVector.angleBetween(usedBones[1][1], usedBones[3][1]);
        float angleBody2 = PVector.angleBetween(usedBones[4][1], usedBones[5][1]);

        float distHand3 = PVector.dist(usedBones[0][2], usedBones[1][2]);
        float angleLeft3 = PVector.angleBetween(usedBones[0][2], usedBones[2][2]);
        float angleRigth3 = PVector.angleBetween(usedBones[1][2], usedBones[3][2]);
        float angleBody3 = PVector.angleBetween(usedBones[4][2], usedBones[5][2]);

        distHand = (distHand + distHand2 + distHand3)/3;
        angleLeft = (angleLeft + angleLeft2 + angleLeft3)/3;
        angleRigth = (angleRigth + angleRigth2 + angleRigth3)/3;
        angleBody = (angleBody + angleBody2 + angleBody3)/3;

        sendOsc(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody));

        println(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody), userList.length);
      } else if (userList.length == 4) {

        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_HEAD, usedBones[4][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, usedBones[5][0]);

        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_HEAD, usedBones[4][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_TORSO, usedBones[5][1]);

        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_HEAD, usedBones[4][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_TORSO, usedBones[5][2]);

        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_HEAD, usedBones[4][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_TORSO, usedBones[5][3]);

        float distHand = PVector.dist(usedBones[0][0], usedBones[1][0]);
        float angleLeft = PVector.angleBetween(usedBones[0][0], usedBones[2][0]);
        float angleRigth = PVector.angleBetween(usedBones[1][0], usedBones[3][0]);
        float angleBody = PVector.angleBetween(usedBones[4][0], usedBones[5][0]);

        float distHand2 = PVector.dist(usedBones[0][1], usedBones[1][1]);
        float angleLeft2 = PVector.angleBetween(usedBones[0][1], usedBones[2][1]);
        float angleRigth2 = PVector.angleBetween(usedBones[1][1], usedBones[3][1]);
        float angleBody2 = PVector.angleBetween(usedBones[4][1], usedBones[5][1]);

        float distHand3 = PVector.dist(usedBones[0][2], usedBones[1][2]);
        float angleLeft3 = PVector.angleBetween(usedBones[0][2], usedBones[2][2]);
        float angleRigth3 = PVector.angleBetween(usedBones[1][2], usedBones[3][2]);
        float angleBody3 = PVector.angleBetween(usedBones[4][2], usedBones[5][2]);

        float distHand4 = PVector.dist(usedBones[0][3], usedBones[1][3]);
        float angleLeft4 = PVector.angleBetween(usedBones[0][3], usedBones[2][3]);
        float angleRigth4 = PVector.angleBetween(usedBones[1][3], usedBones[3][3]);
        float angleBody4 = PVector.angleBetween(usedBones[4][3], usedBones[5][3]);

        distHand = (distHand + distHand2 + distHand3 + distHand4)/4;
        angleLeft = (angleLeft + angleLeft2 + angleLeft3 + angleLeft4)/4;
        angleRigth = (angleRigth + angleRigth2 + angleRigth3 + angleRigth4)/4;
        angleBody = (angleBody + angleBody2 + angleBody3 + angleBody4)/4;

        sendOsc(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody));

        println(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody), userList.length);
      } else if (userList.length == 5) {

        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_HEAD, usedBones[4][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, usedBones[5][0]);

        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_HEAD, usedBones[4][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_TORSO, usedBones[5][1]);

        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_HEAD, usedBones[4][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_TORSO, usedBones[5][2]);

        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_HEAD, usedBones[4][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_TORSO, usedBones[5][3]);

        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_HEAD, usedBones[4][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_TORSO, usedBones[5][4]);

        float distHand = PVector.dist(usedBones[0][0], usedBones[1][0]);
        float angleLeft = PVector.angleBetween(usedBones[0][0], usedBones[2][0]);
        float angleRigth = PVector.angleBetween(usedBones[1][0], usedBones[3][0]);
        float angleBody = PVector.angleBetween(usedBones[4][0], usedBones[5][0]);

        float distHand2 = PVector.dist(usedBones[0][1], usedBones[1][1]);
        float angleLeft2 = PVector.angleBetween(usedBones[0][1], usedBones[2][1]);
        float angleRigth2 = PVector.angleBetween(usedBones[1][1], usedBones[3][1]);
        float angleBody2 = PVector.angleBetween(usedBones[4][1], usedBones[5][1]);

        float distHand3 = PVector.dist(usedBones[0][2], usedBones[1][2]);
        float angleLeft3 = PVector.angleBetween(usedBones[0][2], usedBones[2][2]);
        float angleRigth3 = PVector.angleBetween(usedBones[1][2], usedBones[3][2]);
        float angleBody3 = PVector.angleBetween(usedBones[4][2], usedBones[5][2]);

        float distHand4 = PVector.dist(usedBones[0][3], usedBones[1][3]);
        float angleLeft4 = PVector.angleBetween(usedBones[0][3], usedBones[2][3]);
        float angleRigth4 = PVector.angleBetween(usedBones[1][3], usedBones[3][3]);
        float angleBody4 = PVector.angleBetween(usedBones[4][3], usedBones[5][3]);

        float distHand5 = PVector.dist(usedBones[0][4], usedBones[1][4]);
        float angleLeft5 = PVector.angleBetween(usedBones[0][4], usedBones[2][4]);
        float angleRigth5 = PVector.angleBetween(usedBones[1][4], usedBones[3][4]);
        float angleBody5 = PVector.angleBetween(usedBones[4][4], usedBones[5][4]);

        distHand = (distHand + distHand2 + distHand3 + distHand4 + distHand5)/5;
        angleLeft = (angleLeft + angleLeft2 + angleLeft3 + angleLeft4 + angleLeft5)/5;
        angleRigth = (angleRigth + angleRigth2 + angleRigth3 + angleRigth4 + angleRigth5)/5;
        angleBody = (angleBody + angleBody2 + angleBody3 + angleBody4 + angleBody5)/5;

        sendOsc(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody));

        println(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody), userList.length);
      } else if (userList.length == 6) {

        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_HEAD, usedBones[4][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, usedBones[5][0]);

        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_HEAD, usedBones[4][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_TORSO, usedBones[5][1]);

        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_HEAD, usedBones[4][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_TORSO, usedBones[5][2]);

        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_HEAD, usedBones[4][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_TORSO, usedBones[5][3]);

        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_HEAD, usedBones[4][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_TORSO, usedBones[5][4]);

        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_HEAD, usedBones[4][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_TORSO, usedBones[5][5]);

        float distHand = PVector.dist(usedBones[0][0], usedBones[1][0]);
        float angleLeft = PVector.angleBetween(usedBones[0][0], usedBones[2][0]);
        float angleRigth = PVector.angleBetween(usedBones[1][0], usedBones[3][0]);
        float angleBody = PVector.angleBetween(usedBones[4][0], usedBones[5][0]);

        float distHand2 = PVector.dist(usedBones[0][1], usedBones[1][1]);
        float angleLeft2 = PVector.angleBetween(usedBones[0][1], usedBones[2][1]);
        float angleRigth2 = PVector.angleBetween(usedBones[1][1], usedBones[3][1]);
        float angleBody2 = PVector.angleBetween(usedBones[4][1], usedBones[5][1]);

        float distHand3 = PVector.dist(usedBones[0][2], usedBones[1][2]);
        float angleLeft3 = PVector.angleBetween(usedBones[0][2], usedBones[2][2]);
        float angleRigth3 = PVector.angleBetween(usedBones[1][2], usedBones[3][2]);
        float angleBody3 = PVector.angleBetween(usedBones[4][2], usedBones[5][2]);

        float distHand4 = PVector.dist(usedBones[0][3], usedBones[1][3]);
        float angleLeft4 = PVector.angleBetween(usedBones[0][3], usedBones[2][3]);
        float angleRigth4 = PVector.angleBetween(usedBones[1][3], usedBones[3][3]);
        float angleBody4 = PVector.angleBetween(usedBones[4][3], usedBones[5][3]);

        float distHand5 = PVector.dist(usedBones[0][4], usedBones[1][4]);
        float angleLeft5 = PVector.angleBetween(usedBones[0][4], usedBones[2][4]);
        float angleRigth5 = PVector.angleBetween(usedBones[1][4], usedBones[3][4]);
        float angleBody5 = PVector.angleBetween(usedBones[4][4], usedBones[5][4]);

        float distHand6 = PVector.dist(usedBones[0][5], usedBones[1][5]);
        float angleLeft6 = PVector.angleBetween(usedBones[0][5], usedBones[2][5]);
        float angleRigth6 = PVector.angleBetween(usedBones[1][5], usedBones[3][5]);
        float angleBody6 = PVector.angleBetween(usedBones[4][5], usedBones[5][5]);

        distHand = (distHand + distHand2 + distHand3 + distHand4 + distHand5 + distHand6)/6;
        angleLeft = (angleLeft + angleLeft2 + angleLeft3 + angleLeft4 + angleLeft5 + angleLeft6)/6;
        angleRigth = (angleRigth + angleRigth2 + angleRigth3 + angleRigth4 + angleRigth5 + angleRigth6)/6;
        angleBody = (angleBody + angleBody2 + angleBody3 + angleBody4 + angleBody5 + angleBody6)/6;

        sendOsc(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody));

        println(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody), userList.length);
      } else if (userList.length == 6) {

        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_HEAD, usedBones[4][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, usedBones[5][0]);

        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_HEAD, usedBones[4][1]);
        context.getJointPositionSkeleton(userList[1], SimpleOpenNI.SKEL_TORSO, usedBones[5][1]);

        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_HEAD, usedBones[4][2]);
        context.getJointPositionSkeleton(userList[2], SimpleOpenNI.SKEL_TORSO, usedBones[5][2]);

        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_HEAD, usedBones[4][3]);
        context.getJointPositionSkeleton(userList[3], SimpleOpenNI.SKEL_TORSO, usedBones[5][3]);

        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_HEAD, usedBones[4][4]);
        context.getJointPositionSkeleton(userList[4], SimpleOpenNI.SKEL_TORSO, usedBones[5][4]);

        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_HEAD, usedBones[4][5]);
        context.getJointPositionSkeleton(userList[5], SimpleOpenNI.SKEL_TORSO, usedBones[5][5]);

        context.getJointPositionSkeleton(userList[6], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][6]);
        context.getJointPositionSkeleton(userList[6], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][6]);
        context.getJointPositionSkeleton(userList[6], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][6]);
        context.getJointPositionSkeleton(userList[6], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][6]);
        context.getJointPositionSkeleton(userList[6], SimpleOpenNI.SKEL_HEAD, usedBones[4][6]);
        context.getJointPositionSkeleton(userList[6], SimpleOpenNI.SKEL_TORSO, usedBones[5][6]);

        float distHand = PVector.dist(usedBones[0][0], usedBones[1][0]);
        float angleLeft = PVector.angleBetween(usedBones[0][0], usedBones[2][0]);
        float angleRigth = PVector.angleBetween(usedBones[1][0], usedBones[3][0]);
        float angleBody = PVector.angleBetween(usedBones[4][0], usedBones[5][0]);

        float distHand2 = PVector.dist(usedBones[0][1], usedBones[1][1]);
        float angleLeft2 = PVector.angleBetween(usedBones[0][1], usedBones[2][1]);
        float angleRigth2 = PVector.angleBetween(usedBones[1][1], usedBones[3][1]);
        float angleBody2 = PVector.angleBetween(usedBones[4][1], usedBones[5][1]);

        float distHand3 = PVector.dist(usedBones[0][2], usedBones[1][2]);
        float angleLeft3 = PVector.angleBetween(usedBones[0][2], usedBones[2][2]);
        float angleRigth3 = PVector.angleBetween(usedBones[1][2], usedBones[3][2]);
        float angleBody3 = PVector.angleBetween(usedBones[4][2], usedBones[5][2]);

        float distHand4 = PVector.dist(usedBones[0][3], usedBones[1][3]);
        float angleLeft4 = PVector.angleBetween(usedBones[0][3], usedBones[2][3]);
        float angleRigth4 = PVector.angleBetween(usedBones[1][3], usedBones[3][3]);
        float angleBody4 = PVector.angleBetween(usedBones[4][3], usedBones[5][3]);

        float distHand5 = PVector.dist(usedBones[0][4], usedBones[1][4]);
        float angleLeft5 = PVector.angleBetween(usedBones[0][4], usedBones[2][4]);
        float angleRigth5 = PVector.angleBetween(usedBones[1][4], usedBones[3][4]);
        float angleBody5 = PVector.angleBetween(usedBones[4][4], usedBones[5][4]);

        float distHand6 = PVector.dist(usedBones[0][5], usedBones[1][5]);
        float angleLeft6 = PVector.angleBetween(usedBones[0][5], usedBones[2][5]);
        float angleRigth6 = PVector.angleBetween(usedBones[1][5], usedBones[3][5]);
        float angleBody6 = PVector.angleBetween(usedBones[4][5], usedBones[5][5]);

        float distHand7 = PVector.dist(usedBones[0][6], usedBones[1][6]);
        float angleLeft7 = PVector.angleBetween(usedBones[0][6], usedBones[2][6]);
        float angleRigth7 = PVector.angleBetween(usedBones[1][6], usedBones[3][6]);
        float angleBody7 = PVector.angleBetween(usedBones[4][6], usedBones[5][6]);

        distHand = (distHand + distHand2 + distHand3 + distHand4 + distHand5 + distHand6 + distHand7)/7;
        angleLeft = (angleLeft + angleLeft2 + angleLeft3 + angleLeft4 + angleLeft5 + angleLeft6 + angleLeft7)/7;
        angleRigth = (angleRigth + angleRigth2 + angleRigth3 + angleRigth4 + angleRigth5 + angleRigth6 + angleRigth7)/7;
        angleBody = (angleBody + angleBody2 + angleBody3 + angleBody4 + angleBody5 + angleBody6 + angleBody7)/7;

        sendOsc(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody));

        println(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody), userList.length);
      } else {

        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HAND, usedBones[0][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HAND, usedBones[1][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_LEFT_HIP, usedBones[2][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_RIGHT_HIP, usedBones[3][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_HEAD, usedBones[4][0]);
        context.getJointPositionSkeleton(userList[0], SimpleOpenNI.SKEL_TORSO, usedBones[5][0]);

        float distHand = PVector.dist(usedBones[0][0], usedBones[1][0]);
        float angleLeft = PVector.angleBetween(usedBones[0][0], usedBones[2][0]);
        float angleRigth = PVector.angleBetween(usedBones[1][0], usedBones[3][0]);
        float angleBody = PVector.angleBetween(usedBones[4][0], usedBones[5][0]);

        sendOsc(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody));
        println(distHand, degrees(angleLeft), degrees(angleRigth), degrees(angleBody), userList.length);
      }
    }

    //// draw the center of mass
    //if (context.getCoM(userList[i], com))
    //{
    //  context.convertRealWorldToProjective(com, com2d);
    //  stroke(100, 255, 0);
    //  strokeWeight(1);
    //  beginShape(LINES);
    //  vertex(com2d.x, com2d.y - 5);
    //  vertex(com2d.x, com2d.y + 5);

    //  vertex(com2d.x - 5, com2d.y);
    //  vertex(com2d.x + 5, com2d.y);
    //  endShape();

    //  fill(0, 255, 100);
    //  text(Integer.toString(userList[i]), com2d.x, com2d.y);
    //}
  }
}

void sendOsc(float _dist, float _angleLeft, float _angleRigth, float _angleBody) {
  // this creat the Osc message
  OscMessage msg = new OscMessage("/inputs");
  //this decompress the FloatList and makes the Osc message

  msg.add(_dist);
  msg.add(_angleLeft);
  msg.add(_angleRigth);
  msg.add(_angleBody);

  //this send the message
  oscP5.send(msg, dest);
  //  oscP5.send(msg, dest2);
}
// draw the skeleton with the selected joints
void drawSkeleton(int userId)
{
  // to get the 3d joint data
  /*
  PVector jointPos = new PVector();
   context.getJointPositionSkeleton(userId,SimpleOpenNI.SKEL_NECK,jointPos);
   println(jointPos);
   */

  context.drawLimb(userId, SimpleOpenNI.SKEL_HEAD, SimpleOpenNI.SKEL_NECK);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_LEFT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_LEFT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_ELBOW, SimpleOpenNI.SKEL_LEFT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_NECK, SimpleOpenNI.SKEL_RIGHT_SHOULDER);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_RIGHT_ELBOW);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_ELBOW, SimpleOpenNI.SKEL_RIGHT_HAND);

  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_SHOULDER, SimpleOpenNI.SKEL_TORSO);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_SHOULDER, SimpleOpenNI.SKEL_TORSO);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_LEFT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_HIP, SimpleOpenNI.SKEL_LEFT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_LEFT_KNEE, SimpleOpenNI.SKEL_LEFT_FOOT);

  context.drawLimb(userId, SimpleOpenNI.SKEL_TORSO, SimpleOpenNI.SKEL_RIGHT_HIP);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_HIP, SimpleOpenNI.SKEL_RIGHT_KNEE);
  context.drawLimb(userId, SimpleOpenNI.SKEL_RIGHT_KNEE, SimpleOpenNI.SKEL_RIGHT_FOOT);
}

// -----------------------------------------------------------------
// SimpleOpenNI events

void onNewUser(SimpleOpenNI curContext, int userId)
{
  println("onNewUser - userId: " + userId);
  println("\tstart tracking skeleton");

  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId)
{

 // setup();
  println("onLostUser - userId: " + userId);
}

void onVisibleUser(SimpleOpenNI curContext, int userId)
{
  //println("onVisibleUser - userId: " + userId);
}


void keyPressed()
{
  switch(key)
  {
  case ' ':
    context.setMirror(!context.mirror());
    break;
  }
}  
