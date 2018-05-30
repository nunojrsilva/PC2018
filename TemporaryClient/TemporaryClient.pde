

Assets assets;
PlayState  state;

int arenaWidth = 1200;
int arenaHeight = 800;



void setup() {
  
  fullScreen();
  frameRate(40);
  
  assets = new Assets();
  state  = new PlayState();
}

void draw() {
  background(255);
  translate(width/2 - (arenaWidth/2), height/2 - (arenaHeight/2));
  image(assets.background,0,0);
  noFill();
  stroke(0);
  rect(0, 0, arenaWidth, arenaHeight); 
  
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
