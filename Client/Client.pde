import controlP5.*;
import java.io.*;
import java.net.*;
import java.util.*;
import java.lang.Thread;

ControlP5 cp5;

String username = "";
String password = "";
Socket socket;
Writer writeSocket;
Reader readSocket;
PlayState state;
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

Assets assets;

void setup() {

  assets = new Assets();

  // fullScreen();
  size(800,800);
  frameRate(40);
  pixelDensity( displayDensity() );

  cp5 = new ControlP5(this);
  PFont font = createFont("Arial", 12);

  try{
    socket = new Socket("localhost", 12345);
  }catch(Exception e){
    e.printStackTrace();
  }

  writeSocket = new Writer(socket);
  writeSocket.connect();
  readSocket = new Reader(socket, state);
  readSocket.start();

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
                         writeSocket.login(username,password);
                         try{
                            // if(!playState){
                            //   // server_connection_label.
                            // }
                            cp5.hide();
                            gameState = game_screen;
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
