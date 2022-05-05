import peasy.org.apache.commons.math.geometry.*;

class Spaceship {
  
  PImage sprite; // Looking right by default
  
  float pitch = 0.0;
  float yaw = 0.0;
  float roll = 0.0;
  
  PVector position = new PVector(0, 0, 50);
  
  Rotation orientation = new Rotation(0, 0, 0, 0, false);
  PVector direction = new PVector(0, 0, -1);      // Must be kept normalized
  PVector verticalAxis = new PVector(0, -1, 0);   // Must be kept normalized
  PVector horizontalAxis = new PVector(1, 0, 0);  // Must be kept normalized
  
  PVector speed = new PVector(0, 0, 0);
  PVector acceleration = new PVector(0, 0, 0);
  float maxSpeed = 500 * 300000; // X times the speed of light
  float engineAcceleration = 0.0025;
  
  
  Spaceship() {
    sprite = loadImage("./data/images/Spaceship.png");
    imageMode(CENTER);
  }
  
  void move() {            
    accelerate();
    position.add(speed);
    cameraControl.updateCamera();
    if (speed.mag() > 0) {
      soundsManager.startSpaceshipEngine();
    } else {
      soundsManager.stopSpaceshipEngine();
    }
  }
  
  void accelerate() {
    if (moveForward) {
      acceleration.add(direction.copy().setMag(engineAcceleration));
    }
    
    if (moveBackward) {
      acceleration.add(PVector.mult(direction, -1, null).setMag(engineAcceleration));
    }
  
    if (moveLeft) {
      PVector leftDirection = quaternionRotation(direction, verticalAxis, PI/2.0);
      acceleration.add(leftDirection.setMag(engineAcceleration));
      //acceleration.add(horizontalAxis.copy().mult(-1).setMag(engineAcceleration));
    }
    
    if (moveRight) {
      PVector rightDirection = quaternionRotation(direction, verticalAxis, -PI/2.0);
      acceleration.add(rightDirection.setMag(engineAcceleration));
      //acceleration.add(horizontalAxis.copy().setMag(engineAcceleration));
    }
    
    if (moveUp) {
      //PVector upDirection = quaternionRotation(direction, horizontalAxis, PI/2.0);
      //acceleration.add(upDirection.setMag(engineAcceleration));
      acceleration.add(verticalAxis.copy().setMag(engineAcceleration));
    }
    
    if (moveDown) {
      //PVector downDirection = quaternionRotation(direction, horizontalAxis, -PI/2.0);
      //acceleration.add(downDirection.setMag(engineAcceleration));
      acceleration.add(verticalAxis.copy().mult(-1).setMag(engineAcceleration));
    }
    
    if (moveStop) {
      speed = new PVector(0, 0, 0);
      acceleration = new PVector(0, 0, 0);
      return;
    }
    
    speed.add(acceleration);
    acceleration = new PVector(0, 0, 0);
    
    if (speed.mag()* 60 * DISTANCE_SCALE > maxSpeed) {
      speed.setMag((maxSpeed/DISTANCE_SCALE) / 60);
    }
        
  }
  
  void display(PGraphics canvas) {
    
    if (mode == EXPLORE){
      updateSpaceshipOrientation();
      move();
    }
    
    canvas.pushMatrix();    
      canvas.translate(width/2.0 + position.x, height/2.0 + position.y, position.z);  
      canvas.pushMatrix();
        if (mode == EXPLORE) {
          PMatrix billboardMatrix = generateBillboardMatrix(getMatrix());
          canvas.resetMatrix();
          canvas.applyMatrix(billboardMatrix);
        }
        //float[] cameraRotations = cameraControl.camera.getRotations();
        //rotateX();
        canvas.scale(0.0003);
        canvas.image(sprite, 0, 0);
      canvas.popMatrix();
    canvas.popMatrix();
  }
}
