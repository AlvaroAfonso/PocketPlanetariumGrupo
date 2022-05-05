

interface Viewport {
  
  public void update();
  public void renderGraphics();
  
}

class MatchViewport implements Viewport {

  private PGraphics canvas;
  
  private Player currentPlayer;
  private Player[] players;
  private WorldRender gameWorld;
  
  private Camera cam;
  
  public MatchViewport(Player currentPlayer, Player[] players, WorldRender world) {
  
  }  
  
  public void update() {
  
  }
  
  public void renderGraphics() {
    gameWorld.display(canvas, true);
    canvas.camera(cam.eye.x, cam.eye.y, cam.eye.z, cam.center.x, cam.center.y, cam.center.z, cam.up.x, cam.up.y, cam.up.z);
  }
  
}


class Camera {
  
  PVector eye;
  PVector center;
  PVector up;

}
