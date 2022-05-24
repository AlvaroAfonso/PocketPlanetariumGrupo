//import shapes3d.org.apache.commons.math.*;
//import shapes3d.org.apache.commons.math.geometry.*;
//import peasy.org.apache.commons.math.geometry.*;
import java.util.*;
import peasy.org.apache.commons.math.geometry.*;

public int SPEED_FACTOR = 1; // SPEED_FACTOR = 1 -> Earth's day = 2s
public float DISTANCE_SCALE = 1.537312278E+7;
public float SIZE_SCALE = 20000;

public float timeSinceLastStep; // seconds
private float prevTime = 0;
private float time = 0;

final int GENERAL_VIEW = 0;
final int EXPLORE = 1;

int nPosePlayers;
int mode = EXPLORE;
boolean showHUD = true;

PImage milkyWay;
World solarSystemData;

SoundsManager soundsManager;

PApplet appRoot = this;
Scene currentScene;

PoseDetectionService poseDetectionService;

Player player1;
Player player2;

void setup() {
  fullScreen(P3D);
  //size(1800 ,1500 ,P3D) ;
  noStroke();
  currentScene = new LoadingScene();
  nPosePlayers = 0;
  soundsManager = new SoundsManager();
  soundsManager.playBackgroundMusic();
  thread("load");
}

void load() {
  milkyWay = loadImage("./data/images/Milky Way.jpg");
  milkyWay.resize(displayWidth, displayHeight);
  solarSystemData = new World();
  
  poseDetectionService = new PoseDetectionService();
  
  if(nPosePlayers==0){
    player1 = new Player("Player1", new MouseKeyboardControl(new MainKeyboardMap(), false), new PVector(20, 0, 50));
    player2 = new Player("Player2", new MouseKeyboardControl(new AltKeyboardMap(), true), new PVector(-20, 0, 50));
  } else if(nPosePlayers==1){
    player1 = new Player("Player1", new PoseControl(poseDetectionService), new PVector(20, 0, 50));
    player2 = new Player("Player2", new MouseKeyboardControl(new MainKeyboardMap(), false), new PVector(-20, 0, 50));
  } else {
    player1 = new Player("Player1", new PoseControl(poseDetectionService), new PVector(20, 0, 50));
    player2 = new Player("Player2", new PoseControl(poseDetectionService), new PVector(-20, 0, 50));
  }
  
  Player[] players = {player1, player2};
  //Player[] players = {player1};
    
  synchronized(this) {
    currentScene = new VersusMatchScene(new VersusMatchConfig(players, solarSystemData));
    println("Finished loading");
  }
}

synchronized void draw() {
  time = millis();
  timeSinceLastStep = (time - prevTime)/1000;
  prevTime = time;
  
  currentScene.display();
  
}
