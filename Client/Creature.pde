

class Creature {
  // Classwise Atributes
  PImage green;
  // PImage red = loadImage("Assets/red.png");
  int GREEN = 0;
  int RED = 1;
  int sizeX = 20;
  int sizeY = 20;
  float speed = 1;
  float noiseX = 0.0;
  float noiseY = 0.0;

  // Instance Attributes
  int type;
  PVector position;
  PVector velocity;

  Creature ( int posX, int posY, int type, float velX, float velY ) {
    this.position = new PVector(posX, posY);
    this.velocity = new PVector(velX, velY);
    this.type = type;
  }

  int    getType() { return this.type; }
  float  getSpeed() { return this.speed;}

  void update( ) {
    // Calc direction 
    // Calc position
  }

  void update( int posX, int posY, int type, float velX, float velY) {
    this.position = new PVector(posX, posY);
    this.velocity = new PVector(velX, velY);
    this.type = type;
  }

  void draw( Assets assets ) {
    // Funcion responsible for drawing the creatures
    if( type == GREEN ) {
      // draw at posX posY with sizeX sizeY
    } else { // type == RED
      // draw at posX posY with sizeX sizeY
    }
    image( assets.green , this.position.x, this.position.y );
  }

}
