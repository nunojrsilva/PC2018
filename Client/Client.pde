import controlP5.*;
import java.io.*;
import java.net.*;
import java.util.*;
import java.lang.Thread;

ControlP5 cp5;
Group login;
Group game;
Group result;
Group label;

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
final int waiting_screen = 1;
final int game_screen = 2;
final int result_screen = 3;

int gameState = 0;

Assets assets;

void setup() {

  assets = new Assets();
  state = new PlayState(assets);
  fullScreen();
  // size(800,800);
  frameRate(60);
  pixelDensity( displayDensity() );

  cp5        = new ControlP5(this);
  login      = cp5.addGroup("login");
  game       = cp5.addGroup("game");
  result     = cp5.addGroup("result");
  label      = cp5.addGroup("label");
  PFont font = createFont("Arial", 12);

  connect();

  cp5.addTextfield( "Username" )
     .setGroup(login)
     .setPosition( width/2 - spacing_size - textfield_width, height/2 - spacing_size - fields_height )
     .setSize( textfield_width, fields_height )
     .setFocus(true)
     .setColorActive(color(255,0,0))
     .setFont(font)
     ;
  cp5.addButton( "Login" )
     .setGroup(login)
     .setPosition( width/2 + spacing_size, height/2 - spacing_size - fields_height )
     .setSize( button_width, fields_height )
     .onClick( new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
        public void controlEvent(CallbackEvent theEvent) {
          username = cp5.get(Textfield.class,"Username").getText();
          password = cp5.get(Textfield.class,"Password").getText();
          server_connection_label.setValue(server_connection_status);
          try{
            if( !connect() ){
              server_connection_label.setText("Server offline");
            }else if( socket.isConnected() ){
              if( username.equals("") || password.equals("") ){
                server_connection_label.setValue("Account credentials must not be blank");
              }else{

                writeSocket.login(username,password);
                String m = readSocket.getMessage();
                if( m.equals("login error") ){
                  server_connection_label.setValue("Login Error. Try again");
                  System.out.println("passou pelo erro de login no Client.pde");
                }else if ( m.equals("login successful") ){
                  readSocket.start();
                  server_connection_label.setText("Waiting for your oponent").show();
                  gameState = waiting_screen;

                }
              }

            }// if not offline
          } // closes try
            catch(Exception e){
              e.printStackTrace();
            }



        } // closes method
      })
   ;
  cp5.addTextfield( "Password" )
     .setGroup(login)
     .setPosition( width/2 - spacing_size - textfield_width, height/2 + spacing_size )
     .setSize( textfield_width, fields_height)
     .setPasswordMode(true)
     .setColorActive(color(255,0,0))
     .setFont(font)
     ;
  cp5.addButton( "New Account" )
     .setGroup(login)
     .setPosition( width/2 + spacing_size, height/2 + spacing_size )
     .setSize( button_width, fields_height )
     .onClick( new CallbackListener() { //Eventhandler do botao da pagina inicial main_screen
       public void controlEvent(CallbackEvent theEvent) {
         username = cp5.get(Textfield.class,"Username").getText();
         password = cp5.get(Textfield.class,"Password").getText();

         try{
           if( !connect() ){
             server_connection_label.setText("Server offline");
           }else if( socket.isConnected() ){

             if( username.equals("") || password.equals("") ){
               server_connection_label.setValue("Account credentials must not be blank");
             }else{

               writeSocket.createAccount(username,password);
               String m = readSocket.getMessage();
               if( m.equals("create_account error") ){
                 server_connection_label.setValue("Account creation Error. Try again");
               }else if( m.equals("create_account successful") ){
                 readSocket.start();
                 server_connection_label.setText("Waiting for your oponent").show();
                 gameState = waiting_screen;
               }

             }


           }// if not offline
         }catch(Exception e){
           e.printStackTrace();
         }
       }
      })
     ;
  server_connection_label = cp5.addTextlabel("serverlabel")
                               .setGroup("label")
                               .setPosition(width/2 - server_connection_label_size/2, height/2 + 2*spacing_size + fields_height)
                               .setFont(font)
                               .setText("Connecting to server")
                               ;
  cp5.addButton("END GAME")
     .setGroup("game")
     .setPosition(width/2 - button_width/2, arenaHeight + spacing_size )
     .setSize( button_width, fields_height )
     .onClick( new CallbackListener() {
        public void controlEvent(CallbackEvent theEvent) {
          writeSocket.send("quit");
          print("QUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\nQUIT GAME SENTTTTTTTTTTTTTT\n");
          gameState = result_screen;

        }
     })
     ;
  cp5.addTextlabel("Result Screen")
     .setGroup("result")
     .setPosition( width/2 - (arenaWidth/2), height/2 - (arenaHeight/2) )
     .setSize( arenaWidth, arenaHeight)
     .setFont(font);
     ;
  cp5.addButton("NEW GAME")
    .setGroup("result")
    .setPosition(width/2 - button_width/2, arenaHeight + spacing_size )
    .setSize( button_width, fields_height )
    .onClick( new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        writeSocket.login(username, password);
        gameState = waiting_screen;
       }
    })
    ;
}

void draw() {
  switch(gameState){
    case login_screen:
      draw_login_screen();
      break;

    case waiting_screen:
      draw_waiting_screen();
      break;

    case game_screen:
      draw_game_screen();
      break;

    case result_screen:
      draw_result_screen();
      break;

    default:
      break;
  }

}

void draw_login_screen(){
  cp5.show();
  background(0);
  cp5.getGroup("game").hide();
  cp5.getGroup("result").hide();
  background(0);
  cp5.getGroup("login").show();
}

void draw_game_screen(){
  cp5.getGroup("login").hide();
  cp5.getGroup("result").hide();
  cp5.getGroup("label").hide();
  background(0);

  translate(width/2 - (arenaWidth/2), height/2 - (arenaHeight/2));
  image(assets.background,0,0);
  noFill();
  stroke(0);
  rect(0, 0, arenaWidth, arenaHeight);

  state.l.lock();
  try{
    state.prepareUpdate();
    state.update();
    state.draw();
  } catch (Exception e){
    e.printStackTrace();
  } finally {
    state.l.unlock();
  }

  cp5.getGroup("game").show();
}

void draw_result_screen(){
  cp5.getGroup("login").hide();
  cp5.getGroup("game").hide();
  background(0);
  cp5.getGroup("result").show();

  readSocket.l.lock();
  try {
    while( readSocket.getStatus() ){
      readSocket.notResult.await();
    }
    cp5.get(Textlabel.class,"Result Screen")
       .setText(readSocket.checkMessage());
  }catch (Exception e){
    e.printStackTrace();
  }finally{
    readSocket.l.unlock();
  }
}

void draw_waiting_screen(){
  cp5.getGroup("login").hide();
  cp5.getGroup("result").hide();
  background(0);
  cp5.get(Textlabel.class,"serverlabel").show();


  readSocket.l.lock();
  try {
      while( !readSocket.getStatus() ){
          String m = readSocket.checkMessage();
          server_connection_label.setValue(m).show();
          readSocket.wait.await();
      } // end while
  }catch (Exception e){
    e.printStackTrace();
  }finally{
    readSocket.l.unlock();
  }
  gameState = game_screen;
}

boolean connect(){
    socket = null;
    try{
      socket = new Socket("localhost", 12345);
    }catch(Exception e){
      e.printStackTrace();
      server_connection_status = "Server offline";
    }

    if( socket != null && socket.isConnected() ){
      writeSocket = new Writer(socket);
      server_connection_status = writeSocket.connect();
      readSocket = new Reader(socket, state, this);
      readSocket.connect();
    }
    else return false;
  return true;
}

void keyPressed() {
  if(key == TAB){
    cp5.get(Textfield.class,"Username")
       .setFocus( !cp5.get(Textfield.class,"Username").isFocus() );
    cp5.get(Textfield.class,"Password")
       .setFocus( !cp5.get(Textfield.class,"Password").isFocus() );
  }
  if(gameState == game_screen){
    if( key == CODED ){
      if( keyCode == UP)
        writeSocket.send("w");
      else if( keyCode == LEFT)
        writeSocket.send("a");
      else if( keyCode == RIGHT)
        writeSocket.send("d");
    }
    switch(key){
      case 'w':
        writeSocket.send("w");
      break;

      case 'a':
        writeSocket.send("a");
      break;

      case 'd':
        writeSocket.send("d");
      break;

      default:
      break;
    }
    // }
  }
}
