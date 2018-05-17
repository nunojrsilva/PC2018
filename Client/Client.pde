import controlP5.*;
ControlP5 controlP5;

Creature creature;
Player player;
Assets assets;

void setup() {
  fullScreen();
  controlP5 = new ControlP5(this);
  stroke(255);
  creature = new Creature(height/2, width/2, 1, 1.0, 1.0);
  player = new Player(0, 0, -HALF_PI/2, 1.0);
  assets = new Assets();
}

void draw() {
  background(0);
  // line(150, 25, mouseX, mouseY);

  player.update();
  player.draw( assets );

  creature.update();
  creature.draw( assets );


}

// void mousePressed() {
//   background(192, 64, 0);
// }
