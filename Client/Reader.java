import java.net.*;
import java.io.*;
import java.util.*;
import java.lang.Float;
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
   Condition notResult;
   boolean ready;

  private Reader(){
    this.socket = null;
    this.in = null;
    this.state = null;
    this.message = "";

    this.l = null;
    this.wait = null;
    this.notResult = null;
    this.ready = false;
  }

  public Reader(Socket socket, Client.PlayState state){
    this.socket = socket;
    this.in = null;
    this.state = state;
    this.message = "";

    this.l = new ReentrantLock();
    this.wait = l.newCondition();
    this.notResult = l.newCondition();
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

  private float[] convertToFloat(String[] s){
    float[] f = {0};
    for(int i = 1; i < s.length; i++){
      f[i] = Float.parseFloat( s[i] );
    }

    return f;
  }

  public void updateState(float[] l){
      // PlayerAvatar p1 = new PlayerAvatar(l[1], l[2], l[3], l[4], l[5], l[6], l[7], l[8], l[9], l[10] ,l[11], l[12], l[13]);
      // PlayerAvatar p2 = new PlayerAvatar(l[15], l[16], l[17], l[18], l[19], l[20], l[21], l[22], l[23], l[24] ,l[25], l[26], l[27]);
      float greens, reds;

      greens = l[28];
      Creature[] green;
      greeen[0] = new Creature(l[29], l[30], l[31], l[32], l[33],l[34], l[35], l[36], l[37] );
      green[1] = new Creature(l[38], l[39], l[40], l[41], l[42],l[43], l[44], l[45], l[46] );

      reds = l[47];
      ArrayList<Creature> red;
      for( int i = 0; i < reds; i++){
        red.add( new Creature(l[29], l[30], l[31], l[32], l[33],l[34], l[35], l[36], l[37] ));
      }

      float score1 = this.state.getScore1();
      float score2 = this.state.getScore2();
      l.lock();
      try {
        this.state = new PlayState(p1, p2, green, red, score1, score2);
      }finally{
        l.unlock();
      }
  }

  public void run(){
      while(true){

          try{
            this.message = in.readLine();
          }catch(Exception e){
            e.printStackTrace();
            System.exit(1);
          }
            String[] splitList = this.message.split(";");
            float[] floatList = convertToFloat(splitList);

            if( splitList[0].equals("start") ){
                this.l.lock();
                try {
                  this.ready = true;
                }finally{
                  this.l.unlock();
                }
                updateState(floatList);
                this.wait.signal();
            }else // end if start

            if(splitList[0].equals("result")){
              this.message = "";
              l.lock();
              try {
                for(String a: splitList)
                  this.message.append(a);
                notResult.signal();
              }catch (Exception e){
                e.printStackTrace();
              }
              finally{
                l.unlock();
              }
            }else{ // end result
              updateState(floatList);
            }


      } // end while
  } // end method
}
