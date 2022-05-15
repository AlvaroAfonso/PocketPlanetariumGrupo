// necessary global variables for the event listener
Pose[] poses = new Pose[0];
int nPoses = 0;



abstract class ControlScheme {
  
  // main keyboard controls
  boolean moveForward = false;
  boolean moveLeft = false;
  boolean moveBackward = false;
  boolean moveRight = false;
  boolean moveUp = false;
  boolean moveDown = false;
  boolean moveStop = false;
  
  // planetary system controls
  boolean speedUp = false;
  boolean slowDown = false;
  
  PlayerFocus playerFocus;
  float sensitivity;
  int sensitivityOffset;
}

class PlayerFocus {
   float x;
   float y;   
   public PlayerFocus(float x, float y) {
     this.x = x;
     this.y = y;
   }
}


public class PoseControl extends ControlScheme {
  private oscReceiver osc;
  private int ID;
  private int[] detectionBuffer;
  private float poseX;
  private float poseY;
  
  
  public PoseControl(PApplet parent, int playerID){
    this.ID = playerID;
    this.detectionBuffer = new int[4];
    this.poseX=width/2;
    this.poseY=height/2;
    for(int i=0; i<4; i++){
      this.detectionBuffer[i]=0; //Move forward, backwards, left, right
    }
    this.osc = new oscReceiver();
    this.osc.oscP5.plug(this,"parseData","/poses/xml"); //listener activation
    nPoses++;
    sensitivity = 1;
    sensitivityOffset = 20;
    playerFocus=new PlayerFocus(this.poseX,this.poseY);
    parent.registerMethod("pre", this);
  }
  
  
  public void pre(){
    if (poses.length > 0) {
      detectionLeftArm(poses[this.ID],"leftWrist","leftElbow"); //<>//
      detectionRightArm(poses[this.ID],"rightWrist","rightElbow"); //<>//
    }
  }
  
  
  void detectionLeftArm(Pose pose, String part0, String part1){
    HashMap<String,Keypoint> keypoints;
    try{
      keypoints = pose.keypoints;
    }catch(Exception e){
      return;
    }
    if (!keypoints.containsKey(part0)){
      return;
    }
    if (!keypoints.containsKey(part1)){
      return;
    }
    PVector p0 = keypoints.get(part0).position;
    PVector p1 = keypoints.get(part1).position;
    
    
    if(p0.y - p1.y < sensitivityOffset-50){
      if(this.detectionBuffer[0]>4){
        moveForward = true;
      }else{
        this.detectionBuffer[0]++;
      }
    } else{
      if(this.detectionBuffer[0]>0){
        this.detectionBuffer[0]--;
      }else{
        moveForward=false;
      }
    }
    
    if(p0.y - p1.y > 50-sensitivityOffset){
      if(this.detectionBuffer[1]>4){
        moveBackward = true;
      }else{
        this.detectionBuffer[1]++;
      }
    } else{
      if(this.detectionBuffer[1]>0){
        this.detectionBuffer[1]--;
      }else{
        moveBackward=false;
      }
    }
    
    if(p0.x - p1.x < sensitivityOffset-50){
      if(this.detectionBuffer[2]>4){
        moveLeft = true;
      }else{
        this.detectionBuffer[2]++;
      }
    } else{
      if(this.detectionBuffer[2]>0){
        this.detectionBuffer[2]--;
      }else{
        moveLeft=false;
      }
    }
    
    if(p0.x - p1.x > 50-sensitivityOffset){
      if(this.detectionBuffer[3]>4){
        moveRight = true;
      }else{
        this.detectionBuffer[3]++;
      }
    } else{
      if(this.detectionBuffer[3]>0){
        this.detectionBuffer[3]--;
      }else{
        moveRight=false;
      }
    }
  }
  
  
  void detectionRightArm(Pose pose, String part0, String part1){
    HashMap<String,Keypoint> keypoints;
    try{
      keypoints = pose.keypoints;
    }catch(Exception e){
      return;
    }
    if (!keypoints.containsKey(part0)){
      return;
    }
    if (!keypoints.containsKey(part1)){
      return;
    }
    PVector p0 = keypoints.get(part0).position;
    PVector p1 = keypoints.get(part1).position;
    
    
    if(p0.y - p1.y < sensitivityOffset-50){
      this.poseY = height/2 - p0.y - sensitivityOffset + p1.y + 50;
    } else{
      this.poseY = height/2;
    }
    
    if(p0.y - p1.y > 50-sensitivityOffset){
      this.poseY = height/2 + p0.y + sensitivityOffset - p1.y - 50;
    } else{
      this.poseY = height/2;
    }
    
    if(p0.x - p1.x < sensitivityOffset-50){
      this.poseX = width/2 - p0.x - sensitivityOffset + p1.x + 50;
    } else{
      this.poseX = width/2;
    }
    
    if(p0.x - p1.x < 50-sensitivityOffset){
      this.poseX = width/2 + p0.x + sensitivityOffset - p1.x - 50;
    } else{
      this.poseX = width/2;
    }
  }
  
  //listener method
  public void parseData(String data){
    XML xml = parseXML(data);
    int nPosesAux = xml.getInt("nPoses");
    if(nPosesAux >= nPoses){
      poses = new Pose[nPoses];
      XML[] xmlposes = xml.getChildren("pose");
      for (int i = 0; i < xmlposes.length; i++){
        XML[] xmlkeypoints = xmlposes[i].getChildren("keypoint");
      
        poses[i] = new Pose();
        poses[i].score = xmlposes[i].getFloat("score");
      
        for (int j = 0; j < xmlkeypoints.length; j++){
          Keypoint kpt = new Keypoint();
       
          kpt.position.x = xmlkeypoints[j].getFloat("x");
          kpt.position.y = xmlkeypoints[j].getFloat("y");
          kpt.score = xmlkeypoints[j].getFloat("score");
        
          poses[i].keypoints.put(xmlkeypoints[j].getString("part"), kpt);
        }
      }
    }
  }
}



public class MouseKeyboardControl extends ControlScheme {

  private final int W = 119;
  private final int A = 97;
  private final int R = 114;
  private final int S = 115;
  private final int D = 100;
  private final int X = 120;
  private final int SPACE = 32;
  private final int I = 105;
  private final int J = 106;
  private final int K = 107;
  private final int L = 108;
  private final int U = 117;
  private final int O = 111;
  private final int P = 112;
  private final int eight = 56;
  private final int four = 52;
  private final int two = 50;
  private final int six = 54;
  
  
  private boolean mainScheme;
  private float keyX;
  private float keyY;
  
  public MouseKeyboardControl(PApplet parent, boolean scheme) {
    this.mainScheme = scheme;
    parent.registerMethod("keyEvent", this);
    if(this.mainScheme){                                // main scheme uses W, A, S, D, X, R, SPACE, mouse
      playerFocus = new PlayerFocus(mouseX, mouseY);
      parent.registerMethod("mouseEvent", this);
      sensitivity = 1.75; // radians
      sensitivityOffset = 150;
      this.keyX=0;
      this.keyY=0;
    } else{                                            // alt scheme uses I, J, K, L, U, O, P, numpad 2, 4, 6, 8
      this.keyX=width/2;
      this.keyY=height/2;
      sensitivity=2;
      sensitivityOffset=0;
      playerFocus=new PlayerFocus(this.keyX,this.keyY);
    }
  }
  
  public void keyEvent(KeyEvent event) {
    keyCode = event.getKeyCode();
    if (this.mainScheme){  // if using main scheme only listen to appropriate keys
      if (keyCode == W || keyCode == A || keyCode == R || keyCode == S || keyCode == D || keyCode == X || keyCode == SPACE){
        switch (event.getAction()) {
          case KeyEvent.PRESS:     
            this.keyPressed(event);      
            break;
          case KeyEvent.RELEASE:      
            this.keyReleased(event);
            break;
        }
      }
    } else{  // if using alt scheme first check and handle camera movement
      if (keyCode == eight){
        switch (event.getAction()){
          case KeyEvent.PRESS:
            keyY+=5;
            break;
          case KeyEvent.RELEASE:
            keyY-=5;
        }
      } else if (keyCode == four){
        switch (event.getAction()){
          case KeyEvent.PRESS:
            keyX-=5;
            break;
          case KeyEvent.RELEASE:
            keyX+=5;
        }
      } else if (keyCode == two){
        switch (event.getAction()){
          case KeyEvent.PRESS:
            keyY-=5;
            break;
          case KeyEvent.RELEASE:
            keyY+=5;
        }
      } else if (keyCode == six){
        switch (event.getAction()){
          case KeyEvent.PRESS:
            keyX+=5;
            break;
          case KeyEvent.RELEASE:
            keyX-=5;
        }
      } else if (keyCode != W && keyCode != A && keyCode != R && keyCode != S && keyCode != D && keyCode != X && keyCode != SPACE){
        switch (event.getAction()) {
          case KeyEvent.PRESS:     
            this.keyPressed(event);      
            break;
          case KeyEvent.RELEASE:      
            this.keyReleased(event);
            break;
        }
      }
    }
  }
  
  public void mouseEvent(MouseEvent event) {
    switch(event.getAction()) {
      case MouseEvent.MOVE:
        this.mouseMoved(event);
        break;
    }
  }
  
  public void keyPressed(KeyEvent event) {
    /*
    if (event.getKey() == ENTER) {
      mode = mode==GENERAL_VIEW? EXPLORE : GENERAL_VIEW;
      cameraControl.switchCameraReference();  
      soundsManager.switchBackgroundMusic();
    }
    */
    // ---------------- HUD CONTROLS ----------------
    if (event.getKey() == TAB) {
      showHUD = !showHUD;
    }
    // ---------------- TIME CONTROL ----------------
    if (event.getKey() == CODED) {
      if (keyCode == UP) {
        speedUp = true;
      }
      
      if (keyCode == DOWN) {
        slowDown = true;
      }
    }
    // ---------------- SPACESHIP CONTROLS ----------------  
    if (event.getKey() == W || event.getKey() == I) {
      moveForward = true;
    }
    if (event.getKey() == A || event.getKey() == J) {
      moveLeft = true;
    }  
    if (event.getKey() == S || event.getKey() == K) {
      moveBackward = true;
    }
    if (event.getKey() == D || event.getKey() == L) {
      moveRight = true;
    }
    if (event.getKey() == SPACE || event.getKey() == U) {
      moveUp = true;
    } 
    if (event.getKey() == X || event.getKey() == O) {
      moveDown = true;
    }
    if (event.getKey() == R || event.getKey() == P) {
      moveStop = true;
    }
  }
  
  public void keyReleased(KeyEvent event) {
    if (event.getKey() == CODED) {
      if (keyCode == UP) {
        speedUp = false;
      }
      
      if (keyCode == DOWN) {
        slowDown = false;
      }
    } 
    if (event.getKey() == W || event.getKey() == I) {
      moveForward = false;
    }
    if (event.getKey() == A || event.getKey() == J) {
      moveLeft = false;
    }
    if (event.getKey() == S || event.getKey() == K) {
      moveBackward = false;
    }
    if (event.getKey() == D || event.getKey() == L) {
      moveRight = false;
    }
    if (event.getKey() == SPACE || event.getKey() == U) {
      moveUp = false;
    } 
    if (event.getKey() == X || event.getKey() == O) {
      moveDown = false;
    }
    if (event.getKey() == R || event.getKey() == P) {
      moveStop = false;
    }
  }
  
  public void mouseMoved(MouseEvent event) {
    playerFocus.x = event.getX();
    playerFocus.y = event.getY();
    //println(playerFocus.x);
  }
}
