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

  public void run(){
    try{
      this.connect();
      while(true){
        this.l.lock();
        try{
          this.message = in.readLine();

          if( this.message.equals("Waiting for your oponent") ){


          }
        }catch(Exception e){
          e.printStackTrace();
        }finally{
          this.l.unlock();
        }

      }
    }catch (Exception e){
      e.printStackTrace();
    }

  }
}


//
//
//
// {
//   {
//     { {1,2}, 0,0,20,1,2.25,0.55,20,2,0.2,0.1,100}, {"elisio",<0.76.0>}
//   },
//   {
//     { {1,2}, 0,0,20,2,2.25,0.55,20,2,0.2,0.1,100}, {"\n",<0.60.0>}
//   },
//   [
//     { {1,2}, 0, {3,4}, 50, g,1},
//     { {1,2}, 0, {3,4}, 50, g,1}
//   ],
//   [],
//   {1200,800}
// }
//
//
// {
//   {
//     {"elisio"}, { {1,2}, 0,0,20,1,2.25,0.55,20,2,0.2,0.1,100}
//   },
//   {
//     {"\n"}, { {1,2}, 0,0,20,2,2.25,0.55,20,2,0.2,0.1,100}
//   },
//   [
//     { {1,2}, 0, {3,4}, 50, g,1},
//     { {1,2}, 0, {3,4}, 50, g,1}
//   ],
//   [],
//   {1200,800}
// }
