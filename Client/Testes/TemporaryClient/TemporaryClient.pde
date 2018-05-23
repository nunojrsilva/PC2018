

Assets assets;
PlayState  state;

int arenaWidth = 1200;
int arenaHeight = 800;



void setup() {
  
  fullScreen();
  frameRate(40);
  
  assets = new Assets();
  state  = new PlayState( assets );
}

void draw() {
  background(assets.background);
  int stroke = 50;
  
  translate(width/2 - (arenaWidth/2) -stroke/2, height/2 - (arenaHeight/2) -stroke/2);
  noFill();
  stroke(0);
  strokeWeight(stroke);
  rect(0-stroke/2, 0-stroke/2, arenaWidth + stroke/2, arenaHeight + stroke/2); 
  
  state.prepareUpdate();
  state.update();
  state.draw();
}

//void keyReleased() {
//  state.keyReleased();
//}

//void keyPressed() {
//  state.keyPressed();
//}

void keyTyped() {
  state.keyTyped();
}
