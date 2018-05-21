import controlP5.*;
import java.io.*;
import java.net.*;
import java.util.*;
import java.lang.Thread;

ControlP5 cp5;

String username = "";
String password = "";
ConnectionClient outSocket;
Thread inSocket;
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

int gameState = 0;

State playState;
Assets assets;

void setup() {
//
//   creature = new Creature(height/2, width/2, 1, 1.0, 1.0);
//   player = new Player(0, 0, -HALF_PI/2, 1.0);
  assets = new Assets();
// }

// void draw() {
//   player.update();
//   player.draw( assets );

//   creature.update();
//   creature.draw( assets );


// }

  fullScreen();
  pixelDensity(displayDensity());

  cp5 = new ControlP5(this);
  PFont font = createFont("Arial", 12);

  outSocket = new ConnectionClient();
  outSocket.connect();

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
                         username = cp5.get(Textfield.class,"Username").getText();
                         password = cp5.get(Textfield.class,"Password").getText();
                         outSocket.login(username,password);

                         try{
                           String outSocket = in.readLine();
                           println(outSocket);
                           if(outSocket.equals("ok_login")){
                             m = new Message(in,estado);
                             m.start();
                             cp5.hide();
                             gameState = game_screen;
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


void draw() {
  switch(gameState){
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
