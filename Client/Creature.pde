

class Creature {
  /***   CONSTANTS   ***/
  float velocity = 1;

  /***   ATTRIBUTES   ***/
  PVector position;
  PVector direction;
  PVector desiredDirection;
  int     type; // 0 for green 1 for red

  Creature(int type) {
    this.position = new PVector();
    this.direction = new PVector();
    this.desiredDirection = new PVector();
    this.type = type;
  }

  Creature( float posX, float posY, int type ) {
    this.position = new PVector(posX, posY);
    this.direction = new PVector(0,0);
    this.desiredDirection = new PVector(0,0);
    this.type = type;
  }

  void calcDirection() {
    this.direction.set( (this.direction.x + this.desiredDirection.x)/2, (this.direction.y + this.desiredDirection.y)/2);
    this.direction.normalize();
    this.direction.mult(this.velocity);
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

  void prepareUpdate( PlayerAvatar p1, PlayerAvatar p2 ) {
    this.calcDesiredDirection(p1,p2);
    this.calcDirection();
  }

  void update() {
    this.position.add(this.direction);
  }

  void draw(Assets assets) {
    if(this.type == 0) image(assets.green, this.position.x, this.position.y);
    else image(assets.red, this.position.x, this.position.y);
  }

}
