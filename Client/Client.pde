import controlP5.*;
ControlP5 controlP5;

void setup() {
       size(500, 500);
       controlP5 = new ControlP5(this);
       stroke(255);
     }

     void draw() {
       line(150, 25, mouseX, mouseY);
     }

     void mousePressed() {
       background(192, 64, 0);
     }
