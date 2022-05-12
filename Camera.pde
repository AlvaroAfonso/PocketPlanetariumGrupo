import peasy.*;
import processing.core.PApplet;

abstract class Camera {
  
  private final float CAMERA_MAX_DISTANCE = 550;
  private final float CAMERA_DEFAULT_DISTANCE = 120;
  private final float CAMERA_DEFAULT_DISTANCE_TO_SHIP = 200.0;
  
  PVector eye;
  PVector center;
  PVector up;
  
  public abstract void update();
  public abstract PVector getPosition();

}

interface CameraFocusable {

  PVector getPosition();

}


public class NativeCamera extends Camera {
  
  private PApplet parent;
  private PGraphics canvas;
  
  public NativeCamera(PApplet parent, PGraphics canvas) {
    this.parent = parent;
    this.canvas = canvas;
    parent.registerMethod("draw", this); 
  }
  
  public void draw() {
    canvas.camera(eye.x, eye.y, eye.z, center.x, center.y, center.z, up.x, up.y, up.z);
  }
  
  public void update() {}
  
  public PVector getPosition() {
    return new PVector();
  }

}



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
    //update();
  }
  
  PVector getPosition() {  
    float[] cameraCoordinates = camera.getPosition();
    return new PVector(cameraCoordinates[0] - width/2.0, cameraCoordinates[1] - height/2.0, cameraCoordinates[2]);
  }
  
  void update() {
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
