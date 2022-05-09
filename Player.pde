import peasy.org.apache.commons.math.geometry.*;

class Player {

  String name;
  ControlScheme controlScheme;
  
  PVector spaceShipColor;
  
  float pitch = 0.0;
  float yaw = 0.0;
  float roll = 0.0;
  
  PVector position;
  
  Rotation orientation = new Rotation(0, 0, 0, 0, false);
  PVector direction = new PVector(0, 0, -1);      // Must be kept normalized
  PVector verticalAxis = new PVector(0, -1, 0);   // Must be kept normalized
  PVector horizontalAxis = new PVector(1, 0, 0);  // Must be kept normalized
  
  PVector speed = new PVector(0, 0, 0);
  PVector acceleration = new PVector(0, 0, 0);
  float maxSpeed = 500 * 300000; // X times the speed of light
  float engineAcceleration = 0.0025;

  
  public Player(String name, ControlScheme controlScheme, PVector startingPosition) {
    this.name = name;
    this.controlScheme = controlScheme;
    this.position = startingPosition;
  }
  
  public void update() {
    //updateOrientation();
    move();
  }
  
  private void move() {            
    if (controlScheme.moveForward) {
      acceleration.add(direction.copy().setMag(engineAcceleration));
    }    
    if (controlScheme.moveBackward) {
      acceleration.add(PVector.mult(direction, -1, null).setMag(engineAcceleration));
    }
  
    if (controlScheme.moveLeft) {
      PVector leftDirection = quaternionRotation(direction, verticalAxis, PI/2.0);
      acceleration.add(leftDirection.setMag(engineAcceleration));
      //acceleration.add(horizontalAxis.copy().mult(-1).setMag(engineAcceleration));
    }
    
    if (controlScheme.moveRight) {
      PVector rightDirection = quaternionRotation(direction, verticalAxis, -PI/2.0);
      acceleration.add(rightDirection.setMag(engineAcceleration));
      //acceleration.add(horizontalAxis.copy().setMag(engineAcceleration));
    }
    
    if (controlScheme.moveUp) {
      //PVector upDirection = quaternionRotation(direction, horizontalAxis, PI/2.0);
      //acceleration.add(upDirection.setMag(engineAcceleration));
      acceleration.add(verticalAxis.copy().setMag(engineAcceleration));
    }
    
    if (controlScheme.moveDown) {
      //PVector downDirection = quaternionRotation(direction, horizontalAxis, -PI/2.0);
      //acceleration.add(downDirection.setMag(engineAcceleration));
      acceleration.add(verticalAxis.copy().mult(-1).setMag(engineAcceleration));
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
    if (controlScheme.playerFocus.y < height/2.0 - controlScheme.sensitivityOffset) {
      
      pitch -= radians(((height/2.0) - (controlScheme.playerFocus.y + 1)) / (height/2.0) * controlScheme.sensitivity);
      
    } else if (controlScheme.playerFocus.y > height/2.0 + controlScheme.sensitivityOffset) {
      
      pitch += radians((controlScheme.playerFocus.y - height/2.0) / (height/2.0) * controlScheme.sensitivity);
      
    }
    if (controlScheme.playerFocus.x < width/2.0 - controlScheme.sensitivityOffset) {
      
      yaw += radians(((width/2.0) - (controlScheme.playerFocus.x + 1)) / (width/2.0) * controlScheme.sensitivity);
      
    } else if (controlScheme.playerFocus.x > width/2.0 + controlScheme.sensitivityOffset) {
      
      yaw -= radians((controlScheme.playerFocus.x - width/2.0) / (width/2.0) * controlScheme.sensitivity);
      
    }
    
    if (pitch >= TWO_PI || pitch <= TWO_PI) pitch = 0 + pitch % TWO_PI;
    if (yaw >= TWO_PI || yaw <= TWO_PI) yaw = 0 + yaw % TWO_PI;
    
    Rotation verticalRotation = generateQuaternionRotor(horizontalAxis, -pitch);
    Rotation horizontalRotation = generateQuaternionRotor(verticalAxis, yaw);
    
    orientation = horizontalRotation.applyTo(verticalRotation);
   
    direction = toPVector(orientation.applyTo(new Vector3D(0, 0, -1)));
    
    //spaceship.verticalAxis = toPVector(spaceship.orientation.applyTo(toVector3D(spaceship.verticalAxis))).normalize();
    //spaceship.horizontalAxis = toPVector(spaceship.orientation.applyTo(toVector3D(spaceship.horizontalAxis))).normalize();
    
    //println("\n\nDir: " + spaceship.direction);
    //println("Vertical Axis: " + spaceship.verticalAxis);
    //println("Horizontal Axis: " + spaceship.horizontalAxis);
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
      /*
        PMatrix billboardMatrix = generateBillboardMatrix(getMatrix());
        canvas.resetMatrix();
        canvas.applyMatrix(billboardMatrix);
      */
        //float[] cameraRotations = cameraControl.camera.getRotations();
        //rotateX();
        canvas.pushStyle();
          canvas.noLights();
          canvas.imageMode(CENTER);
          //canvas.scale(0.0003);
          canvas.scale(0.05);
          canvas.image(sprite, 0, 0);
        canvas.popStyle();
      canvas.popMatrix();
    canvas.popMatrix();    
  }
  
}

    
