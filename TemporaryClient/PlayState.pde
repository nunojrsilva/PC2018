

class PlayState {
  PlayerAvatar thisPlayer;
  PlayerAvatar adversary;
  Creature[] greens;
  ArrayList<Creature> reds;
  // Creature reds;

  JSONObject keys;

  int thisPlayerPoints;
  int adversaryPoints;

  int timeSlice = 0;

  PlayState (Assets assets) {
    this.thisPlayer = new PlayerAvatar( random(100, arenaWidth-100), random(100, arenaHeight - 100), 0);
    this.adversary  = new PlayerAvatar( random(100, arenaWidth-100), random(100, arenaHeight - 100), 1);

    this.greens = new Creature[2];
    this.greens[0] = new Creature(random(100, arenaWidth-100), random(100, arenaHeight - 100), 0);
    this.greens[1] = new Creature(random(100, arenaWidth-100), random(100, arenaHeight - 100), 0);

    this.reds = new ArrayList<Creature>();

    this.thisPlayerPoints = 0;
    this.adversaryPoints  = 0;


    this.keys = new JSONObject();
    this.keys.setBoolean("w", false);
    this.keys.setBoolean("a", false);
    this.keys.setBoolean("d", false);

    this.timeSlice = millis();
  }

  void keyTyped() {
    this.thisPlayer.keyTyped();
  }

  void keyReleased() {
    String k = ""+key;
     if( !this.keys.isNull(k) ) {
       this.keys.setBoolean(k, false );
     }
  }
  void keyPressed() {
     String k = ""+key;
     if( !this.keys.isNull(k) ) {
       this.keys.setBoolean(k, true );
     }
  }

  void prepareUpdate() {
    // this.thisPlayer.processKeys( this.keys );

    this.thisPlayer.prepareUpdate( this.adversary, 0 );
    this.adversary.prepareUpdate( this.thisPlayer, 0 );

    this.greens[0].prepareUpdate(this.thisPlayer, this.adversary);
    this.greens[1].prepareUpdate(this.thisPlayer, this.adversary);

    for(Creature red: this.reds) {
      red.prepareUpdate(this.thisPlayer, this.adversary);
    }
  }
  void updateRedsList() {
    int currentMillis = millis();
    print(currentMillis + "\n");
    //print(millis() - this.timeSlice + "\n");
    if( currentMillis - this.timeSlice > 10000) {
      print("Created new creature.\n");
      this.reds.add( new Creature(random(100, arenaWidth-100), random(100, arenaHeight - 100), 1) );
      this.timeSlice = currentMillis;
    }
  }

  void update() {

    this.thisPlayer.update();
    this.adversary.update();

    this.greens[0].update();
    this.greens[1].update();

    for(Creature red: this.reds) {
      red.update();
    }

    this.updateRedsList();
  }

  void draw() {
    // Draw
    this.greens[0].draw();
    this.greens[1].draw();

    for(Creature red: this.reds) {
      red.draw(this.assets);
    }

    this.thisPlayer.draw();
    this.adversary.draw();

    // for(red in this.reds) red.draw();
    this.thisPlayer.drawEnergy();
  }
}
