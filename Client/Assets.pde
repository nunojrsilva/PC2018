

class Assets {

  PImage green;
  float greenSize = 0.1;

  PImage red;
  int redSizeX = 20;
  int redSizeY = 20;

  PImage player;
  float playerSize = 2;

  PImage background;

  Assets() {
    this.green = loadImage("./Assets/greenThings.png");
    this.green.resize(
      int( this.green.width  * this.greenSize ), 
      int( this.green.height * this.greenSize )
    );

    this.player = loadImage("./Assets/psa.png");
    this.player.resize( int(this.player.width * this.playerSize), int(this.player.height * this.playerSize));
  }
}
