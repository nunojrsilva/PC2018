

Assets assets;
PlayState  state;



void setup() {
  size(1366, 768);
  assets = new Assets();
  state  = new PlayState( assets );
}

void draw() {
  background(assets.background);
  state.prepareUpdate();
  state.update();
  state.draw();
}

void keyReleased() {
  state.keyReleased();
}

void keyPressed() {
  state.keyPressed();
}
