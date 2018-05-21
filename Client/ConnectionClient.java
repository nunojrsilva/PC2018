import java.net.*;
import java.io.*;
import java.util.*;

public class ConnectionClient {
  private Socket writeSocket;

  public ConnectionClient(){
    this.writeSocket = null;
  }

  public boolean connect(){
      try{
        writeSocket = new Socket("localhost", 12345);
      }catch(Exception e){
        e.printStackTrace();
        return false;
      }
      return true;
  }

  public void disconnect() throws IOException{
    writeSocket.close();
  }

  public void login(String user, String password){
    try{
      PrintWriter out = new PrintWriter(writeSocket.getOutputStream());
      out.println("*login " + user + " " + pass);
      out.flush();
    }catch (Exception e) {
      e.printStackTrace();
      System.exit(0);
    }
  }
}

class ReadSocket extends Thread{
  BufferedReader in;
  ConnectionClient inSocket;

  ReadSocket(){
    inSocket.connect();
    this.in = new BufferedReader(new InputStreamReader(inSocket.getInputStream()));

  }
}
