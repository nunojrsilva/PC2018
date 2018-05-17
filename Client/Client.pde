import controlP5.*;
import java.io.*;
import java.net.*;
import java.util.*;
import java.lang.Thread;

ControlP5 cp5;

String username = "";
String password = "";
Player player1;
ConnectionClient s;
String server_connection_status = "";

final int fields_height = 40;
final int textfield_width = 250;
final int button_width = 100;
final int spacing_size = 10;
final int server_connection_label_size = spacing_size*2 + button_width + textfield_width;

controlP5.Button login_button;
controlP5.Button new_account_button;
controlP5.Textfield username_textfield;
controlP5.Textfield password_textfield;
controlP5.Textlabel server_connection_label;

final int login_screen = 0;
final int game_screen = 1;
final int result_screen = 2;

int state = 0;


Creature creature;
Player player;
Assets assets;

void setup() {
//   fullScreen();
//   controlP5 = new ControlP5(this);
//   stroke(255);
//   creature = new Creature(height/2, width/2, 1, 1.0, 1.0);
//   player = new Player(0, 0, -HALF_PI/2, 1.0);
//   assets = new Assets();
// }

// void draw() {
//   background(0);
//   // line(150, 25, mouseX, mouseY);

//   player.update();
//   player.draw( assets );

//   creature.update();
//   creature.draw( assets );


// }

// void mousePressed() {
//   background(192, 64, 0);
// }

  fullScreen();
  pixelDensity(displayDensity());

  cp5 = new ControlP5(this);
  PFont font = createFont("Arial", 12);

  s = new ConnectionClient();
  s.connect();
  player1 = new Player();
  // while ( !s.connect() ){
  //   sleep(1000);
  // }

  username_textfield =  cp5.addTextfield( "Username" )
                           .setPosition( width/2 - spacing_size - textfield_width, height/2 - spacing_size - fields_height )
                           .setSize( textfield_width, fields_height )
                           .setFocus(true)
                           .setColorActive(color(255,0,0))
                           .setFont(font)
                           ;
  login_button = cp5.addButton( "Login" )
                    .setPosition( width/2 + spacing_size, height/2 - spacing_size - fields_height )
                    .setSize( button_width, fields_height )
                    .onClick( new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                       public void controlEvent(CallbackEvent theEvent) {
                         user = cp5.get(Textfield.class,"Username").getText();
                         pass = cp5.get(Textfield.class,"Password").getText();
                         c1.login(user,pass);

                         try{
                           String s = in.readLine();
                           println(s);
                           if(s.equals("ok_login")){
                             m = new Message(in,estado);
                             m.start();
                             cp5.hide();
                             state = game_screen;
                           }else{
                             login_fail=true;
                           }
                         }catch(Exception e){e.printStackTrace();}

                       }
                     })
                    ;
  password_textfield = cp5.addTextfield( "Password" )
                           .setPosition( width/2 - spacing_size - textfield_width, height/2 + spacing_size )
                           .setSize( textfield_width, fields_height)
                           .setFocus(true)
                           .setPasswordMode(true)
                           .setColorActive(color(255,0,0))
                           .setFont(font)
                           ;
  new_account_button = cp5.addButton( "New Account" )
                          .setPosition( width/2 + spacing_size, height/2 + spacing_size )
                          .setSize( button_width, fields_height )
                          ;
  server_connection_label = cp5.addTextlabel("Connection with server OK")
                               .setPosition(width/2, height/2 + 2*spacing_size + fields_height)
                               .setFont(font)
                               // setFont(createFont("Calibri",20))
                               ;
}

public

void draw() {
  switch(state){
    case login_screen:

      break;
    case game_screen:

      break;
    case result_screen:

      break;

    default:
      break;
  }

}

void login_screen(){

}
