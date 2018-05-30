import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class PlayState {
  Assets assets;

  PlayerAvatar thisPlayer;
  PlayerAvatar adversary;
  ArrayList<Creature> greens;
  ArrayList<Creature> reds;
  // Creature reds;

  JSONObject keys;

  float thisPlayerPoints;
  float adversaryPoints;

  int timeSlice = 0;
  Lock l;

  PlayState (Assets assets) {
    this.thisPlayer = new PlayerAvatar(0);
    this.adversary  = new PlayerAvatar(1);

    this.greens = new ArrayList<Creature>();
    this.greens.add(new Creature(0));
    this.greens.add(new Creature(0));

    this.reds = new ArrayList<Creature>();

    this.thisPlayerPoints = 0;
    this.adversaryPoints  = 0;

    this.assets = assets;

    this.keys = new JSONObject();
    this.keys.setBoolean("w", false);
    this.keys.setBoolean("a", false);
    this.keys.setBoolean("d", false);

    this.timeSlice = millis();
    this.l = new ReentrantLock();
  }

  PlayState (PlayerAvatar a, PlayerAvatar b, ArrayList<Creature> green, ArrayList<Creature> red, float score1, float score2) {
    this.thisPlayer = a;
    this.adversary  = b;

    this.greens = green;

    this.reds = red;

    this.thisPlayerPoints = score1;
    this.adversaryPoints  = score2;

    this.assets = assets;

    this.keys = new JSONObject();
    this.keys.setBoolean("w", false);
    this.keys.setBoolean("a", false);
    this.keys.setBoolean("d", false);

    this.timeSlice = millis();
  }
  void update(PlayerAvatar a, PlayerAvatar b, Creature[] green, ArrayList<Creature> red, float score1, float score2) {
    this.thisPlayer = a;
    this.adversary  = b;

    this.greens = green;

    this.reds = red;

    this.thisPlayerPoints = score1;
    this.adversaryPoints  = score2;

    this.assets = assets;

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

  // void updatePlayer1(PlayerAvatar p){
  //   this.thisPlayer.update(p);
  // }
  //
  // void updatePlayer2(PlayerAvatar p){
  //   this.thisPlayer.update(p);
  // }

  void prepareUpdate() {
    // this.thisPlayer.processKeys( this.keys );

    this.thisPlayer.prepareUpdate( this.adversary, 0 );
    this.adversary.prepareUpdate( this.thisPlayer, 0 );

    this.greens.get(0).prepareUpdate(this.thisPlayer, this.adversary);
    this.greens.get(1).prepareUpdate(this.thisPlayer, this.adversary);

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

    this.greens.get(0).update();
    this.greens.get(1).update();

    for(Creature red: this.reds) {
      red.update();
    }

    this.updateRedsList();
  }

  // PlayerAvatar getPlayer1(){
  //   return this.thisPlayer;
  // }
  //
  // PlayerAvatar getPlayer2(){
  //   return this.adversary;
  // }

  float getScore1(){
    return this.thisPlayerPoints;
  }

  float getScore2(){
    return this.adversaryPoints;
  }

  void draw() {
    // Draw
    this.greens.get(0).draw(this.assets);
    this.greens.get(1).draw(this.assets);

    for(Creature red: this.reds) {
      red.draw(this.assets);
    }

    this.thisPlayer.draw(this.assets);
    this.adversary.draw(this.assets);

    // for(red in this.reds) red.draw();
    this.thisPlayer.drawEnergy();
  }
}
