

class PlayState {
  PlayerAvatar thisPlayer;
  PlayerAvatar adversary;
  Creature[] greens;
  Creature[] reds;
  // Creature reds;
  
  JSONObject keys;

  int thisPlayerPoints;
  int adversaryPoints;
  
  PlayState () {
    this.thisPlayer = new PlayerAvatar( random(100, width-100), random(100, height - 100), 0);
    this.adversary  = new PlayerAvatar( random(100, width-100), random(100, height - 100), 1);
    
    this.greens = new Creature[2];
    this.greens[0] = new Creature(random(100, width-100), random(100, height - 100), 0);
    this.greens[1] = new Creature(random(100, width-100), random(100, height - 100), 0);
    
    this.reds = new Creature[2];
    this.reds[0] = new Creature(random(100, width-100), random(100, height - 100), 1);
    this.reds[1] = new Creature(random(100, width-100), random(100, height - 100), 1);

    this.thisPlayerPoints = 0;
    this.adversaryPoints  = 0;
   
     
    this.keys = new JSONObject();
    this.keys.setBoolean("w", false);
    this.keys.setBoolean("a", false);
    this.keys.setBoolean("d", false);
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
    
    this.reds[0].prepareUpdate(this.thisPlayer, this.adversary);
    this.reds[1].prepareUpdate(this.thisPlayer, this.adversary);
  }

  void update() {

    this.thisPlayer.update();
    this.adversary.update();
    
    this.greens[0].update();
    this.greens[1].update();
    
    this.reds[0].update();
    this.reds[1].update();
  }

  void draw() {
    // this.prepareUpdate();
    // this.update();
  
    // Draw
    this.greens[0].draw();
    this.greens[1].draw();
    
    this.reds[0].draw();
    this.reds[1].draw();
    
    this.thisPlayer.draw();
    this.adversary.draw();
    
    // for(red in this.reds) red.draw();
    this.thisPlayer.drawEnergy();
  }
}
