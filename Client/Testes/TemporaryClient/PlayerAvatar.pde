

class PlayerAvatar {
  /****   CONSTANTS   ****/
  float frontAcceleration = 0.25;   // Quantidade aumentada à velocidade com propulsão
  float angularVelocity   = 0.05; // Quantidade alterada ao angulo
  float maxEnergy         = 20;  // Energy Maxima que pode ter
  float energyWaste       = 0.15;   // Quantidade de energia gasta com propulsão
  float energyGain        = 0.5; // Quantidade de energia gasta quando não hºa populsão
  float drag              = 0.1;  // Quantidade removida à velocidade com o tempo

  /***   ATTRIBUTES   ***/
  PVector position;     // Vetor de pusição
  float   direction;    // Ângulo para onde se encontra virado
  float   velocity;     // Escalar
  float   energy;       // Energia atual
  int type;             // 0 - Jogador. 1 - Oponente

  /*** INFORMATION FOR UPDATE ***/
  PVector positionOffset = new PVector(0,0);
  float energyToAdd = 0;
  boolean usedEnergy = false;

  PlayerAvatar( float posX, float posY, int type) {
    this.type = type;
    this.position  = new PVector(posX, posY);
    this.direction = 0;
    this.velocity  = 0.01;
    this.energy    = this.maxEnergy;
  }
  
  void processKeys(JSONObject keys ) {
    // key is a Processing variable
    if( this.energy > this.energyWaste ) {
      if( keys.getBoolean("w") ) {
        this.accelerateForward();
      }
      if( keys.getBoolean("d") ) {  
         this.turnRight();
      }
      if( keys.getBoolean("a") ) {
         this.turnLeft();
      }
    }
  }

  void accelerateForward() {
    if( this.energy > this.energyWaste ){
      this.velocity  += this.frontAcceleration;
      this.energy    -= this.energyWaste;
      this.usedEnergy = true;
    }
  }

  void turnRight() {
    if( this.energy > this.energyWaste ){
      this.direction += this.angularVelocity;
      this.energy    -= this.energyWaste;
      this.usedEnergy = true;
    }
  }

  void turnLeft() {
    if( this.energy > this.energyWaste ){
      this.direction  -= this.angularVelocity;
      this.energy     -= this.energyWaste;
      this.usedEnergy = true;
    }
  }

  /** Receives info from server **/
  void update( int posX, int posY, float direction, float velocity, float energy ) {
    this.position.set(posX, posY);
    this.direction = direction;
    this.velocity  = velocity;
    this.energy    = energy;
  }

  void prepareUpdate( PlayerAvatar otherPlayer, float extraEnergy ) {
    // Repel from other player 
    float distance = otherPlayer.position.dist( this.position );
    // direction is vector pointing AWAY from the player
    PVector direction = new PVector( this.position.x, this.position.y);
    direction.sub( otherPlayer.position );
    direction.normalize();
    this.positionOffset = direction.mult( 1/pow(distance,0.3) );
      
    this.energyToAdd = extraEnergy;
   
  }

  /*
    Update without information
    Need information
  */
  void update( ) {
    // Changes from the prepare update
    this.position.add( this.positionOffset );

    // update position
    PVector directionVector = new PVector( cos(this.direction), sin(this.direction) );
    directionVector.mult( this.velocity );
    this.position.add( directionVector );

    // Drag
    if(this.velocity > 0)
      this.velocity -= this.drag;
    else this.velocity = 0;
  
     
    this.energy += this.energyToAdd;
    if(this.energy > this.maxEnergy) this.energy = this.maxEnergy;
    if(!usedEnergy)
      this.energy += this.energyGain;
      if( this.energy > this.maxEnergy ) this.energy = this.maxEnergy;

    this.usedEnergy = false;
  }
  
  void drawEnergy () {
     // draw outline box
     print(this.energy);
     print("\n");
     fill(255);
     strokeWeight(1);
     stroke(0,0,0);
     rect(10, 10, this.maxEnergy * 10, 30);
     
     // draw energy box
     noStroke();
     fill( 255, 0, 0 );
     rect(12, 12, abs(this.energy * 10 - 4), 26);
  }

  void draw( Assets assets ) {
    // Draw the object at position and rotated by the Direction.
    pushMatrix();
    // Vai para a posição do jogador
    translate(this.position.x, this.position.y);
    // Roda para a direção desejada
    rotate(this.direction);
    // Desenha o Avatar
    triangle(assets.playerSize/2 +20, 0,
             10, -20,
             10, 20);
    if(this.type == 0) image( assets.player0, -assets.playerSize/2, -assets.playerSize/2);
    else image(assets.player1,  -assets.playerSize/2, -assets.playerSize/2);
    popMatrix();
  }


}
