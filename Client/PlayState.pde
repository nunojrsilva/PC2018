import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class PlayState {
  Assets assets;

  PlayerAvatar thisPlayer;
  PlayerAvatar adversary;
  ArrayList<Creature> greens;
  ArrayList<Creature> reds;
  // Creature reds;

  float thisPlayerPoints;
  float adversaryPoints;

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
    last_update_time = millis();
  }

  void update(PlayerAvatar a, PlayerAvatar b, ArrayList<Creature> green, ArrayList<Creature> red, float score1, float score2) {
    this.l.lock();
    try {
      this.thisPlayer = a;
      this.adversary  = b;

      this.greens = green;
      this.reds = red;

      this.thisPlayerPoints = score1;
      this.adversaryPoints  = score2;


      this.assets = assets;
    }finally{
      this.l.unlock();
    }
    last_update_time = millis();
  }

  void prepareUpdate(float interpolateBy) {
    // this.thisPlayer.processKeys( this.keys );

    this.thisPlayer.prepareUpdate( this.adversary, 0, interpolateBy);
    this.adversary.prepareUpdate( this.thisPlayer, 0, interpolateBy);
    this.greens.get(0).prepareUpdate(this.thisPlayer, this.adversary, interpolateBy);
    this.greens.get(1).prepareUpdate(this.thisPlayer, this.adversary, interpolateBy);

    for(Creature red: this.reds) {
      red.prepareUpdate(this.thisPlayer, this.adversary, interpolateBy);
    }

  }

  void update( float interpolateBy ) {

    this.thisPlayer.update(interpolateBy);
    this.adversary.update(interpolateBy);

    this.greens.get(0).update();
    this.greens.get(1).update();

    for(Creature red: this.reds) {
      red.update();
    }
  }


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

    this.thisPlayer.drawEnergy();
  }
}
