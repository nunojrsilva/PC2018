import java.net.*;
import java.io.*;
import java.util.*;

public class Writer {
   Socket socket;
   PrintWriter out;

  private Writer(){
    this.socket = null;
    this.out = null;
  }

  public Writer(Socket socket/*, PlayState state*/){
    this.socket = socket;
    this.out = null;
  }

  public String connect(){
    try{
      out = new PrintWriter(socket.getOutputStream());
    }catch(Exception e){
      e.printStackTrace();
    }
    return "Write Socket msg: Server offline";
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
    }
  }


  public void createAccount(String user, String password){
    try{
      out.println("*create_account " + user + " " + password);
      out.flush();
    }catch (Exception e){
      e.printStackTrace();
    }
  }

  public void send(String message){
    try{
      out.println(message);
      out.flush();
    }catch (Exception e) {
      e.printStackTrace();
    }
  }
}
