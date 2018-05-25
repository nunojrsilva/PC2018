import controlP5.*;
import java.io.*;
import java.net.*;
import java.util.*;
import java.lang.Thread;

ControlP5 cp5;
Group login;
Group game;
Group result;

int arenaWidth = 1200;
int arenaHeight = 800;

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

controlP5.Textlabel server_connection_label;

final int login_screen = 0;
final int game_screen = 1;
final int result_screen = 2;

int gameState = 0;

Assets assets;

void setup() {

  assets = new Assets();
  state = new PlayState(assets);
  fullScreen();
  // size(800,800);
  frameRate(40);
  pixelDensity( displayDensity() );

  cp5        = new ControlP5(this);
  login      = cp5.addGroup("login");
  game       = cp5.addGroup("game");
  result     = cp5.addGroup("result");
  PFont font = createFont("Arial", 12);

  try{
    socket = new Socket("localhost", 12345);
  }catch(Exception e){
    e.printStackTrace();
  }

  writeSocket = new Writer(socket);
  server_connection_status = writeSocket.connect();
  readSocket = new Reader(socket, state);
  if(!server_connection_status.equals("server offline") ){
    readSocket.connect();
  }

  cp5.addTextfield( "Username" )
                           .setPosition( width/2 - spacing_size - textfield_width, height/2 - spacing_size - fields_height )
                           .setSize( textfield_width, fields_height )
                           .setFocus(true)
                           .setColorActive(color(255,0,0))
                           .setFont(font)
                           .setGroup(login)
                           ;
  cp5.addButton( "Login" )
     .setPosition( width/2 + spacing_size, height/2 - spacing_size - fields_height )
     .setSize( button_width, fields_height )
     .onClick( new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                      public void controlEvent(CallbackEvent theEvent) {
                        username = cp5.get(Textfield.class,"Username").getText();
                        password = cp5.get(Textfield.class,"Password").getText();
                        writeSocket.login(username,password);
                        try{

                          if( server_connection_status.equals("Server offline") ){
                            writeSocket.connect();
                            readSocket.connect();
                          }else{
                            String m = readSocket.getMessage();
                            if( m.equals("login error") ){
                              server_connection_label.setValue("Login Error. Try again");
                              System.out.println("passou pelo erro de login no Client.pde");
                            }else if ( m.equals("login successful") ){
                              readSocket.setStatus(true);
                              cp5.hide();
                              gameState = game_screen;
                              readSocket.start();
                            }
                          }
                        } // closes try
                          catch(Exception e){
                            e.printStackTrace();
                          }



                      } // closes method
                    })
     .setGroup(login)
                    ;
  cp5.addTextfield( "Password" )
     .setPosition( width/2 - spacing_size - textfield_width, height/2 + spacing_size )
     .setSize( textfield_width, fields_height)
     .setPasswordMode(true)
     .setColorActive(color(255,0,0))
     .setFont(font)
     .setGroup(login)
                           ;
  cp5.addButton( "New Account" )
     .setPosition( width/2 + spacing_size, height/2 + spacing_size )
     .setSize( button_width, fields_height )
     .onClick( new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
                            public void controlEvent(CallbackEvent theEvent) {
                              username = cp5.get(Textfield.class,"Username").getText();
                              password = cp5.get(Textfield.class,"Password").getText();
                              writeSocket.createAccount(username,password);
                              try{
                                // readSocket.start.await();
                                // não funciona porque não ha controlo de acesso à variável do readSocket
                                  String m = readSocket.getMessage();
                                  if( m.equals("create_account error") ){
                                    server_connection_label.setText("").setValue("Account creation Error. Try again");
                                    System.out.println("passou pelo erro de create account no Client.pde");
                                  }else if( m.equals("create_account successful") ){
                                    readSocket.setStatus(true);
                                    gameState = game_screen;
                                    readSocket.start();
                                  }
                              }catch(Exception e){
                                e.printStackTrace();
                              }
                            }
                          })
     .setGroup(login)
                          ;
  server_connection_label = cp5.addTextlabel("Connecting to server")
                               .setPosition(width/2 - server_connection_label_size/2, height/2 + 2*spacing_size + fields_height)
                               // .setColor(100)
                               .setFont(font)
                               .setText("Connecting to server")
                               .setGroup(login)
                               // setFont(createFont("Calibri",20))
                               ;
cp5.addButton("END GAME")
   .
}

void draw() {
  switch(gameState){
    case login_screen:
      cp5.show();
      background(0);
      draw_login_screen();
      break;

    case game_screen:
      cp5.getGroup("login").hide();
      cp5.getGroup("result").hide();
      // background(0);
      cp5.getGroup("game").show();

      background(255);
      translate(width/2 - (arenaWidth/2), height/2 - (arenaHeight/2));
      image(assets.background,0,0);
      noFill();
      stroke(0);
      rect(0, 0, arenaWidth, arenaHeight);
      state.draw();
      break;

    case result_screen:
      cp5.getGroup("login").hide();
      cp5.getGroup("game").hide();
      background(0);
      cp5.getGroup("result").show();
      break;

    default:
      break;
  }

}

void draw_login_screen(){
  cp5.getGroup("game").hide();
  cp5.getGroup("result").hide();
  background(0);
  cp5.getGroup("login").show();
}

void draw_game_screen(){

}

void draw_result_screen(){

  // show_result_screen.
}
