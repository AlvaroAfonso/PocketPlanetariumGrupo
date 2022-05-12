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
  
  PlayerFocus playerFocus;
  float sensitivity = 1.75; // Radians
  int sensitivityOffset = 150;
}

class PlayerFocus {
   float x;
   float y;   
   public PlayerFocus(float x, float y) {
     this.x = x;
     this.y = y;
   }
}

public class PoseDetectionService {
  
  ArrayList<PoseDetectionControl> observers;
  
  public void register(PoseDetectionControl control) {
    observers.add(control);
    
    // IDENTIFICACIÓN DEL CONTROL PARA DETERMINAR QUÉ POSE ENVIAR
    
  }

}

public class PoseDetectionControl extends ControlScheme {
  
  public PoseDetectionControl(PoseDetectionService serv) {
    serv.register(this); // SUSCRIPCIÓN A SERVICIO PARA RECIBIR POSES DETECTADAS
  }
  
  public void update() {
    
    // PROCESAR POSE Y ACTIVAR FLAGS
    
  }
  
}


public class MouseKeyboardControl extends ControlScheme {
  private final int W = 119;
  private final int A = 97;
  private final int R = 114;
  private final int S = 115;
  private final int D = 100;
  private final int X = 120;
  private final int SPACE = 32;
  
  public MouseKeyboardControl(PApplet parent) {
    playerFocus = new PlayerFocus(mouseX, mouseY);
    parent.registerMethod("keyEvent", this); 
    parent.registerMethod("mouseEvent", this); 
  }
  
  public void keyEvent(KeyEvent event) {
    keyCode = event.getKeyCode();
    switch (event.getAction()) {
    case KeyEvent.PRESS:     
      this.keyPressed(event);      
      break;
    case KeyEvent.RELEASE:      
      this.keyReleased(event);
      break;
    }
  }
  
  public void mouseEvent(MouseEvent event) {
    switch(event.getAction()) {
      case MouseEvent.MOVE:
        this.mouseMoved(event);
        break;
    }
  }
  
  public void keyPressed(KeyEvent event) {
    /*
    if (event.getKey() == ENTER) {
      mode = mode==GENERAL_VIEW? EXPLORE : GENERAL_VIEW;
      cameraControl.switchCameraReference();  
      soundsManager.switchBackgroundMusic();
    }
    */
    // ---------------- HUD CONTROLS ----------------
    if (event.getKey() == TAB) {
      showHUD = !showHUD;
    }
    // ---------------- TIME CONTROL ----------------
    if (event.getKey() == CODED) {
      if (keyCode == UP) {
        speedUp = true;
      }
      
      if (keyCode == DOWN) {
        slowDown = true;
      }
    }
    // ---------------- SPACESHIP CONTROLS ----------------  
    if (event.getKey() == W) {
      moveForward = true;
    }
    if (event.getKey() == A) {
      moveLeft = true;
    }  
    if (event.getKey() == S) {
      moveBackward = true;
    }
    if (event.getKey() == D) {
      moveRight = true;
    }
    if (event.getKey() == SPACE) {
      moveUp = true;
    } 
    if (event.getKey() == X) {
      moveDown = true;
    }
    if (event.getKey() == R) {
      moveStop = true;
    }
  }
  
  public void keyReleased(KeyEvent event) {
    if (event.getKey() == CODED) {
      if (keyCode == UP) {
        speedUp = false;
      }
      
      if (keyCode == DOWN) {
        slowDown = false;
      }
    } 
    if (event.getKey() == W) {
      moveForward = false;
    }
    if (event.getKey() == A) {
      moveLeft = false;
    }
    if (event.getKey() == S) {
      moveBackward = false;
    }
    if (event.getKey() == D) {
      moveRight = false;
    }
    if (event.getKey() == SPACE) {
      moveUp = false;
    } 
    if (event.getKey() == X) {
      moveDown = false;
    }
    if (event.getKey() == R) {
      moveStop = false;
    }
  }
  
  public void mouseMoved(MouseEvent event) {
    playerFocus.x = event.getX();
    playerFocus.y = event.getY();
    
    //println("[" + playerFocus.x + ", " + playerFocus.y + "]");
  }
}
