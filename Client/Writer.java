import java.net.*;
import java.io.*;
import java.util.*;

public class Writer {
   Socket socket;
   PrintWriter out;
   // BufferedReader in;
   // int* gameState;
   // String message;

  private Writer(){
    this.socket = null;
    this.out = null;
    // this.state = false;
    // this.message = "";
  }

  public Writer(Socket socket/*, PlayState state*/){
    this.socket = socket;
    this.out = null;
    // this.gameState = gameState;
    // this.message = "";
  }

  public void connect(){
    try{
      out = new PrintWriter(socket.getOutputStream());
    }catch(Exception e){
      e.printStackTrace();
    }
  }

  public void connect(){
    try {
      // this.socket = new Socket("localhost", 12345);
      this.in = new BufferedReader(new InputStreamReader(this.socket.getInputStream()));
    }catch(IOException e){
      e.printStackTrace();
    }
  }

  public void disconnect() throws IOException{
    socket.close();
  }

  public void login(String user, String pass){
    try{
      PrintWriter out = new PrintWriter(socket.getOutputStream());
      out.println("*login " + user + " " + pass);
      out.flush();
    }catch (Exception e) {
      e.printStackTrace();
      System.exit(0);
    }
  }

  public boolean checkStatus(){
    if (this.in != null){
      return true;
    }else{
      return false;
    }
  }


  public void createAccount(String user, String password){

  }
  public void run(){
    try{
      this.connect();
      while(true){
        this.message = in.readLine();
        if( this.message.equals("login successful") ){
          this.gameState = 1;
          System.out.println("login successful\n");
        }
        if( this.message.equals("login error") ){
          System.out.println("login error");
        }

      }
    }catch (IOException e){
      e.printStackTrace();
    }

  }
}
