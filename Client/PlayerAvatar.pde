

class PlayerAvatar {
  /****   CONSTANTS   ****/
  float frontAcceleration = 1;   // Quantidade aumentada à velocidade com propulsão
  float angularVelocity   = 0.1; // Quantidade alterada ao angulo
  float maxEnergy         = 20;  // Energy Maxima que pode ter
  float energyWaste       = 1;   // Quantidade de energia gasta com propulsão
  float energyGain        = 0.7; // Quantidade de energia gasta quando não hºa populsão
  float drag              = 0.5;  // Quantidade removida à velocidade com o tempo

  /***   ATTRIBUTES   ***/
  PVector position;     // Vetor de pusição
  float   direction;    // Ângulo para onde se encontra virado
  float   velocity;     // Escalar
  float   energy;       // Energia atual

  /*** INFORMATION FOR UPDATE ***/
  PVector positionOffset;
  float energyToAdd;
  boolean usedEnergy = false;

  PlayerAvatar( int posX, int posY ) {
    this.position  = new PVector(posX, posY);
    this.direction = 0;
    this.velocity  = 0;
    this.energy    = this.maxEnergy;
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
      this.direction -= this.angularVelocity;
      this.energy    -= this.energyWaste;
      this.usedEnergy = true;
    }
  }

  void turnLeft() {
    if( this.energy > this.energyWaste ){
      this.direction  += this.angularVelocity;
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
    distance = otherPlayer.position.dist( this.position );
    // direction is vector pointing AWAY from the player
    direction = new PVector( this.position.x, this.position.y);
    direction.sub( otherPlayer.position );
    this.positionOffset = direction.mult(distance);

    this.energyToAdd = extraEnergy;
  }

  /*
    Update without information
    Need information
  */
  void update( ) {
    // Changes from the prepare update
    this.position.add( this.poisitionOffset );

    // update position
    directionVector = new PVector( cos(this.direction), sin(this.direction) );
    directionVector.mag( this.velocity );
    this.position.add( directionVector );

    // Drag
    this.velocity -= this.drag;

    this.energy += this.energyToAdd;

    if(!usedEnergy)
      this.energy += this.energyGain;

    this.usedEnergy = false;
  }

  void draw( Assets assets ) {
    // Draw the object at position and rotated by the Direction.
    pushMatrix();
    // Vai para a posição do jogador
    translate(this.position.x, this.position.y);
    // Roda para a direção desejada
    rotate(-this.direction);
    // Desenha o Avatar
    image( assets.player, 0, 0);
    popMatrix();
  }


}
