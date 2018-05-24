

class Assets {
  PImage background;

  PImage green;
  int greenSize = 30;

  PImage red;
  int redSize = 30;

  PImage player0;
  PImage player1;
  //float playerSize = 0.5;
  int playerSize = 70;

  Assets() {
    background = loadImage("./Assets/brickWall.png");
    background.resize(arenaWidth, arenaHeight);

    this.green = loadImage("./Assets/pepperoni.png");
    this.green.resize(this.greenSize, this.greenSize);
    
    this.red = loadImage("./Assets/ananas.png");
    this.red.resize(this.redSize, this.redSize);

    this.player0 = loadImage("./Assets/pizza1.png");
    // this.player.resize( int(this.player.width * this.playerSize), int(this.player.height * this.playerSize));
    this.player0.resize( this.playerSize, this.playerSize);
    
    this.player1 = loadImage("./Assets/pizza2.png");
    // this.player.resize( int(this.player.width * this.playerSize), int(this.player.height * this.playerSize));
    this.player1.resize( this.playerSize, this.playerSize);
    
  }
}
