import java.net.*;
import java.io.*;
import java.util.*;
import java.util.concurrent.locks.ReentrantLock;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.Condition;

public class Reader extends Thread {
   Socket socket;
   BufferedReader in;
   Client.PlayState state;
   String message;
   Lock l;
   Condition wait;
   boolean ready;

  private Reader(){
    this.socket = null;
    this.in = null;
    this.state = null;
    this.message = "";

    this.l = null;
    this.wait = null;
    this.ready = false;
  }

  public Reader(Socket socket, Client.PlayState state){
    this.socket = socket;
    this.in = null;
    this.state = state;
    this.message = "";

    this.l = new ReentrantLock();
    this.wait = l.newCondition();
    this.ready = false;
  }

  public String connect(){
    try {
      this.in = new BufferedReader(new InputStreamReader(this.socket.getInputStream()));
    }catch(Exception e){
      // e.printStackTrace();
      return "Server offline";
    }
    return "Server online";
  }

  public void disconnect() throws IOException{
    ///////// tem de se fechar o out primieiro? senao vamos fechar o socket e deve dar Exception no Writer
    socket.close();
  }

  public boolean getStatus(){
    if (this.ready){
      return true;
    }else{
      return false;
    }
  }

  public void setStatus(boolean status){
    this.ready = status;
  }


  public void createAccount(String user, String password){

  }

  public String getMessage(){
    try{
      this.message = in.readLine();
      return this.message;
    }catch (Exception e){
      e.printStackTrace();
    }
    return "Error connecting to server";
  }

  public String checkMessage(){
    return this.message;
  }

  public void updateState(String[] l){
      PlayerAvatar p1 = this.state.

  }

  public void run(){
      while(true){

          try{
            this.message = in.readLine();
            String[] splitList = this.message.split(";");

            if( splitList[0].equals("start") ){
                this.l.lock();
                try {
                  this.ready = true;
                }finally{
                  this.l.unlock();
                }
                this.wait.signal();
            }else // end if start

            if(splitList[0].equals("result")){

            }else{ // end result
              updateState(splitList);
            }
          }catch(Exception e){
            e.printStackTrace();
          }


      } // end while
  } // end method
}
