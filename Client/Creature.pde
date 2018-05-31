import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class Creature {
  /***   CONSTANTS   ***/
  float velocity = 1;

  /***   ATTRIBUTES   ***/
  PVector position;
  PVector direction;
  PVector desiredDirection;
  int   type; // 0 for green 1 for red

  Lock l;

  Creature(int type) {
    this.position         = new PVector();
    this.direction        = new PVector();
    this.desiredDirection = new PVector();
    this.type             = type;
    this.l = new ReentrantLock();
  }

  Creature( float posX, float posY, int type ) {
    this.position         = new PVector(posX, posY);
    this.direction        = new PVector(0,0);
    this.desiredDirection = new PVector(0,0);
    this.type             = type;
    this.l = new ReentrantLock();
  }

  Creature( float posX, float posY, float dirX, float dirY, float dx, float dy, float size, String type, float velocity ) {
    this.position         = new PVector(posX, posY);
    this.direction        = new PVector(dirX,dirY);
    this.desiredDirection = new PVector(dx,dy);
    if( type.equals("g") )
      this.type = 0;
    else
      this.type = 1;
    this.velocity         = velocity;
    this.l = new ReentrantLock();
  }

  void update( float posX, float posY, float dirX, float dirY, float dx, float dy, float size, String type, float velocity ) {
    this.position         = new PVector(posX, posY);
    this.direction        = new PVector(dirX,dirY);
    this.desiredDirection = new PVector(dx,dy);
    if( type.equals("g") == true )
      this.type = 0;
    else
      this.type = 1;
    this.velocity         = velocity;
    // this.l = new ReentrantLock();
  }

  void calcDirection(float interpolateBy) {
    this.direction.set( (this.direction.x + this.desiredDirection.x)/2, (this.direction.y + this.desiredDirection.y)/2);
    this.direction.normalize();
    this.direction.mult(this.velocity);
    this.direction.mult(interpolateBy);
  }

  void calcDesiredDirection( PlayerAvatar p1, PlayerAvatar p2) {
    // Get distances
    float d1 = this.position.dist(p1.position);
    float d2 = this.position.dist(p2.position);

    // compare and chose the closest
    if( d1 < d2 ) {
      this.desiredDirection = new PVector(p1.position.x, p1.position.y);
    } else {
      this.desiredDirection = new PVector(p2.position.x, p2.position.y);
    }

    // set desired direction pointing to the closest
    this.desiredDirection.sub(this.position);
    this.desiredDirection.normalize();
  }

  void prepareUpdate( PlayerAvatar p1, PlayerAvatar p2, float interpolateBy ) {
    this.calcDesiredDirection(p1,p2);
    this.calcDirection(interpolateBy);
  }

  void update() {
    this.position.add(this.direction);
  }

  void draw(Assets assets) {
    if(this.type == 0) image(assets.green, this.position.x, this.position.y);
    else image(assets.red, this.position.x, this.position.y);
  }

}
