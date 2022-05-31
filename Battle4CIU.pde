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
ControllerRepository controllerRepository;

void setup() {
  fullScreen(P3D);
  //size(1800 ,1500 ,P3D) ;
  noStroke();
  currentScene = new LoadingScene();
  soundsManager = new SoundsManager();
  soundsManager.playBackgroundMusic();
  thread("load");
}

void load() {
  milkyWay = loadImage("./data/images/Milky Way.jpg");
  milkyWay.resize(displayWidth, displayHeight);
  solarSystemData = new World();
  
  loadFonts();
  
  poseDetectionService = new PoseDetectionService();
  controllerRepository = new ControllerRepository();
    
  synchronized(this) {
    switchScene(new MainMenu());
    println("Finished loading");
  }
}

public void switchScene(Scene newScene) {
  currentScene.dispose();
  currentScene = newScene;
}

synchronized void draw() {
  time = millis();
  timeSinceLastStep = (time - prevTime)/1000;
  prevTime = time;
  
  currentScene.display();
  
}
