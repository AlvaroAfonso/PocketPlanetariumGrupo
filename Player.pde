import peasy.org.apache.commons.math.geometry.*;

class Player {

  String name;
  ControlScheme controlScheme;
  
  SoundsManager soundsManager;
  
  PVector spaceShipColor;
  
  float pitch = 0.0;
  float yaw = 0.0;
  float roll = 0.0;
  
  PVector position;
  
  int countFrame = 0;
  
  //Rotation orientation = new Rotation(0, 0, 0, 0, false);
  Rotation orientation = new Rotation();
  PVector direction = new PVector(0, 0, -1);      // Must be kept normalized
  PVector verticalAxis = new PVector(0, -1, 0);   // Must be kept normalized
  PVector horizontalAxis = new PVector(1, 0, 0);  // Must be kept normalized
  
  PVector speed = new PVector(0, 0, 0);
  PVector acceleration = new PVector(0, 0, 0);
  float maxSpeed = 1000 * 300000; // X times the speed of light
  float engineAcceleration = 0.0025;

  
  public Player(String name, ControlScheme controlScheme, PVector startingPosition) {
    this.name = name;
    this.controlScheme = controlScheme;
    this.position = startingPosition;
    soundsManager = new SoundsManager(papplet);
  }
  
  public void update() {
    updateOrientation();
    move();
  }
  
  private void move() {      
    
    //Space engine control
    if(controlScheme.moveForward || controlScheme.moveBackward || controlScheme.moveLeft || controlScheme.moveRight || controlScheme.moveUp || controlScheme.moveDown) {
      if(countFrame == 0){
      soundsManager.startSpaceshipEngine();
      }
      countFrame++;
      if(countFrame > 5) countFrame = 0;       
    }else{
      soundsManager.stopSpaceshipEngine();
      countFrame = 0;
    }
    
    if (controlScheme.moveForward) {
      acceleration.add(direction.copy().setMag(engineAcceleration));
    }    
    if (controlScheme.moveBackward) {
      acceleration.add(PVector.mult(direction, -1, null).setMag(engineAcceleration));
    }
  
    if (controlScheme.moveLeft) {
      PVector leftDirection = quaternionRotation(direction, verticalAxis, PI/2.0);
      acceleration.add(leftDirection.setMag(engineAcceleration));
    }
    
    if (controlScheme.moveRight) {
      PVector rightDirection = quaternionRotation(direction, verticalAxis, -PI/2.0);
      acceleration.add(rightDirection.setMag(engineAcceleration));
    }
    
    if (controlScheme.moveUp) {
      acceleration.add(verticalAxis.copy().setMag(engineAcceleration));
      //acceleration.add((new PVector(0, -1, 0)).setMag(engineAcceleration));
    }
    
    if (controlScheme.moveDown) {
      acceleration.add(verticalAxis.copy().mult(-1).setMag(engineAcceleration));
      //acceleration.add((new PVector(0, 1, 0)).setMag(engineAcceleration));
    }
    
    if (controlScheme.moveStop) {
      speed = new PVector(0, 0, 0);
      acceleration = new PVector(0, 0, 0);
      return;
    }
    
    speed.add(acceleration);
    acceleration = new PVector(0, 0, 0);
    
    if (speed.mag()* 60 * DISTANCE_SCALE > maxSpeed) {
      speed.setMag((maxSpeed/DISTANCE_SCALE) / 60);
    }    
    
    position.add(speed);
  }
  
  void updateOrientation() {  
    //if (mode != EXPLORE) return;
    if (controlScheme.playerFocus.y < height/2.0 - controlScheme.cameraSensitivityOffset) {
      
      pitch -= radians(((height/2.0) - (controlScheme.playerFocus.y + 1)) / (height/2.0) * controlScheme.cameraSensitivity);
      
    } else if (controlScheme.playerFocus.y > height/2.0 + controlScheme.cameraSensitivityOffset) {
      
      pitch += radians((controlScheme.playerFocus.y - height/2.0) / (height/2.0) * controlScheme.cameraSensitivity);
      
    }
    if (controlScheme.playerFocus.x < width/2.0 - controlScheme.cameraSensitivityOffset) {
      
      yaw += radians(((width/2.0) - (controlScheme.playerFocus.x + 1)) / (width/2.0) * controlScheme.cameraSensitivity);
      
    } else if (controlScheme.playerFocus.x > width/2.0 + controlScheme.cameraSensitivityOffset) {
      
      yaw -= radians((controlScheme.playerFocus.x - width/2.0) / (width/2.0) * controlScheme.cameraSensitivity);
      
    }
    
    if (pitch >= TWO_PI || pitch <= TWO_PI) pitch = 0 + pitch % TWO_PI;
    if (yaw >= TWO_PI || yaw <= TWO_PI) yaw = 0 + yaw % TWO_PI;
    
    Rotation verticalRotation = generateQuaternionRotor(new PVector(1, 0, 0), -pitch);
    Rotation horizontalRotation = generateQuaternionRotor(new PVector(0, -1, 0), yaw);
    Rotation rollRotation = generateQuaternionRotor(new PVector(0, 0, -1), roll);    
    
    //orientation = horizontalRotation.applyTo(verticalRotation);
    orientation = rollRotation.applyTo(horizontalRotation.applyTo(verticalRotation));
    
    direction = toPVector(orientation.applyTo(Vector3D.minusK)).normalize();
    horizontalAxis = toPVector(orientation.applyTo(Vector3D.plusI)).normalize();
    verticalAxis = toPVector(orientation.applyTo(Vector3D.minusJ)).normalize();

  }
  
}



class PlayerModel {
  
  PGraphics canvas;
  
  PImage sprite; // Looking right by default
  Player player;
  
  public PlayerModel(PGraphics canvas, Player player) {
    this.canvas = canvas;
    this.player = player;
    sprite = loadImage("./data/images/Spaceship.png");
    //imageMode(CENTER);
  }
  
  void display() { 
    /*
    if (mode == EXPLORE) {      
      if (player.speed.mag() > 0) {
        soundsManager.startSpaceshipEngine();
      } else {
        soundsManager.stopSpaceshipEngine();
      }   
    }
    */    
    canvas.pushMatrix();    
      canvas.translate(width/2.0 + player.position.x, height/2.0 + player.position.y, player.position.z);  
      canvas.pushMatrix();

        PMatrix billboardMatrix = generateBillboardMatrix(canvas.getMatrix());
        canvas.resetMatrix();
        canvas.applyMatrix(billboardMatrix);
        
        //float[] cameraRotations = cameraControl.camera.getRotations();
        //rotateX();
        canvas.pushStyle();
          canvas.noLights();
          canvas.imageMode(CENTER);
          canvas.scale(0.003);
          //Dcanvas.scale(0.05);
          canvas.image(sprite, 0, 0);
        canvas.popStyle();
      canvas.popMatrix();
    canvas.popMatrix();    
  }
  
}

    
