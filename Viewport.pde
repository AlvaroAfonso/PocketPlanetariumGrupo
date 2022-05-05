

interface Viewport {
  
  public void update();
  public void renderGraphics();
  
}

class MatchViewport implements Viewport {

  private PVector screenCoords;
  private PGraphics canvas;
  
  private Player currentPlayer;
  private Player[] players;
  private WorldRender gameWorld;
  
  private Camera cam;
  
  public MatchViewport(PVector screenCoords, PGraphics canvas, WorldData world) {
    this.screenCoords = screenCoords;
    this.canvas = canvas;
    this.gameWorld = new WorldRender(canvas, world);  
  }  
  
  public void update() {
  
  }
  
  public void renderGraphics() {
    canvas.beginDraw();
      canvas.background(0); 
      gameWorld.display(true);
      //canvas.camera(cam.eye.x, cam.eye.y, cam.eye.z, cam.center.x, cam.center.y, cam.center.z, cam.up.x, cam.up.y, cam.up.z);
    canvas.endDraw();
    image(canvas, screenCoords.x, screenCoords.y);
  }
  
}


class Camera {
  
  PVector eye;
  PVector center;
  PVector up;

}
