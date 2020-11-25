import peasy.*;
import processing.core.PApplet;

class CameraControl {
  
  private PApplet parent;
  private PeasyCam camera;
  
  CameraControl(PApplet parent) {
    this.parent = parent;
    camera = new PeasyCam(parent, width/2.0, height/2.0, 0, 150000); // (height/2.0)/tan(PI*30.0/180.0)
    camera.setMinimumDistance(1);
    camera.setMaximumDistance(10000000);
  }
  
  PVector getCameraPosition() {  
    float[] cameraCoordinates = cameraControl.camera.getPosition();
    return new PVector(cameraCoordinates[0] - width/2.0, cameraCoordinates[1] - height/2.0, cameraCoordinates[2]);
  }
  
  void updateCamera() {
    if (mode != EXPLORE) return;   
    CameraState update = new CameraState(spaceship.orientation, new Vector3D(width/2.0 + spaceship.position.x, height/2.0 + spaceship.position.y, spaceship.position.z), 20.0);
    camera.setState(update, 0);
  }
  
  void switchCameraReference() {
    if (mode==GENERAL_VIEW) {
      camera = new PeasyCam(parent, width/2.0, height/2.0, 0, 150000);
      camera.setMinimumDistance(1);
      camera.setMaximumDistance(10000000);
    } else {
      camera = new PeasyCam(parent, width/2.0 + spaceship.position.x, height/2.0 + spaceship.position.y, spaceship.position.z, 20.0);
      camera.setActive(false);
      camera.setMouseControlled(false);
      camera.setResetOnDoubleClick(false);
      camera.setMinimumDistance(1);
      camera.setMaximumDistance(10000000);
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
