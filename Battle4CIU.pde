//import shapes3d.org.apache.commons.math.*;
//import shapes3d.org.apache.commons.math.geometry.*;
//import peasy.org.apache.commons.math.geometry.*;

private boolean loading;
private float opacity = 0.0;

public int SPEED_FACTOR = 1; // SPEED_FACTOR = 1 -> Earth's day = 2s
public float DISTANCE_SCALE = 1.537312278E+7;
public float SIZE_SCALE = 20000;

public float timeSinceLastStep; // seconds
private float prevTime = 0;
private float time = 0;

final int GENERAL_VIEW = 0;
final int EXPLORE = 1;

int mode = EXPLORE;
boolean showHUD = true;

PImage milkyWay;
World solarSystemData;

HUD hud;
SoundsManager soundsManager;

Player player1;
Player player2;
Viewport player1Viewport;
Viewport player2Viewport;

void setup() {
  fullScreen(P3D);
  //size(1800 ,1500 ,P3D) ;
  noStroke();
  loading = true;
  soundsManager = new SoundsManager(this);
  soundsManager.playBackgroundMusic();
  hud = new HUD();
 
  
  thread("load");
}

void load() {
  milkyWay = loadImage("./data/images/Milky Way.jpg");
  milkyWay.resize(displayWidth, displayHeight);
  solarSystemData = new World();
  //spaceship = new Spaceship();
  
  player1 = new Player("Player1", new MouseKeyboardControl(this), new PVector(20, 0, 50));
  player2 = new Player("Player2", new MouseKeyboardControl(this), new PVector(-20, 0, 50));
  
  
  Player[] players = {player1, player2};
  //Player[] players = {player1};
  
  player1Viewport = new MatchViewport(this, width/2, height, new PVector(0, 0), player1, players, solarSystemData);
  player2Viewport = new MatchViewport(this, width/2, height, new PVector(width/2, 0), player2, players, solarSystemData);
  
  synchronized(this) {
    loading = false;
    println("Finished loading");
  }
}

synchronized void draw() {
  time = millis();
  timeSinceLastStep = (time - prevTime)/1000;
  prevTime = time;
  
  if (loading) {
    showLoadingScreen();
  } else {
    renderScene();
  }
}

void showLoadingScreen() {
  background(0);
  translate(width/2.0 - 25, height/2.0, -200);
  textSize(10);
  //fill(color(255, 255, 255));
  fill(255, 255.0 - opacity);
  opacity += 2;
  if (opacity >= 255.0) opacity = 0.0;
  text("LOADING...", 0, 0);
  fill(255);
}

void renderScene() {
  //noCursor();  
  solarSystemData.update();
  
  //pg1.background(milkyWay);  
  //background (0, 0, 0); 
  player1.update();
  player2.update();
  player1Viewport.renderGraphics();
  player2Viewport.renderGraphics();
  //pg1.noLights();
  //spaceship.display(pg1);
  //pg1.perspective(PI/3.0,(float)width/height,1, 900);
  //pg1.endDraw();
  
  
  
  //if(showHUD) hud.show();
}
