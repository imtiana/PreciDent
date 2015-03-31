// I2C device class (I2Cdev) demonstration Processing sketch for MPU6050 DMP output
// 6/20/2012 by Jeff Rowberg <jeff@rowberg.net>
// Updates should (hopefully) always be available at https://github.com/jrowberg/i2cdevlib

import processing.serial.*;
import processing.opengl.*;
import toxi.geom.*;
import toxi.processing.*;

ToxiclibsSupport gfx;

Serial port;                         // The serial port
char[] teapotPacket = new char[14];  // InvenSense Teapot packet
int serialCount = 0;                 // current packet byte position
int synced = 0;
int interval = 0;
float[] rightShoulderTranslationVal = {35, -25, 52};
float[] leftShoulderTranslationVal = {-45, 5, -10};
float[] leftShoulderRotationVal = {0, 0, 0};
float[] rightShoulderRotationVal = {0, 0, 0};
//bad left shoulder posture {0.3, 0.05, -0.3}
//bad right shoulder posture {0.3, 0.05, 0.3}
float leftStrainValue = 0;
float rightStrainValue = 0;
int i = 0;

float[] q = new float[4];
Quaternion quat = new Quaternion(1, 0, 0, 0);

float[] gravity = new float[3];
float[] euler = new float[3];
float[] ypr = new float[3];

void setup() {
    // Screensize 300px square viewport using OpenGL rendering
    size(500, 500, OPENGL);
    gfx = new ToxiclibsSupport(this);

    // setup lights and antialiasing
    lights();
    smooth();
  
    // display serial port list for debugging/clarity
    println(Serial.list());

    // get the first available port (use EITHER this OR the specific port code below)
    //String portName = Serial.list()[0];
    
    // get a specific serial port (use EITHER this OR the first-available code above)
    String portName = "COM4";
    
    // open the serial port
    port = new Serial(this, portName, 115200);
    
    // send single character to trigger DMP init/start
    // (expected by MPU6050_DMP6 example Arduino sketch)
    port.write('r');
}

void draw() {
    if (millis() - interval > 1000) {
        // resend single character to trigger DMP init/start
        // in case the MPU is halted/reset while applet is running
        port.write('r');
        interval = millis();
    }
    
    // black background
    background(0);
    
    // translate everything to the middle of the viewport
    pushMatrix();
    translate(width / 2, height / 2 + 100);


    //static body
    pushMatrix();
    translate(0, 0, -125);
    rotateY(PI/2);
    rotateY(PI/6);
    rotateX(PI/8); // plane tilt
    fillRed();
    //box(200, 200, 1);
    rotateX(-PI/8);
    rotateY(-PI/2);
    rotateY(-PI/6);
    //rotateX(-PI/6);
     
    // 3-step rotation from yaw/pitch/roll angles (gimbal lock!)
    // ...and other weirdness I haven't figured out yet
    rotateY(-ypr[0]);
    rotateZ(-ypr[1]);
    rotateX(-ypr[2]);

    pushMatrix();
    // toxiclibs direct angle/axis rotation from quaternion (NO gimbal lock!)
    // (axis order [1, 3, 2] and inversion [-1, +1, +1] is a consequence of
    // different coordinate system orientation assumptions between Processing
    // and InvenSense DMP)
    float[] axis = quat.toAxisAngle();
    rotate(axis[0], -axis[1], axis[3], axis[2]);

    // torso
    //fill(250, 526, 170, 200); // color
    //box(80, 30, 200);
   
    //rotate on right axis
    rotateX(PI/2);
    rotateZ(PI/2);
    
    rotateX(-PI/2); // stand upright
    
//debugging rotations (without accelerometer data/frozen)
//rotateX(PI/2);
//rotateZ(PI/4);
    
    //upper body
    pushMatrix();
    fillClothesColor();
    translate(0, 50, -50);
    box(70, 30, 50);
    
    pushMatrix();
    
    //neck
    fillSkinColor(); 
    translate(0, 0, -45);
    rotateX(PI/2);
    drawCylinder(0, 20, 20, 8);
    rotateX(-PI/2);

    // head
    fillSkinColor(); 
    translate(0, 0, -20);
    box(50, 50, 50);
               
    // eyes
    pushMatrix();
    fill(0, 0, 0, 200);
    translate(-15, 25, 3); // across, depth, heigtht
    box(10, 10, 10);
    popMatrix();
 
    fill(0, 0, 0, 200);
    translate(10, 25, 3);
    box(10, 10, 10);

  //SHOULDER CODE
  //rotation values adjusted according to strain values
  leftShoulderTranslationVal[0] = leftStrainValue * 0.3;
  leftShoulderTranslationVal[1] = leftStrainValue * 0.05;
  leftShoulderTranslationVal[2] = leftStrainValue * -0.3;
  
  pushMatrix();
  fillClothesColor();
  translate(-10, -30, 62);
  translate(leftShoulderTranslationVal[0], leftShoulderTranslationVal[1], leftShoulderTranslationVal[2]); 
  rotateX(leftShoulderRotationVal[0]);
  rotateY(leftShoulderRotationVal[1]);
  rotateZ(leftShoulderRotationVal[2]);
  box(20, 30, 30);
  popMatrix();
  
  //rotation values adjusted according to strain values
  rightShoulderTranslationVal[0] = rightStrainValue * 0.3;
  rightShoulderTranslationVal[1] = rightStrainValue * 0.05;
  rightShoulderTranslationVal[2] = rightStrainValue * 0.3;
  
  pushMatrix();
  translate(rightShoulderTranslationVal[0], rightShoulderTranslationVal[1], rightShoulderTranslationVal[2]); 
  rotateX(rightShoulderRotationVal[0]);
  rotateY(rightShoulderRotationVal[1]);
  rotateZ(rightShoulderRotationVal[2]);
  box(20, 30, 30);
  popMatrix();
    
    
    popMatrix();
      
     // draw arms here 
     
    // draw wings and tail fin in green
    /*
    fill(250, 226, 170, 200);
    beginShape(TRIANGLES);
    vertex(-100,  2, 30); vertex(0,  2, -80); vertex(100,  2, 30);  // wing top layer
    vertex(-100, -2, 30); vertex(0, -2, -80); vertex(100, -2, 30);  // wing bottom layer
    vertex(-2, 0, 98); vertex(-2, -30, 98); vertex(-2, 0, 70);  // tail left layer
    vertex( 2, 0, 98); vertex( 2, -30, 98); vertex( 2, 0, 70);  // tail right layer
    endShape();
    beginShape(QUADS);
    vertex(-100, 2, 30); vertex(-100, -2, 30); vertex(  0, -2, -80); vertex(  0, 2, -80);
    vertex( 100, 2, 30); vertex( 100, -2, 30); vertex(  0, -2, -80); vertex(  0, 2, -80);
    vertex(-100, 2, 30); vertex(-100, -2, 30); vertex(100, -2,  30); vertex(100, 2,  30);
    vertex(-2,   0, 98); vertex(2,   0, 98); vertex(2, -30, 98); vertex(-2, -30, 98);
    vertex(-2,   0, 98); vertex(2,   0, 98); vertex(2,   0, 70); vertex(-2,   0, 70);
    vertex(-2, -30, 98); vertex(2, -30, 98); vertex(2,   0, 70); vertex(-2,   0, 70);
    endShape();
    */
    popMatrix();
    popMatrix();
    popMatrix();
    popMatrix();
}


void serialEvent(Serial port) {
    interval = millis();
    while (port.available() > 0) {
        int ch = port.read();

        if (synced == 0 && ch != '$') return;   // initial synchronization - also used to resync/realign if needed
        synced = 1;
        print ((char)ch);

        if ((serialCount == 1 && ch != 2)
            || (serialCount == 14 && ch != '\r') //MICHAEL: 12 without strain gauge data
            || (serialCount == 15 && ch != '\n'))  { //MICHAEL: 13 without strain gauge data
            serialCount = 0;
            synced = 0;
            return;
        }

        if (serialCount > 0 || ch == '$') {
            teapotPacket[serialCount++] = (char)ch;
            if (serialCount == 16) { //MICHAEL: 14 (without strain gauge data)
                serialCount = 0; // restart packet byte position
                
                // get quaternion from data packet
                q[0] = ((teapotPacket[2] << 8) | teapotPacket[3]) / 16384.0f;
                q[1] = ((teapotPacket[4] << 8) | teapotPacket[5]) / 16384.0f;
                q[2] = ((teapotPacket[6] << 8) | teapotPacket[7]) / 16384.0f;
                q[3] = ((teapotPacket[8] << 8) | teapotPacket[9]) / 16384.0f;
                leftStrainValue = teapotPacket[10]; //MICHAEL: assumed teapotPacket[10] is left strain gauge value
                rightStrainValue = teapotPacket[11];//MICHAEL: assumed teapotPacket[11] is right strain gauge value
                for (int i = 0; i < 4; i++) if (q[i] >= 2) q[i] = -4 + q[i];
                
                // set our toxilibs quaternion to new data
                quat.set(q[0], q[1], q[2], q[3]);

                /*
                // below calculations unnecessary for orientation only using toxilibs
                
                // calculate gravity vector
                gravity[0] = 2 * (q[1]*q[3] - q[0]*q[2]);
                gravity[1] = 2 * (q[0]*q[1] + q[2]*q[3]);
                gravity[2] = q[0]*q[0] - q[1]*q[1] - q[2]*q[2] + q[3]*q[3];
    
                // calculate Euler angles
                euler[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
                euler[1] = -asin(2*q[1]*q[3] + 2*q[0]*q[2]);
                euler[2] = atan2(2*q[2]*q[3] - 2*q[0]*q[1], 2*q[0]*q[0] + 2*q[3]*q[3] - 1);
    
                // calculate yaw/pitch/roll angles
                ypr[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
                ypr[1] = atan(gravity[0] / sqrt(gravity[1]*gravity[1] + gravity[2]*gravity[2]));
                ypr[2] = atan(gravity[1] / sqrt(gravity[0]*gravity[0] + gravity[2]*gravity[2]));
    
                // output various components for debugging
                //println("q:\t" + round(q[0]*100.0f)/100.0f + "\t" + round(q[1]*100.0f)/100.0f + "\t" + round(q[2]*100.0f)/100.0f + "\t" + round(q[3]*100.0f)/100.0f);
                //println("euler:\t" + euler[0]*180.0f/PI + "\t" + euler[1]*180.0f/PI + "\t" + euler[2]*180.0f/PI);
                //println("ypr:\t" + ypr[0]*180.0f/PI + "\t" + ypr[1]*180.0f/PI + "\t" + ypr[2]*180.0f/PI);
                */
            }
        }
    }
}

void drawCylinder(float topRadius, float bottomRadius, float tall, int sides) {
    float angle = 0;
    float angleIncrement = TWO_PI / sides;
    beginShape(QUAD_STRIP);
    for (int i = 0; i < sides + 1; ++i) {
        vertex(topRadius*cos(angle), 0, topRadius*sin(angle));
        vertex(bottomRadius*cos(angle), tall, bottomRadius*sin(angle));
        angle += angleIncrement;
    }
    endShape();
    
    // If it is not a cone, draw the circular top cap
    if (topRadius != 0) {
        angle = 0;
        beginShape(TRIANGLE_FAN);
        
        // Center point
        vertex(0, 0, 0);
        for (int i = 0; i < sides + 1; i++) {
            vertex(topRadius * cos(angle), 0, topRadius * sin(angle));
            angle += angleIncrement;
        }
        endShape();
    }
  
    // If it is not a cone, draw the circular bottom cap
    if (bottomRadius != 0) {
        angle = 0;
        beginShape(TRIANGLE_FAN);
    
        // Center point
        vertex(0, tall, 0);
        for (int i = 0; i < sides + 1; i++) {
            vertex(bottomRadius * cos(angle), tall, bottomRadius * sin(angle));
            angle += angleIncrement;
        }
        endShape();
    }
}

void drawSphere(double r, int lats, int longs) {
}

void fillSkinColor() {
   fill(255,224,189, 200);
}

void fillClothesColor() {
   fill(240,240,255, 200);
}

void fillRed() {
   fill(255,0,0, 200);
}
