import peasy.*;
import processing.core.PApplet;

abstract class Camera {
  
  final float CAMERA_MAX_DISTANCE = 550;
  float CAMERA_DEFAULT_DISTANCE = 4;
  
  PVector position;
  PVector focus;
  PVector up;
  
  public abstract PVector getPosition();

}

interface CameraFocusable {

  PVector getPosition();
  PVector getDirection();
  Rotation getOrientation();

}


public class NativeThirdPersonCamera extends Camera {
  
  private PGraphics canvas;
  private Player focusedPlayer;

  
  public NativeThirdPersonCamera(PGraphics canvas, Player focusedPlayer) {
    this.canvas = canvas;
    this.focusedPlayer = focusedPlayer;
    update();
    appRoot.registerMethod("draw", this); 
  }
  
  public void draw() {
    update();
    canvas.camera(
                  width/2.0 + position.x, height/2.0 + position.y, position.z, 
                  width/2.0 + focus.x, height/2.0 + focus.y, focus.z, 
                  up.x, up.y, up.z);
    canvas.perspective(PI/3.0, (float)canvas.width/canvas.height, 1, 100000);
  }
  
  public void update() {
    position = new PVector(focusedPlayer.direction.x, focusedPlayer.direction.y, focusedPlayer.direction.z);
    position.setMag(CAMERA_DEFAULT_DISTANCE);
    position = PVector.sub(focusedPlayer.position, position);
    focus = focusedPlayer.position;
    //up = toPVector(focusedPlayer.orientation.applyTo(new Vector3D(0, 1, 0)));
    up = PVector.mult(focusedPlayer.verticalAxis, -1);
  }
  
  public PVector getPosition() {
    return position;
  }

}
