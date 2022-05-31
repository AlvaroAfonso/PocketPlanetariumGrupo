/*
*  -Index-
*    1. PLAYER COMMANDS
*    2. PLAYER 
*    3. PLAYER MODEL
*    4. BULLET
*    5. BLASTER
*    6. BULLET MODEL
*    7. BLASTER MODEL
*    8. TAIL 
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
    SHOOT,
    
    CAMERA_UP,
    CAMERA_DOWN,
    CAMERA_LEFT,
    CAMERA_RIGHT
}


/*-------------------------------- 
2. PLAYER
--------------------------------*/
class Player implements Collisionable {
  
  public float maxSpeed = 1000 * LIGHT_SPEED;
  public float engineAcceleration = 0.003;

  String name;
  int id;
  Control controller;
  
  PVector spaceShipColor;
  
  float pitch = 0.0;
  float yaw = 0.0;
  float roll = 0.0;
  
  PVector position;
  HitBox hitbox;
  
  int countFrame = 0;
  
  //Rotation orientation = new Rotation(0, 0, 0, 0, false);
  Rotation orientation = new Rotation();
  PVector direction = new PVector(0, 0, -1);      // Must be kept normalized
  PVector verticalAxis = new PVector(0, -1, 0);   // Must be kept normalized
  PVector horizontalAxis = new PVector(1, 0, 0);  // Must be kept normalized
  
  PVector speed = new PVector(0, 0, 0);
  PVector acceleration = new PVector(0, 0, 0);
  
  Blaster blaster;
  
  public Player(String name, Control controller, PVector startingPosition) {
    this.name = name;
    this.controller = controller;
    this.position = startingPosition;
    this.hitbox = new HitBox(loadImage("./data/images/Spaceship.png"), 0.001, this.position);
    this.blaster = new Blaster(50);
  }
  
  public void setLives(int lives) {
  
  }
  
  public void setMaxSpeed(int maxSpeed) {
  
  }
  
  public void setBulletSpeed(int bulletSpeed) {
  
  }
  
  public void switchController(Control controller) {
    this.controller = controller;
  }
  
  public void update() {
    updateOrientation();
    move();
    blaster.update();
    this.hitbox.position = position;
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
    
    if (controller.activateBlaster) blaster.shoot(PVector.add(position, direction.copy().setMag(4*earthRadius)), direction); 
    
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
  
  public CollisionMesh getCollisionMesh() {
    return hitbox;
  }
  
}


/*-------------------------------- 
3. PLAYER MODEL
--------------------------------*/
class PlayerModel {
  
  PGraphics canvas;
  
  PImage sprite; // Looking right by default
  Player player;
  
  Tail tail;
  
  public PlayerModel(PGraphics canvas, Player player) {
    this.canvas = canvas;
    this.player = player;
    this.sprite = loadImage("./data/images/Spaceship.png");
    //imageMode(CENTER);
    this.tail = new Tail(canvas, player.position, player.maxSpeed);
  }
  
  void display() {  
    
    if (player.speed.mag() > 0 && innerProduct(player.speed, player.direction) > PI/2) {
      tail.updateHead(player.position, player.speed);
      tail.display();
    }
    
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
    
    canvas.pointLight(255, 255, 255, width/2.0, height/2.0, 0);
    
    if (player.speed.mag() > 0 && innerProduct(player.speed, player.direction) <= PI/2) {
      tail.updateHead(player.position, player.speed);
      tail.display();
    }
  }
  
}   


/*-------------------------------- 
4. BULLET
--------------------------------*/
class Bullet  implements Collisionable {
  
  float baseSpeed = 300 * LIGHT_SPEED / DISTANCE_SCALE / 60;
  
  PVector position;
  PVector direction;
  PVector speed;
  int timeout;
  
  HitBox hitbox;
  boolean exploded;
  int explosionDuration;
  
  Player trackedPlayer;
  
  public Bullet(PVector position, PVector direction) {
    this.position = position.copy();
    this.direction = direction.copy();
    this.speed = this.direction.copy().setMag(baseSpeed);
    this.timeout = 1500;
    this.hitbox = new HitBox(2*earthRadius, this.position);
    exploded = false;
    explosionDuration = 50;
    trackedPlayer = null;
  }
  
  public void move(){
    if (trackedPlayer != null && !exploded) speed = PVector.sub(trackedPlayer.position, this.position).setMag(baseSpeed);
    this.position.add(this.speed);
    this.timeout--;
  } 
  
  public void collide() {
    speed = new PVector(0, 0, 0);
    exploded = true;
    timeout = explosionDuration;
  }
  
  public void trackPlayers(ArrayList<Player> players) {
    if (this.exploded) return;
    float shortestDistance2Player = MAX_FLOAT;
    Player closestPlayer = null; 
    float cone_height = 500*earthRadius;
    float base_radius = 50*earthRadius;
    for (Player player : players) {
      float cone_dist = PVector.dot(PVector.sub(player.position, this.position), this.speed.copy().setMag(cone_height));
      if (cone_dist > cone_height || cone_dist < 0) continue;
      float cone_radius = (cone_dist / cone_height) * base_radius;
      float orth_distance = (PVector.sub(PVector.sub(player.position, this.position),  PVector.mult(this.speed, cone_dist))).mag();

      if (orth_distance < cone_radius && cone_dist < shortestDistance2Player) {
        shortestDistance2Player = cone_dist;
        closestPlayer = player;
      }
    }
    if (closestPlayer != null) {
      trackedPlayer = closestPlayer;
    }
  }

  public ArrayList<Integer> checkCollisions(List<Collisionable> bodies) {
    
    ArrayList<Integer> collidedBodiesIndexes = new ArrayList();
    
    if (exploded) return collidedBodiesIndexes;
    
    this.hitbox.position = position;
    
    for (Collisionable body : bodies) {
      if (this.hitbox.isCollidingWith(body)) collidedBodiesIndexes.add(bodies.indexOf(body));
    }
    
    if (collidedBodiesIndexes.size() > 0) collide(); 
    
    return collidedBodiesIndexes;
  }
  
  public CollisionMesh getCollisionMesh() {
    return hitbox;
  }
}


/*-------------------------------- 
5. BLASTER
--------------------------------*/
class Blaster {
  
  Bullet[] bullets;
  Stack<Integer> freeBulletSpots;
  int maxBullets;
  
  int cooldown = 0;
  
  public Blaster(int maxBullets) {
    this.maxBullets = maxBullets;
    bullets = new Bullet[maxBullets];
    freeBulletSpots = new Stack();
    for (int i = 0; i < maxBullets; i++) {
      freeBulletSpots.push(i);
    }
  }
  
  public void shoot(PVector position, PVector direction) {
    if (freeBulletSpots.size() > 0 && cooldown <= 0) {
      bullets[freeBulletSpots.pop()] = new Bullet(position, direction);
      cooldown = 30;
    }
  }
  
  public void update() {    
    cooldown = cooldown > 0 ? cooldown-1 : 0;
    for (int i = 0; i < bullets.length; i++) {
      if (bullets[i] == null) continue;
      bullets[i].move();
      if (bullets[i].timeout <= 0) {
        bullets[i] = null;
        freeBulletSpots.push(i);
      }
    }
  }
  
  public void trackPlayers(ArrayList<Player> players) {
    for (Bullet bullet : bullets) {
      if (bullet == null) continue;
      bullet.trackPlayers(players);
    }
  }
  
  public HashMap<Integer,Integer> checkCollisions(List<Collisionable> bodies) {
    
    HashMap<Integer, Integer> collidedBodiesCollisions = new HashMap();
    
    for (Bullet bullet : bullets) {   
      
      if (bullet == null) continue;
      
      ArrayList<Integer> collidedBodiesIndexes = bullet.checkCollisions(bodies);
      
      for (Integer collidedBodyIndex : collidedBodiesIndexes) {
        Integer bodyCollisions = collidedBodiesCollisions.get(collidedBodyIndex);
        if (bodyCollisions == null) collidedBodiesCollisions.put(collidedBodyIndex, 1);
        else collidedBodiesCollisions.put(collidedBodyIndex, bodyCollisions + 1);
      }
      
    }
    
    return collidedBodiesCollisions;
  }
  
}


/*-------------------------------- 
6. BULLET MODEL
--------------------------------*/
class BulletModel {
  
  PGraphics canvas;
  
  PShape bulletMesh;
  
  boolean isTracking;
  Bullet trackedBullet;
  
  int explosionAnimationFrame;
  
  public BulletModel(PGraphics canvas) {
    this.canvas = canvas;
    bulletMesh = createShape(BOX, 2*earthRadius);
    isTracking = false;
  }
  
  public void trackBullet(Bullet bullet) {
    trackedBullet = bullet;
    isTracking = true;
  }
  
  public void reset() {
    explosionAnimationFrame = 0;
    trackedBullet = null;
    isTracking = false;
  }
      
  public void display() {
    if (trackedBullet.timeout <= 0) reset();
    if (!isTracking) return;
    canvas.pushMatrix();
      canvas.translate(width/2.0 + trackedBullet.position.x, height/2.0 + trackedBullet.position.y, trackedBullet.position.z);
      canvas.pushStyle();
        bulletMesh.setFill(color(0, 240, 255));
        bulletMesh.setStroke(true);
        bulletMesh.setStroke(color(0, 0, 0));
        if (trackedBullet.exploded) displayExplodingAnimation();
        else canvas.shape(bulletMesh);
      canvas.popStyle();
    canvas.popMatrix();
  }
  
  public void displayExplodingAnimation() {
    bulletMesh.setFill(color(255, 0, 0));
    canvas.shape(bulletMesh);
  }

}


/*-------------------------------- 
7. BLASTER MODEL
--------------------------------*/
class BlasterModel {
  Blaster blaster;
  
  PGraphics canvas;
  BulletModel[] bulletModels;
   
  BlasterModel(PGraphics canvas, Blaster blaster) {
    this.canvas = canvas;
    this.blaster = blaster;
    bulletModels = new BulletModel[blaster.maxBullets];
    for (int i = 0; i < blaster.maxBullets; i++) {
      bulletModels[i] = new BulletModel(canvas);
    }
  }
  
  public void display() {
    canvas.noLights();
    for (int i = 0; i < blaster.maxBullets; i++) {   
      if (!bulletModels[i].isTracking && blaster.bullets[i] != null) bulletModels[i].trackBullet(blaster.bullets[i]);
      if (bulletModels[i].isTracking) bulletModels[i].display();
    }
    canvas.pointLight(255, 255, 255, width/2.0, height/2.0, 0);
  }
}


/*-------------------------------- 
8. TAIL
--------------------------------*/
class Tail {
  
  private class TailParticle {
    
    PGraphics canvas;
    PShader toonShader;
    
    float radius;
    float sizeScale;
    PVector position;
    PShape particleMesh;
    
    float opacity;
    int opacityFrames;
      
    public TailParticle(PGraphics canvas, float radius, float sizeScale, PVector initialPosition, float opacity) {
      this.canvas = canvas;
      toonShader = loadShader("shaders/toon_frag.glsl", "shaders/toon_vert.glsl");
      this.radius = radius;
      this.sizeScale = sizeScale;
      this.position = initialPosition;
      particleMesh = createShape(SPHERE, radius);
      opacityFrames = 0;
      this.opacity = opacity;
    }
    
    public void update(PVector newPosition, float radius) {
      position = newPosition;
      if (radius != this.radius) {
        this.radius = radius;
        particleMesh = createShape(SPHERE, radius);
      }
    }
    
    public void display() {
      canvas.pushMatrix();
        canvas.translate(width/2.0 + position.x, height/2.0 + position.y, position.z);
        canvas.scale(sizeScale);
        if (opacity < 1.0 && opacityFrames == floor(opacity*15) || opacity == 1.0) {
          //particleMesh.setFill(color(255, opacity*255));
          toonShader.set("opacity", opacity);
          opacityFrames = 0;
        } else if (opacity < 1.0) {
          //particleMesh.setFill(color(255, 0));
          toonShader.set("opacity", 0.0);
          opacityFrames++;
        }
        //canvas.shape(particleMesh);
        canvas.pushStyle();
          canvas.shader(toonShader);
          canvas.sphere(radius);
          canvas.resetShader();
        canvas.popStyle();
      canvas.popMatrix(); 
    }
  }
  
  PGraphics canvas;
  
  TailParticle[] particles;
  final float baseRadius = 20;
  final float baseScale = 0.003;
  float maxSpeed; 
  
  int countFrameTail = 0;
  
  public Tail(PGraphics canvas, PVector initialPosition, float maxSpeed) {
    this.canvas = canvas;
    
    this.maxSpeed = maxSpeed;
    particles = new TailParticle[4];
    for(int i = 0; i < particles.length; i++){
      particles[i] = new TailParticle(canvas, baseRadius / (i+1), baseScale, initialPosition.copy(), 1.0 - 0.1*i);
    }
  }
  
  void updateHead(PVector playerPosition, PVector currentSpeed){
    PVector newHeadPosition = PVector.sub(playerPosition, currentSpeed.copy().setMag(6*baseScale*baseRadius));
    float newRadius = max( (60*currentSpeed.mag()*DISTANCE_SCALE) / maxSpeed * baseRadius, 0.4*baseRadius ) ;
    particles[0].update( newHeadPosition, newRadius); 
    for(int i = 1; i < particles.length; i++) {
      particles[i].update(
                          PVector.sub(particles[i-1].position, currentSpeed.copy().setMag(baseScale * (particles[i-1].radius + 2*newRadius))), 
                          max(newRadius*pow(0.7, i), 0.1*baseRadius));
    } 
    
  }
  
  void display() {
    for(int i = 0; i < particles.length; i++){
      particles[i].display();
    }
  }
  
}
