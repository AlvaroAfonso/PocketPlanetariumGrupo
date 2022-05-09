

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
    this.cam =  new CustomPeasyCamera(parent, canvas, currentPlayer);

    for (Player player : players) {
      this.players.add(new PlayerModel(canvas, player));
    }

  }  
  
  public void update() {
    
  }
  
  public void renderGraphics() {
    //cam.update();
    canvas.beginDraw();
      canvas.background(0); 
      gameWorld.display(true);

      for (PlayerModel player : players) {
        player.display();
      }

      //canvas.camera(cam.eye.x, cam.eye.y, cam.eye.z, cam.center.x, cam.center.y, cam.center.z, cam.up.x, cam.up.y, cam.up.z);
    canvas.endDraw();
    //cam.update();
    image(canvas, screenCoords.x, screenCoords.y);
  }
  
}
