//import shapes3d.org.apache.commons.math.*;
//import shapes3d.org.apache.commons.math.geometry.*;
//import peasy.org.apache.commons.math.geometry.*;


PImage milkyWay;
SolarSystem solarSystem;
Spaceship spaceship;
CameraControl cameraControl;
HUD hud;
SoundsManager soundsManager;

private boolean loading;

public int SPEED_FACTOR = 1; // SPEED_FACTOR = 1 -> Earth's day = 2s
public float DISTANCE_SCALE = 1E+4;
public int SIZE_SCALE = 10;

public float timeSinceLastStep; // seconds
private float prevTime = 0;
private float time = 0;

final int GENERAL_VIEW = 0;
final int EXPLORE = 1;

int mode = GENERAL_VIEW;
boolean showHUD = true;

void setup() {
  fullScreen(P3D);
  //size(1800 ,1500 ,P3D) ;
  noStroke();
  loading = true;
  soundsManager = new SoundsManager(this);
  soundsManager.playBackgroundMusic();
  cameraControl = new CameraControl(this); 
  hud = new HUD();
  thread("load");
}

void load() {
  milkyWay = loadImage("./data/images/Milky Way.jpg");
  milkyWay.resize(displayWidth, displayHeight);
  solarSystem = new SolarSystem();
  spaceship = new Spaceship();
  
  synchronized(this) {
    loading = false;
    println("Finished loading");
  }
}

synchronized void draw() {
  if (loading) {
    background(0);
    translate(width/2.0, height/2.0, 0);
    textSize(900);
    fill(color(255, 255, 255));
    text("LOADING...", 0, 0);
    return;
  }
  
  //noCursor();
  
  time = millis();
  timeSinceLastStep = (time - prevTime)/1000;
  prevTime = time;
  
  background(milkyWay);  
  //background (0, 0, 0); 
  
  solarSystem.display(); 
   
  noLights();
  
  spaceship.display();
  
  perspective(PI/3.0,(float)width/height,1,10000000);
  
  if(showHUD) hud.show();
}
