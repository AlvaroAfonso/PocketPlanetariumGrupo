

class Player {

  Spaceship spaceship;
  ControlScheme controlScheme;
  
}

abstract class ControlScheme {
  
  boolean moveForward = false;
  boolean moveLeft = false;
  boolean moveBackward = false;
  boolean moveRight = false;
  boolean moveUp = false;
  boolean moveDown = false;
  boolean moveStop = false;
  
  boolean speedUp = false;
  boolean slowDown = false;
  
}
