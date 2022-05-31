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

  ArrayList<Player> players;
  World worldData;
  
  Layout viewportLayout;
  
  int playerLives;
  int playerMaxSpeed;
  int bulletSpeed;
  int planetOrbitationSpeedUp;
  
  public VersusMatchConfig() {
    players = new ArrayList();
    worldData = solarSystemData;
    viewportLayout = Layout.VERTICAL;
  }
  
  public VersusMatchConfig(ArrayList<Player> players, World worldData) {
    this.players = players;
    this.worldData = worldData;
    viewportLayout = Layout.VERTICAL;
  }
  
  public void addPlayer(Player newPlayer) {
    players.add(newPlayer);
  }
  
}


/*--------------------------------  
            2. SCENE
--------------------------------*/
public class VersusMatchScene extends Scene {
  
  private ArrayList<Player> players;
  private World worldData;
  
  public VersusMatchScene(VersusMatchConfig config) {
    super();    
    
    println(config.players.size() + " Lives: " + config.playerLives +  " P1 Control: " + config.players.get(0).controller.getClass() + " P2 Control: " + config.players.get(1).controller.getClass());
    this.players = config.players;
    this.worldData = config.worldData;
    
    int viewportWidth = config.viewportLayout == Layout.VERTICAL ? width/config.players.size() : width;
    int viewportHeight = config.viewportLayout == Layout.HORIZONTAL ? height/config.players.size() : height;
    
    for (Player player : players) {
      PVector viewportCoords = config.viewportLayout == Layout.VERTICAL ? new PVector(players.indexOf(player)*viewportWidth, 0) : new PVector(0, players.indexOf(player)*viewportHeight);
      viewports.add(new PlayerViewport(viewportWidth, viewportHeight, viewportCoords, player, players, worldData));
      uiComponents.add(new PlayerHUD(player, viewportWidth, viewportHeight, viewportCoords, Panel.DEFAULT_PRIORITY + 1000));
      
    }

    appRoot.registerMethod("pre", this);
    
  }
  
  public void pre() {
    ArrayList<Collisionable> collisionableBodies = new ArrayList();
    worldData.update();
    for (Player player : players) {
      player.update();
      collisionableBodies.add(player);
    }
    for (Player player : players) {
      player.blaster.trackPlayers(players);
      player.blaster.checkCollisions(collisionableBodies);
    }
    
  } 

}


/*-------------------------------- 
          3. VIEWPORT
--------------------------------*/
public class PlayerViewport extends Viewport {
  
  private Player currentPlayer;
  private ArrayList<PlayerModel> playerModels;
  private ArrayList<BlasterModel> blasterModels;
  private WorldModel gameWorld;
  
  private Camera cam;
  
  public PlayerViewport(int viewportWidth, int viewportHeight, PVector screenCoords, Player currentPlayer, ArrayList<Player> players, World world) {
    super(viewportWidth, viewportHeight, screenCoords, DEFAULT_PRIORITY);
    this.currentPlayer = currentPlayer;
    this.gameWorld = new WorldModel(canvas, world);
    this.cam = new NativeThirdPersonCamera(canvas, currentPlayer);
    this.playerModels = new ArrayList();
    this.blasterModels = new ArrayList();
    for (Player player : players) {
      playerModels.add(new PlayerModel(canvas, player));
      blasterModels.add(new BlasterModel(canvas, player.blaster));
    }
  }  
  
  @Override
  protected void renderContent() {
    canvas.background(0); 
    gameWorld.display(true);
    
    for (BlasterModel blasterModel : blasterModels) {
      blasterModel.display();
    } 
      
    //We sort the players from farthest to closest based on their distance to current player.
    Collections.sort(playerModels, new Comparator<PlayerModel>() {
      @Override
      public int compare(PlayerModel modelA, PlayerModel modelB) {
        float distanceA = distanceBetween(cam.getPosition(), modelA.player.position);
        float distanceB = distanceBetween(cam.getPosition(), modelB.player.position);
        if (distanceA > distanceB) return -1;
        if (distanceA < distanceB) return 1;
        return 0;
      }
    });
    
    for (PlayerModel playerModel : playerModels) {
      playerModel.display();
    }    
  }
  
  @Override
   public void dispose() {
     appRoot.unregisterMethod("pre", this);
     currentPlayer.controller.dispose();
   }
  
}


/*-------------------------------- 
3. UI COMPONENTS
--------------------------------*/
class PlayerHUD extends UIComponent { 
  
  private ControlP5 controlP5;
  
  Player player;
  
  Knob speedmeter;
  
  public PlayerHUD(Player player, int componentWidth, int componentHeight, PVector screenCoords, int priority) {
    super(componentWidth, componentHeight,  screenCoords, priority);
    this.player = player;

    controlP5 = new ControlP5(appRoot);
    //controlP5.setBackground(BG_COLOR);
    controlP5.setGraphics(this.canvas, (int) screenCoords.x, (int) screenCoords.y);   
    
    setupPlayerLife();
    setupSpeedmeter(80);
  }
  
  private void setupPlayerLife() {
    // TO BE DONE
  }
  
  private void setupSpeedmeter(int radius) {
    speedmeter = controlP5.addKnob("Speed")
               .setRange(0, player.maxSpeed / LIGHT_SPEED)
               .setValue(0)
               .setPosition(canvas.width - 3*radius, canvas.height - 3*radius)
               .setRadius(radius)
               .setColorForeground(PRIMARY_FONT_COLOR)
               .setColorBackground(PRIMARY_COLOR)
               .setLock(true)
               ;
  }
  
  @Override
  protected void renderContent() {
    if (player.controller.moveForward || player.controller.moveBackward 
        || player.controller.moveLeft || player.controller.moveRight 
        || player.controller.moveUp || player.controller.moveDown) speedmeter.setColorForeground(INTERACT_COLOR);
    else speedmeter.setColorForeground(PRIMARY_FONT_COLOR);
    speedmeter.setValue(player.speed.mag()/LIGHT_SPEED  * 60 * DISTANCE_SCALE);
  }
  
  @Override
  public void dispose() {
    controlP5.dispose();
    controlP5.setVisible(false);
    controlP5.setAutoDraw(false);
  }

}
