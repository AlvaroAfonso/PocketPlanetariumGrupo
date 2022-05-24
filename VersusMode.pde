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
  
  public VersusMatchConfig(Player[] players, World worldData) {
    this.players = players;
    this.worldData = worldData;
    viewportLayout = Layout.VERTICAL;
  }
  
}


/*--------------------------------  
            2. SCENE
--------------------------------*/
public class VersusMatchScene extends Scene {
  
  private Player[] players;
  private World worldData;
  
  public VersusMatchScene(VersusMatchConfig config) {
    super();    
    this.players = config.players;
    this.worldData = config.worldData;
    
    int viewportWidth = config.viewportLayout == Layout.VERTICAL ? width/config.players.length : width;
    int viewportHeight = config.viewportLayout == Layout.HORIZONTAL ? height/config.players.length : height;
    
    for (int i = 0; i < players.length; i++) {
      PVector viewportCoords = config.viewportLayout == Layout.VERTICAL ? new PVector(i*viewportWidth, 0) : new PVector(0, i*viewportHeight);
      viewports.add(new PlayerViewport(viewportWidth, viewportHeight, viewportCoords, players[i], players, worldData));
      uiComponents.add(new PlayerHUD(players[i], viewportWidth, viewportHeight, viewportCoords, Panel.DEFAULT_PRIORITY + 1000));
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
  
  public PlayerViewport(int viewportWidth, int viewportHeight, PVector screenCoords, Player currentPlayer, Player[] players, World world) {
    super(viewportWidth, viewportHeight, screenCoords, DEFAULT_PRIORITY);
    this.currentPlayer = currentPlayer;
    this.players = new ArrayList();
    this.gameWorld = new WorldModel(canvas, world);
    this.cam = new NativeThirdPersonCamera(canvas, currentPlayer);
    for (Player player : players) {
      this.players.add(new PlayerModel(canvas, player));
    }
  }  
  
  @Override
  protected void renderContent() {
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
      
    for (PlayerModel model : players) {
      model.display();
    }
  }
  
}


/*-------------------------------- 
   3.1. VIEWPORT UI COMPONENTS
--------------------------------*/


/*-------------------------------- 
4. UI COMPONENTS
--------------------------------*/
