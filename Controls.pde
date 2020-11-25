private final int W = 119;
private final int A = 97;
private final int R = 114;
private final int S = 115;
private final int D = 100;
private final int X = 120;
private final int SPACE = 32;

public boolean moveForward = false;
public boolean moveLeft = false;
public boolean moveBackward = false;
public boolean moveRight = false;
public boolean moveUp = false;
public boolean moveDown = false;
public boolean moveStop = false;
    

void keyPressed() {
  
  if (key == ENTER) {
    mode = mode==GENERAL_VIEW? EXPLORE : GENERAL_VIEW;
    cameraControl.switchCameraReference();  
    soundsManager.switchBackgroundMusic();
  }
  
  // ---------------- HUD CONTROLS ----------------
  if (key == TAB) {
    showHUD = !showHUD;
    return;
  }
  
  // ---------------- TIME CONTROL ----------------
  if (key == CODED) {
    if (keyCode == UP) {
      SPEED_FACTOR = SPEED_FACTOR == 1 ? SPEED_FACTOR + 9 : SPEED_FACTOR + 10;
      if (SPEED_FACTOR > 10000) SPEED_FACTOR = 10000;
      solarSystem.updateTimeParams();
    }
    
    if (keyCode == DOWN) {
      SPEED_FACTOR -= 10;
      if (SPEED_FACTOR < 1) SPEED_FACTOR = 1;
      solarSystem.updateTimeParams();
    }
    return;
  }
  
  // ---------------- SPACESHIP CONTROLS ----------------  
  if (key == W) {
    moveForward = true;
  }
  if (key == A) {
    moveLeft = true;
  }  
  if (key == S) {
    moveBackward = true;
  }
  if (key == D) {
    moveRight = true;
  }
  if (key == SPACE) {
    moveUp = true;
  } 
  if (key == X) {
    moveDown = true;
  }
  if (key == R) {
    moveStop = true;
  }
}

void keyReleased() {
  if (key == W) {
    moveForward = false;
  }
  if (key == A) {
    moveLeft = false;
  }
  if (key == S) {
    moveBackward = false;
  }
  if (key == D) {
    moveRight = false;
  }
  if (key == SPACE) {
    moveUp = false;
  } 
  if (key == X) {
    moveDown = false;
  }
  if (key == R) {
    moveStop = false;
  }
}

void updateSpaceshipOrientation() {  
  //if (mode != EXPLORE) return;
  
  float angularSpeed = 1.75;
  int center_offset = 150;
  if (mouseY < height/2.0 - center_offset) {
    spaceship.pitch -= radians(((height/2.0) - (mouseY + 1)) / (height/2.0) * angularSpeed);
  } else if (mouseY > height/2.0 + center_offset) {
    spaceship.pitch += radians((mouseY - height/2.0) / (height/2.0) * angularSpeed);
  }
  
  if (mouseX < width/2.0 - center_offset) {
    spaceship.yaw += radians(((width/2.0) - (mouseX + 1)) / (width/2.0) * angularSpeed);
  } else if (mouseX > width/2.0 + center_offset) {
    spaceship.yaw -= radians((mouseX - width/2.0) / (width/2.0) * angularSpeed);
  }
  
  if (spaceship.pitch >= TWO_PI || spaceship.pitch <= TWO_PI) spaceship.pitch = 0 + spaceship.pitch % TWO_PI;
  if (spaceship.yaw >= TWO_PI || spaceship.yaw <= TWO_PI) spaceship.yaw = 0 + spaceship.yaw % TWO_PI;
  
  Rotation verticalRotation = generateQuaternionRotor(spaceship.horizontalAxis, -spaceship.pitch);
  Rotation horizontalRotation = generateQuaternionRotor(spaceship.verticalAxis, spaceship.yaw);
  
  spaceship.orientation = horizontalRotation.applyTo(verticalRotation);
 
  spaceship.direction = toPVector(spaceship.orientation.applyTo(new Vector3D(0, 0, -1)));
  
  //spaceship.verticalAxis = toPVector(spaceship.orientation.applyTo(toVector3D(spaceship.verticalAxis))).normalize();
  //spaceship.horizontalAxis = toPVector(spaceship.orientation.applyTo(toVector3D(spaceship.horizontalAxis))).normalize();
  
  //println("\n\nDir: " + spaceship.direction);
  //println("Vertical Axis: " + spaceship.verticalAxis);
  //println("Horizontal Axis: " + spaceship.horizontalAxis);
  
   cameraControl.updateCamera();
}
