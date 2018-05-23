import java.net.*;
import java.io.*;
import java.util.*;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.Condition;

public class Reader extends Thread {
   Socket socket;
   BufferedReader in;
   PlayState state;
   String message;

  private Writer(){
    this.socket = null;
    this.in = null;
    this.state = null;
    this.message = "";
  }

  public Writer(Socket socket, PlayState state){
    this.socket = socket;
    this.in = null;
    this.state = state;
    this.message = "";
  }

  public void connect(){
    try {
      this.in = new BufferedReader(new InputStreamReader(this.socket.getInputStream()));
    }catch(IOException e){
      e.printStackTrace();
    }
  }

  public void disconnect() throws IOException{
    ///////// tem de se fechar o out primieiro? senao vamos fechar o socket e deve dar Exception no Writer
    socket.close();
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
