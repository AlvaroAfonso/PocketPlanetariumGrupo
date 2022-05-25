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
  float matchTime;
  float planetsOrbitationSpeed;
  
  public VersusMatchConfig(ArrayList<Player> players, World worldData) {
    this.players = players;
    this.worldData = worldData;
    viewportLayout = Layout.VERTICAL;
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
   3.1. VIEWPORT UI COMPONENTS
--------------------------------*/


/*-------------------------------- 
4. UI COMPONENTS
--------------------------------*/
