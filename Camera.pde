import peasy.*;
import processing.core.PApplet;

class CameraControl {
  
  private final float CAMERA_MAX_DISTANCE = 550;
  private final float CAMERA_DEFAULT_DISTANCE = 120;
  private final float CAMERA_DEFAULT_DISTANCE_TO_SHIP = 2.0;
  
  private PApplet parent;
  private PeasyCam camera;
  
  CameraControl(PApplet parent, PGraphics pg) {
    this.parent = parent;
    camera = new PeasyCam(parent, pg, width/2.0, height/2.0, 0, CAMERA_DEFAULT_DISTANCE); // (height/2.0)/tan(PI*30.0/180.0)
    //camera.setMinimumDistance(0.0000000001);
    camera.setMaximumDistance(CAMERA_MAX_DISTANCE);
  }
  
  PVector getCameraPosition() {  
    float[] cameraCoordinates = cameraControl.camera.getPosition();
    return new PVector(cameraCoordinates[0] - width/2.0, cameraCoordinates[1] - height/2.0, cameraCoordinates[2]);
  }
  
  void updateCamera() {
    if (mode != EXPLORE) return;   
    CameraState update = new CameraState(spaceship.orientation, new Vector3D(width/2.0 + spaceship.position.x, height/2.0 + spaceship.position.y, spaceship.position.z), CAMERA_DEFAULT_DISTANCE_TO_SHIP);
    camera.setState(update, 0);
  }
  
  void switchCameraReference() {
    if (mode==GENERAL_VIEW) {
      camera = new PeasyCam(parent, width/2.0, height/2.0, 0, CAMERA_DEFAULT_DISTANCE);
      //camera.setMinimumDistance(0.0000000001);
      camera.setMaximumDistance(CAMERA_MAX_DISTANCE);
    } else {
      camera = new PeasyCam(parent, width/2.0 + spaceship.position.x, height/2.0 + spaceship.position.y, spaceship.position.z, CAMERA_DEFAULT_DISTANCE_TO_SHIP);
      camera.setActive(false);
      camera.setMouseControlled(false);
      camera.setResetOnDoubleClick(false);
      //camera.setMinimumDistance(1);
      camera.setMaximumDistance(CAMERA_MAX_DISTANCE);
      updateCamera();
    }
  }
  
  void beginHUD() {
    camera.beginHUD();
  }
  
  void endHUD() {
    camera.endHUD();
  }
  
}
