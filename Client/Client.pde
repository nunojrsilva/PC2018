import controlP5.*;

ControlP5 cp5;

String username;
String password;

final int fields_height = 40;
final int textfield_width = 250;
final int button_width = 100;
final int spacing_size = 10;
final int server_connection_label = spacing_size*2 + button_width + textfield_width;

controlP5.Button login_button;
controlP5.Button new_account_button;
controlP5.Textfield username_textfield;
controlP5.Textfield password_textfield;

final int login_screen = 0;
final int game_screen = 1;
final int result_screen = 2;

int state = 0;


void setup() {

  fullScreen();
  pixelDensity(displayDensity());

  cp5 = new ControlP5(this);
  PFont font = createFont("Papyrus", 12);


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
                    // .onClick( new CallbackListener(){
                    //
                    // })
                    ;
  password_textfield = cp5.addTextfield( "Password" )
                           .setPosition( width/2 - spacing_size - textfield_width, height/2 + spacing_size )
                           .setSize( textfield_width, fields_height)
                           .setFocus(true)
                           .setColorActive(color(255,0,0))
                           .setFont(font)
                           ;
  new_account_button = cp5.addButton( "New Account" )
                          .setPosition( width/2 + spacing_size, height/2 + spacing_size )
                          .setSize( button_width, fields_height )
                          ;
  // server_connection_label = cp5.addTextlabel("Connection with server OK")
  //                              .setPosition(width/2, height/2 + 2*spacing_size + fields_height)
  //                              // setFont(createFont("Calibri",20))
  //                              ;
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
