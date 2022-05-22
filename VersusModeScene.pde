/*
*  -Index-
*    1. SCENE ARGS
*    2. SCENE 
*    3. VIEWPORT
*      3.1. VIEWPORT UI COMPONENTS
*    4. UI COMPONENTS
*    5. SCENE CONTROLS
*/


/*-------------------------------- 
        1. SCENE ARGS
--------------------------------*/
public enum Layout {
    HORIZONTAL,
    VERTICAL  
}

public class VersusMatchConfig {

  Player[] players;
  World worldData;
  
  Layout viewportLayout;
  
  int playerLives;
  float matchTime;
  float planetsOrbitationSpeed;
}


/*--------------------------------  
            2. SCENE
--------------------------------*/
public class VersusMatchScene extends Scene {
  
  private Player[] players;
  private World worldData;
  
  public VersusMatchScene(PApplet root, VersusMatchConfig config) {
    super();
    this.players = config.players;
    this.worldData = config.worldData;
    
    int viewportWidth = config.viewportLayout == Layout.VERTICAL ? width/config.players.length : width;
    int viewportHeight = config.viewportLayout == Layout.HORIZONTAL ? height/config.players.length : height;
    
    for (int i = 0; i < config.players.length; i++) {
      PVector viewportCoords = config.viewportLayout == Layout.VERTICAL ? new PVector(i*viewportWidth, 0) : new PVector(0, i*viewportHeight);
      viewports.add(new PlayerViewport(root, viewportWidth, viewportHeight, viewportCoords, players[i], players, worldData));
    }
    
    appRoot.registerMethod("pre", this);
  }
  
  public void pre() {
    worldData.update();
    for (Player player : players) {
      player.update();
    }
  } 

}


/*-------------------------------- 
          3. VIEWPORT
--------------------------------*/
public class PlayerViewport extends Viewport {
  
  private Player currentPlayer;
  private ArrayList<PlayerModel> players;
  private WorldModel gameWorld;
  
  private Camera cam;
  
  public PlayerViewport(PApplet parent, int viewportWidth, int viewportHeight, PVector screenCoords, Player currentPlayer, Player[] players, World world) {
    super(parent, viewportWidth, viewportHeight, screenCoords, DEFAULT_PRIORITY);
    this.currentPlayer = currentPlayer;
    this.players = new ArrayList();
    this.gameWorld = new WorldModel(canvas, world);
    this.cam = new NativeThirdPersonCamera(parent, canvas, currentPlayer);
    for (Player player : players) {
      this.players.add(new PlayerModel(canvas, player));
    }
  }  
  
  @Override
  protected void renderGraphics() {
    canvas.background(0); 
    gameWorld.display(true);
      
    //We sort the players from farthest to closest based on their distance to current player.
    Collections.sort(players, new Comparator<PlayerModel>() {
      @Override
      public int compare(PlayerModel modelA, PlayerModel modelB) {
        float distanceA = distanceBetween(cam.getPosition(), modelA.player.position);
        float distanceB = distanceBetween(cam.getPosition(), modelB.player.position);
        if (distanceA > distanceB) return -1;
        if (distanceA < distanceB) return 1;
        return 0;
      }
    });
      
    for (PlayerModel player : players) {
      player.display();
    }
  }
  
}


/*-------------------------------- 
   3.1. VIEWPORT UI COMPONENTS
--------------------------------*/


/*-------------------------------- 
4. UI COMPONENTS
--------------------------------*/


/*--------------------------------  
5. CONTROLS
--------------------------------*/
enum Command {
    MOVE_FORWARD,
    MOVE_BACKWARD,
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DOWN,
    STOP,
    
    CAMERA_UP,
    CAMERA_DOWN,
    CAMERA_LEFT,
    CAMERA_RIGHT
}

abstract class ControlScheme {
  // camera controls
  PlayerFocus playerFocus;
  float cameraSensitivity;
  int cameraSensitivityOffset;
  
  // main keyboard controls
  boolean moveForward = false;
  boolean moveLeft = false;
  boolean moveBackward = false;
  boolean moveRight = false;
  boolean moveUp = false;
  boolean moveDown = false;
  boolean moveStop = false;
  
  // solar system controls
  boolean speedUp = false;
  boolean slowDown = false;
  
  // system controls
  
}

class PlayerFocus {  
   float x;
   float y;   
   
   public PlayerFocus(float x, float y) {
     this.x = x;
     this.y = y;
   }
}

public class CommandLatencyGenerator {
  
  private int latency;
  private HashMap<Command, Integer> latencyCounters;
  private HashMap<Command, Boolean> previousFlagValues;
  
  public CommandLatencyGenerator(Command[] commands, int latency) {
    this.latency = latency;
    latencyCounters = new HashMap();
    previousFlagValues = new HashMap();
    for (Command command : commands) {
       latencyCounters.put(command, 0);
       previousFlagValues.put(command, false);
    }
  }
  
  public boolean delayedFlagValue(Command command, boolean commandFlagValue) {
    int latencyCounter = latencyCounters.get(command);
    boolean previousFlagValue = previousFlagValues.get(command);
    
    if (commandFlagValue == previousFlagValue) return commandFlagValue;
    
    if (latencyCounter++ == latency) {
      latencyCounters.put(command, 0);
      previousFlagValues.put(command, commandFlagValue);
      return commandFlagValue;
    }
    
    return previousFlagValue;
  }
} 
