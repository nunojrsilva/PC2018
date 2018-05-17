

class Player {

  float force = 0.1;
  float maxEnergy = 10;
  float energyUse = 0.1;


  PVector position;
  PVector velocity;
  PVector acceleration;
  float direction; // Angle
  float speed;
  float energy = maxEnergy;

  Player( int   posX, int   posY, 
          float velX, float velY, 
          float accX, float accY, 
          float initialDirection, 
          float initialSpeed ) {
    this.position     = new PVector(posX, posY);
    this.velocity     = new PVector(velX, velY);
    this.acceleration = new PVector(accX, accY);
    this.direction    = initialDirection;
    this.speed        = initialSpeed;
  }

  Player( int posX, int posY, float initialDirection, float initalSpeed ){
    this.position     = new PVector(posX, posY);
    this.velocity     = new PVector(0, 1);
    this.velocity.rotate(initialDirection);
    this.acceleration = new PVector(0, 0);
    this.direction    = initialDirection;
    this.speed        = initalSpeed;
  }

  void update(){
    // this.velocity.add(this.acceleration).mult(this.energy);
    this.position.add(this.velocity);
  }

  void update( int   posX, int   posY, 
               float velX, float velY, 
               float accX, float accY, 
               float direction, 
               float speed ) {
    this.position     = new PVector(posX, posY);
    this.velocity     = new PVector(velX, velY);
    this.acceleration = new PVector(accX, accY);
    this.direction    = direction;
    this.speed        = speed;
  }

  void draw( Assets assets ) {
    pushMatrix();
    translate(this.position.x, this.position.y);
    rotate(-this.direction);
    image( assets.player, 0, 0);
    popMatrix();
  }
}
