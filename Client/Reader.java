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
   Client a;

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

  public Reader(Socket socket, Client.PlayState state, Client a){
    this.socket = socket;
    this.in = null;
    this.state = state;
    this.message = "";

    this.l = new ReentrantLock();
    this.wait = l.newCondition();
    this.notResult = l.newCondition();
    this.ready = false;
    this.a = a;
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

  public void updateState(float[] list){
      Client.PlayerAvatar p1 = a.new PlayerAvatar(list[1], list[2], list[3], list[4], list[5], list[6], list[7], list[8], list[9], list[10] ,list[11], list[12], list[13]);
      Client.PlayerAvatar p2 = a.new PlayerAvatar(list[15], list[16], list[17], list[18], list[19], list[20], list[21], list[22], list[23], list[24] ,list[25], list[26], list[27]);
      float greens, reds;

      greens = list[28];
      Client.Creature[] green = null;
      // green[0] = a.new Creature(0);
      // green[0] = a.new Creature(0);
      green[0] = a.new Creature(list[29], list[30], list[31], list[32], list[33],list[34], list[35], list[36], list[37] );
      green[1] = a.new Creature(list[38], list[39], list[40], list[41], list[42],list[43], list[44], list[45], list[46] );

      reds = list[47];
      ArrayList<Client.Creature> red = new ArrayList<Client.Creature>();
      for( int i = 0; i < reds; i++){
        red.add( a.new Creature(list[29], list[30], list[31], list[32], list[33],list[34], list[35], list[36], list[37] ));
      }

      float score1 = this.state.getScore1();
      float score2 = this.state.getScore2();
      this.l.lock();
      try {
        this.state = a.new PlayState(p1, p2, green, red, score1, score2);
      }finally{
        this.l.unlock();
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
                  this.message += a;
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
