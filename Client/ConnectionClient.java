import java.net.*;
import java.io.*;
import java.util.*;

public class ConnectionClient {
  private Socket socket;

  public ConnectionClient(){
    this.socket = null;
  }

  public boolean connect(){
      try{
        socket = new Socket("localhost", 12345);
      }catch(Exception e){
        e.printStackTrace();
        return false;
      }
      return true;
  }

  public void disconnect() throws IOException{
    socket.close();
  }

  public void login(String user, String password){
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

class ReadSocket extends Thread{
  BufferedReader in;
  ConnectionClient inSocket;
  // boolean *start;

  public ReadSocket(Socket socket){
    inSocket.connect();
    try {
      this.in = new BufferedReader(new InputStreamReader(inSocket.getInputStream()));
    }catch(IOException e){
      e.printStackTrace();
    }
  }

  public void run(){
    while(!start){
      if ( in.readLine().equals("login successful") ){
        start = true;
      }

    }
  }
}
