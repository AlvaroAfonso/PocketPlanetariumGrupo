/*
*  -Index-
*    1. PLAYER COMMANDS
*    2. PLAYER 
*    3. PLAYER MODEL
*/


/*-------------------------------- 
1. PLAYER COMMANDS
--------------------------------*/
enum PlayerCommand {
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


/*-------------------------------- 
2. PLAYER
--------------------------------*/
class Player {
  
  public float maxSpeed = 1000 * LIGHT_SPEED;
  public float engineAcceleration = 0.003;

  String name;
  Control controller;
  
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
  

  
  public Player(String name, Control controlScheme, PVector startingPosition) {
    this.name = name;
    this.controller = controlScheme;
    this.position = startingPosition;
    soundsManager = new SoundsManager();
  }
  
  public void update() {
    updateOrientation();
    move();
  }
  
  private void move() {          
    if (controller.moveForward) {
      acceleration.add(direction.copy().setMag(engineAcceleration));
    }    
    if (controller.moveBackward) {
      acceleration.add(PVector.mult(direction, -1, null).setMag(engineAcceleration));
    }
  
    if (controller.moveLeft) {
      PVector leftDirection = quaternionRotation(direction, verticalAxis, PI/2.0);
      acceleration.add(leftDirection.setMag(engineAcceleration));
    }
    
    if (controller.moveRight) {
      PVector rightDirection = quaternionRotation(direction, verticalAxis, -PI/2.0);
      acceleration.add(rightDirection.setMag(engineAcceleration));
    }
    
    if (controller.moveUp) {
      acceleration.add(verticalAxis.copy().setMag(engineAcceleration));
      //acceleration.add((new PVector(0, -1, 0)).setMag(engineAcceleration));
    }
    
    if (controller.moveDown) {
      acceleration.add(verticalAxis.copy().mult(-1).setMag(engineAcceleration));
      //acceleration.add((new PVector(0, 1, 0)).setMag(engineAcceleration));
    }
    
    if (controller.moveStop) {
      speed = new PVector(0, 0, 0);
      acceleration = new PVector(0, 0, 0);
      return;
    }
    
    // Sound
    if (acceleration.mag() > 0 && countFrame++ == 0) {
      soundsManager.startSpaceshipEngine();
      if(countFrame > 5) countFrame = 0;       
    } else {
      soundsManager.stopSpaceshipEngine();
      countFrame = 0;
    }
    
    speed.add(acceleration);
    acceleration = new PVector(0, 0, 0);
    
    if (speed.mag()* 60 * DISTANCE_SCALE > maxSpeed) speed.setMag((maxSpeed/DISTANCE_SCALE) / 60);
    
    position.add(speed);
  }
  
  void updateOrientation() {  
    if (controller.playerFocus.y < height/2.0 - controller.cameraSensitivityOffset) { 
      pitch -= radians(((height/2.0) - (controller.playerFocus.y + 1)) / (height/2.0) * controller.cameraSensitivity);
    } else if (controller.playerFocus.y > height/2.0 + controller.cameraSensitivityOffset) { 
      pitch += radians((controller.playerFocus.y - height/2.0) / (height/2.0) * controller.cameraSensitivity);     
    }
    
    if (controller.playerFocus.x < width/2.0 - controller.cameraSensitivityOffset) {    
      yaw += radians(((width/2.0) - (controller.playerFocus.x + 1)) / (width/2.0) * controller.cameraSensitivity);   
    } else if (controller.playerFocus.x > width/2.0 + controller.cameraSensitivityOffset) {
      yaw -= radians((controller.playerFocus.x - width/2.0) / (width/2.0) * controller.cameraSensitivity);     
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


/*-------------------------------- 
3. PLAYER MODEL
--------------------------------*/
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
    canvas.pushMatrix();    
      canvas.translate(width/2.0 + player.position.x, height/2.0 + player.position.y, player.position.z);  
      canvas.pushMatrix();
      
        try {
          double[] eulerAngles = player.orientation.getAngles(RotationOrder.XYZ);
          canvas.rotateX((float) eulerAngles[0]);
          canvas.rotateY((float) eulerAngles[1]);
          canvas.rotateZ((float) eulerAngles[2]);
        } catch (Exception e) {
          PMatrix billboardMatrix = generateBillboardMatrix(canvas.getMatrix());
          canvas.resetMatrix();
          canvas.applyMatrix(billboardMatrix);
        }
        
        canvas.pushStyle();
          canvas.noLights();
          canvas.imageMode(CENTER);
          canvas.scale(0.001);
          //canvas.scale(0.05);
          canvas.image(sprite, 0, 0);
        canvas.popStyle();
      canvas.popMatrix();
    canvas.popMatrix();    
  }
  
}   
