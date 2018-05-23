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


  public void createAccount(String user, String password){

  }
}
