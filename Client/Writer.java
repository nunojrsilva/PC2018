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

  public String connect(){
    try{
      out = new PrintWriter(socket.getOutputStream());
    }catch(Exception e){
      e.printStackTrace();
      return "Server offline";
    }
    return "Server online";
  }

  public void disconnect() throws IOException{
    socket.close();
  }

  public void login(String user, String pass){
    try{
      out.println("*login " + user + " " + pass);
      out.flush();
    }catch (Exception e) {
      e.printStackTrace();
      System.exit(1);
    }
  }


  public void createAccount(String user, String password){
    try{
      out.println("*create_account " + user + " " + password);
      out.flush();
    }catch (Exception e){
      e.printStackTrace();
      System.exit(1);
    }
  }
}
