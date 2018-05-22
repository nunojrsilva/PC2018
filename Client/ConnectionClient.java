import java.net.*;
import java.io.*;
import java.util.*;

public class ConnectionClient {
   Socket socket;

  public ConnectionClient(){
    this.socket = null;
  }

  public Socket getSocket (){
    return this.socket;
  }

  public Socket connect(){
      try{
        socket = new Socket("localhost", 12345);
      }catch(Exception e){
        e.printStackTrace();
        return null;
      }
      return socket;
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

class ReadSocket extends Thread{
  BufferedReader in;
  ConnectionClient inSocket;
  // boolean *start;

  public ReadSocket(){
    inSocket = new ConnectionClient();
    // inSocket.getSocket().connect();
    try {
      Socket aux = inSocket.getSocket();
      this.in = new BufferedReader(new InputStreamReader(aux.getInputStream()));
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
