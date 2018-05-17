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

}
