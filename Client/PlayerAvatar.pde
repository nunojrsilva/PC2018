import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class PlayerAvatar {
  /****   CONSTANTS   ****/
  float frontAcceleration = 2.25;   // Quantidade aumentada à velocidade com propulsão
  float angularVelocity   = 0.55; // Quantidade alterada ao angulo
  float maxEnergy         = 20;  // Energy Maxima que pode ter
  float energyWaste       = 2.0;   // Quantidade de energia gasta com propulsão
  float energyGain        = 0.2; // Quantidade de energia gasta quando não hºa populsão
  float drag              = 0.1;  // Quantidade removida à velocidade com o tempo

  /***   ATTRIBUTES   ***/
  PVector position;     // Vetor de posição
  float   direction;    // Ângulo para onde se encontra virado
  float   velocity;     // Escalar
  float   energy;       // Energia atual
  float     type;         // 1 - Jogador. 2 - Oponente

  /*** INFORMATION FOR UPDATE ***/
  PVector positionOffset = new PVector(0,0);
  float   energyToAdd = 0;
  Lock l;

  PlayerAvatar(int type){
    this.type      = type;
    this.position  = new PVector();
    this.direction = 0;
    this.velocity  = 0;
    this.energy    = this.maxEnergy;
    this.l = new ReentrantLock();
  }

  PlayerAvatar(float posX, float posY, int type) {
    this.type = type;
    this.position  = new PVector(posX, posY);
    this.direction = 0;
    this.velocity  = 0;
    this.energy    = this.maxEnergy;
    this.l = new ReentrantLock();
  }

  PlayerAvatar(float posX, float posY, float direction, float velocity, float energy, float type, float frontAcceleration, float angularVelocity, float maxEnergy, float energyWaste, float energyGain, float drag, float size) {
    this.type = type;
    this.position  = new PVector(posX, posY);
    this.direction = direction;
    this.velocity  = velocity;
    this.energy    = energy;
    this.type      = type;
    this.frontAcceleration = frontAcceleration;
    this.angularVelocity   = angularVelocity;
    this.maxEnergy         = maxEnergy;
    this.energyWaste       = energyWaste;
    this.energyGain        = energyGain;
    this.drag              = drag;
    this.l = new ReentrantLock();
  }

  void update(float posX, float posY, float direction, float velocity, float energy, float type, float frontAcceleration, float angularVelocity, float maxEnergy, float energyWaste, float energyGain, float drag, float size) {
    this.l.lock();
    try {
      this.type = type;
      this.position  = new PVector(posX, posY);
      this.direction = direction;
      this.velocity  = velocity;
      this.energy    = energy;
      this.type      = type;
      this.frontAcceleration = frontAcceleration;
      this.angularVelocity   = angularVelocity;
      this.maxEnergy         = maxEnergy;
      this.energyWaste       = energyWaste;
      this.energyGain        = energyGain;
      this.drag              = drag;
    }finally{
      this.l.unlock();
    }
  }

  void prepareUpdate( PlayerAvatar otherPlayer, float interpolateBy) {

    // Repel from other player
    float distance = otherPlayer.position.dist( this.position );
    // direction is vector pointing AWAY from the player
    PVector direction = new PVector( this.position.x, this.position.y);
    direction.sub( otherPlayer.position );
    direction.normalize();
    this.positionOffset = direction.mult( (1/pow(distance,1.3)) * interpolateBy);

    PVector directionVector = PVector.fromAngle(this.direction);
    directionVector.mult( this.velocity * interpolateBy);
    this.positionOffset.add( directionVector );

  }

  /*
    Update without information
    Need information
  */
  void update( float interpolateBy ) {
    // Changes from the prepare update
    this.position.add( this.positionOffset );

    // Drag
    if(this.velocity > 0)
      this.velocity -= this.drag * interpolateBy ;
    else this.velocity = 0;


    this.energy += this.energyToAdd ;
    if(this.energy > this.maxEnergy) this.energy = this.maxEnergy;
    this.energy += this.energyGain * interpolateBy;
    if( this.energy > this.maxEnergy ) this.energy = this.maxEnergy;
  }

  void drawEnergy () {
     // draw outline box
     fill(255);
     strokeWeight(1);
     stroke(0,0,0);
     rect(10, 10, this.maxEnergy * 10, 30);
     print(this.energy + "\n");
     // draw energy box
     noStroke();
     fill( 255, 0, 0 );
     rect(12, 12, abs(this.energy * 10 - 4), 26);
  }

  void draw() {
    // Draw the object at position and rotated by the Direction.
    pushMatrix();
    // Vai para a posição do jogador
    translate(this.position.x, this.position.y);
    // Roda para a direção desejada
    rotate(this.direction);
    // Desenha o Avatar
    noStroke();
    if( type == 1 )
      fill(255,0,0);
    else
      fill(0,0,0);
    triangle(assets.playerSize/2 +20, 0,
             10, -20,
             10, 20);
    if(this.type == 1) image( assets.player0, -assets.playerSize/2, -assets.playerSize/2);
    else image(assets.player1,  -assets.playerSize/2, -assets.playerSize/2);
    popMatrix();
  }


}
