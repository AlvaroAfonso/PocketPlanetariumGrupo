
enum Command {
    MOVE_FORWARD,
    MOVE_BACKWARD,
    MOVE_LEFT,
    MOVE_RIGHT,
    MOVE_UP,
    MOVE_DOWN,
    STOP,
    
    CAMERA_UP,
    CAMERA_DOWN,
    CAMERA_LEFT,
    CAMERA_RIGHT
}

abstract class ControlScheme {
  // camera controls
  PlayerFocus playerFocus;
  float cameraSensitivity;
  int cameraSensitivityOffset;
  
  // main keyboard controls
  boolean moveForward = false;
  boolean moveLeft = false;
  boolean moveBackward = false;
  boolean moveRight = false;
  boolean moveUp = false;
  boolean moveDown = false;
  boolean moveStop = false;
  
  // solar system controls
  boolean speedUp = false;
  boolean slowDown = false;
  
  // system controls
  
}

class PlayerFocus {  
   float x;
   float y;   
   
   public PlayerFocus(float x, float y) {
     this.x = x;
     this.y = y;
   }
} //<>//
