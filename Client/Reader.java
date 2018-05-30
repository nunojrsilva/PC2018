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
   int firstState;

  private Reader(){
    this.socket = null;
    this.in = null;
    this.state = null;
    this.message = "";

    this.l = null;
    this.wait = null;
    this.notResult = null;
    this.ready = false;
    this.firstState = 0;
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
    this.firstState = 0;
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

  private ArrayList<String> convertToFloat(String[] s){
    ArrayList<String> f = new ArrayList(s.length);
    for(int i = 1; i < s.length; i++){
        f.add( s[i] );
    }

    return f;
  }

  public void updateState(String[] list){
    int i = 2;
    Client.PlayerAvatar p1 = a.new PlayerAvatar(
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]) 
    );
    i++;
    Client.PlayerAvatar p2 = a.new PlayerAvatar( 
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]),
     Float.parseFloat(list[i++]) 
    );
    float greens, reds;

    greens = Float.parseFloat(list[i++]);
    ArrayList<Client.Creature> green = new ArrayList<Client.Creature>();

    green.add( a.new Creature( 
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]), 
      list[i++], 
      Float.parseFloat(list[i++]) 
      ) 
    );

    green.add( a.new Creature( 
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]),
      Float.parseFloat(list[i++]), 
      Float.parseFloat(list[i++]), 
      list[i++],
      Float.parseFloat(list[i++]) 
      )
    );

    reds = Float.parseFloat( list[i++] );
    int count = 48;
    ArrayList<Client.Creature> red = new ArrayList<Client.Creature>();
    for( int j = 0; j < reds; j++){
      red.add( a.new Creature(
        Float.parseFloat(list[count++]), 
        Float.parseFloat(list[count++]), 
        Float.parseFloat(list[count++]),
        Float.parseFloat(list[count++]), 
        Float.parseFloat(list[count++]),
        Float.parseFloat(list[count++]), 
        Float.parseFloat(list[count++]), 
        list[count++], 
        Float.parseFloat(list[count++])
        )
      );
    }

    float score1 = this.state.getScore1();
    float score2 = this.state.getScore2();
    this.l.lock();
    try {
      this.state.update(p1, p2, green, red, score1, score2);
    }finally{
      this.l.unlock();
    }
  }

  public void run(){
      while(true){
          String[] splitList = null;
          try{
            this.message = in.readLine();
          }catch(Exception e){
            e.printStackTrace();
            System.exit(1);
          }
          if( this.message != null){
            System.out.println(this.message);
            splitList = this.message.split(",");

            System.out.println("readSocket - " + splitList.length + " " + this.message);
          }else{
            System.out.println("readSocket leu null do socket");
          }
          ArrayList<String> floatList ;
          floatList = convertToFloat(splitList);

          if( splitList.length > 1 ){
              if( this.firstState == 0){
                this.firstState = 1;
                this.l.lock();
                try {
                  this.ready = true;
                  this.wait.signal();
                }finally{
                  this.l.unlock();
                }
              }
              updateState(splitList);
          }else // end if start

          if(splitList[0].equals("result")){
            this.message = "";
            l.lock();
            try {
              for(String a: splitList)
                this.message += a;
                this.ready = false;
                notResult.signal();
            }catch (Exception e){
              e.printStackTrace();
            }
            finally{
              l.unlock();
            }
          }


      } // end while
  } // end method
}
