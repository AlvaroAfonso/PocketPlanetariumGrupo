import peasy.*;
import processing.core.PApplet;

abstract class Camera {
  
  final float CAMERA_MAX_DISTANCE = 550;
  float CAMERA_DEFAULT_DISTANCE = 7;
  
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
  
  private PApplet parent;
  private PGraphics canvas;
  private Player focusedPlayer;

  
  public NativeThirdPersonCamera(PApplet parent, PGraphics canvas, Player focusedPlayer) {
    this.parent = parent;
    this.canvas = canvas;
    this.focusedPlayer = focusedPlayer;
    parent.registerMethod("draw", this); 
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
    up = toPVector(focusedPlayer.orientation.applyTo(new Vector3D(0, 1, 0)));
    //up = focusedPlayer.verticalAxis;
  }
  
  public PVector getPosition() {
    return position;
  }

}


/*
class CustomPeasyCamera extends Camera {
  
  private PApplet parent;
  private PeasyCam camera;
  
  private Player player;
  
  CustomPeasyCamera(PApplet parent, PGraphics canvas, Player player) {
    //super();
    this.parent = parent;
    this.player = player;
    camera = new PeasyCam(parent, canvas, width/2.0 + player.position.x, height/2.0 + player.position.y, player.position.z, super.CAMERA_DEFAULT_DISTANCE_TO_SHIP);
    //camera = new PeasyCam(parent, canvas, width/2.0, height/2.0, 0, super.CAMERA_DEFAULT_DISTANCE); // (height/2.0)/tan(PI*30.0/180.0)
    //camera.setActive(false);
    //camera.setMouseControlled(false);
    //camera.setResetOnDoubleClick(false);
    //camera.setMinimumDistance(1);
    camera.setMaximumDistance(super.CAMERA_MAX_DISTANCE);
    parent.registerMethod("draw", this); 
    //update();
  }
  
  PVector getPosition() {  
    float[] cameraCoordinates = camera.getPosition();
    return new PVector(cameraCoordinates[0] - width/2.0, cameraCoordinates[1] - height/2.0, cameraCoordinates[2]);
  }
  
  public void draw() {
    if (mode != EXPLORE) return;   
    CameraState update = new CameraState(player.orientation, new Vector3D(width/2.0 + player.position.x, height/2.0 + player.position.y, player.position.z), super.CAMERA_DEFAULT_DISTANCE_TO_SHIP);
    camera.setState(update, 0);
  }
  
  void beginHUD() {
    camera.beginHUD();
  }
  
  void endHUD() {
    camera.endHUD();
  }
  
}


/*
class CameraControl extends Camera {
  
  private PApplet parent;
  private PeasyCam camera;
  
  CameraControl(PApplet parent, PGraphics pg) {
    this.parent = parent;
    camera = new PeasyCam(parent, pg, width/2.0, height/2.0, 0, super.CAMERA_DEFAULT_DISTANCE); // (height/2.0)/tan(PI*30.0/180.0)
    //camera.setMinimumDistance(0.0000000001);
    camera.setMaximumDistance(super.CAMERA_MAX_DISTANCE);
  }
  
  PVector getCameraPosition() {  
    float[] cameraCoordinates = cameraControl.camera.getPosition();
    return new PVector(cameraCoordinates[0] - width/2.0, cameraCoordinates[1] - height/2.0, cameraCoordinates[2]);
  }
  
  void updateCamera(Rotation orientation, PVector position) {
    if (mode != EXPLORE) return;   
    CameraState update = new CameraState(orientation, new Vector3D(width/2.0 + position.x, height/2.0 + position.y, position.z), super.CAMERA_DEFAULT_DISTANCE_TO_SHIP);
    camera.setState(update, 0);
  }
  
  void switchCameraReference(Rotation orientation, PVector position) {
    if (mode==GENERAL_VIEW) {
      camera = new PeasyCam(parent, width/2.0, height/2.0, 0, super.CAMERA_DEFAULT_DISTANCE);
      //camera.setMinimumDistance(0.0000000001);
      camera.setMaximumDistance(super.CAMERA_MAX_DISTANCE);
    } else {
      camera = new PeasyCam(parent, width/2.0 + position.x, height/2.0 + position.y, position.z, super.CAMERA_DEFAULT_DISTANCE_TO_SHIP);
      camera.setActive(false);
      camera.setMouseControlled(false);
      camera.setResetOnDoubleClick(false);
      //camera.setMinimumDistance(1);
      camera.setMaximumDistance(super.CAMERA_MAX_DISTANCE);
      updateCamera(orientation, position);
    }
  }
  
  void beginHUD() {
    camera.beginHUD();
  }
  
  void endHUD() {
    camera.endHUD();
  }
  
}
*/
