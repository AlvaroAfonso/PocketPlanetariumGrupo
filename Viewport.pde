import java.util.*;

interface Viewport {
  
  public void update();
  public void renderGraphics();
  
}

class MatchViewport implements Viewport {

  private PVector screenCoords;
  private PGraphics canvas;
  
  private Player currentPlayer;
  private ArrayList<PlayerModel> players;
  private WorldModel gameWorld;
  
  private Camera cam;
  
  public MatchViewport(PApplet parent, int viewportWidth, int viewportHeight, PVector screenCoords, Player currentPlayer, Player[] players, World world) {
    this.screenCoords = screenCoords;
    this.canvas = createGraphics(viewportWidth, viewportHeight, P3D);
    this.currentPlayer = currentPlayer;
    this.players = new ArrayList();
    this.gameWorld = new WorldModel(canvas, world);
    //this.cam =  new CustomPeasyCamera(parent, canvas, currentPlayer);
    this.cam = new NativeThirdPersonCamera(parent, canvas, currentPlayer);

    for (Player player : players) {
      this.players.add(new PlayerModel(canvas, player));
    }

  }  
  
  public void update() {
    
  }
  
  public void renderGraphics() {
    canvas.beginDraw();
      canvas.background(0); 
      gameWorld.display(true);
      
      // We sort the players based on their distance to current player from farthest to closest.
      Collections.sort(players, new Comparator<PlayerModel>() {
        @Override
        public int compare(PlayerModel playerModelA, PlayerModel playerModelB) {
          float distanceA = distanceBetween(cam.getPosition(), playerModelA.player.position);
          float distanceB = distanceBetween(cam.getPosition(), playerModelB.player.position);
          if (distanceA > distanceB) return -1;
          if (distanceA < distanceB) return 1;
          return 0;
        }
      });
      
      for (PlayerModel player : players) {
        player.display();
      }
      //canvas.perspective(PI/3.0,(float)width/height,1, 900);
    canvas.endDraw();
    image(canvas, screenCoords.x, screenCoords.y);
  }
  
}
