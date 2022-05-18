
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

class MainKeyboardMap extends KeyboardMap {
  public MainKeyboardMap() {
    super();
    bindings.put(Command.MOVE_FORWARD, new Key('w'));
    bindings.put(Command.MOVE_BACKWARD, new Key('s'));
    bindings.put(Command.MOVE_LEFT, new Key('a'));
    bindings.put(Command.MOVE_RIGHT, new Key('d'));
    bindings.put(Command.MOVE_UP, new Key('q'));
    bindings.put(Command.MOVE_DOWN, new Key('e'));
    bindings.put(Command.STOP, new Key('r'));
    
    bindings.put(Command.CAMERA_UP, new Key('t'));
    bindings.put(Command.CAMERA_DOWN, new Key('g'));
    bindings.put(Command.CAMERA_LEFT, new Key('f'));
    bindings.put(Command.CAMERA_RIGHT, new Key('h'));
  }
}

class AltKeyboardMap extends KeyboardMap {
  public AltKeyboardMap() {
    super();
    bindings.put(Command.MOVE_FORWARD, new Key('i'));
    bindings.put(Command.MOVE_BACKWARD, new Key('k'));
    bindings.put(Command.MOVE_LEFT, new Key('j'));
    bindings.put(Command.MOVE_RIGHT, new Key('l'));
    bindings.put(Command.MOVE_UP, new Key('u'));
    bindings.put(Command.MOVE_DOWN, new Key('o'));
    bindings.put(Command.STOP, new Key('p'));
    
    bindings.put(Command.CAMERA_UP, new Key(CODED, UP));
    bindings.put(Command.CAMERA_DOWN, new Key(CODED, DOWN));
    bindings.put(Command.CAMERA_LEFT, new Key(CODED, LEFT));
    bindings.put(Command.CAMERA_RIGHT, new Key(CODED, RIGHT));
  }
}

public class MouseKeyboardControl extends ControlScheme {
  
  KeyboardMap keyMap;
  
  public MouseKeyboardControl(PApplet parent, KeyboardMap keyMap, boolean useMouse) {
    this.keyMap = keyMap;
    parent.registerMethod("keyEvent", this);
    if (useMouse) {
      parent.registerMethod("mouseEvent", this);
      playerFocus = new PlayerFocus(mouseX, mouseY);
      cameraSensitivity = 1.75;
      cameraSensitivityOffset = 150;
    } else {
      playerFocus = new PlayerFocus(width/2, height/2);
      cameraSensitivity = 20;
      cameraSensitivityOffset = 0;
    }
  }
  
   public void keyEvent(KeyEvent event) {
     Command command = keyMap.parseKeyEvent(event);
     println(event.getAction() + " " + event.getKey());
     println("Result " + command);
     if (command == null) return;
     switch (command) {
       case MOVE_FORWARD:
         if (event.getAction() == KeyEvent.PRESS) moveForward = true;
         else if (event.getAction() == KeyEvent.RELEASE) moveForward = false;
         break;
       case MOVE_BACKWARD:
         if (event.getAction() == KeyEvent.PRESS) moveBackward = true;
         else if (event.getAction() == KeyEvent.RELEASE) moveBackward = false;
         break;
       case MOVE_LEFT:
         if (event.getAction() == KeyEvent.PRESS) moveLeft = true;
         else if (event.getAction() == KeyEvent.RELEASE) moveLeft = false;
         break;
       case MOVE_RIGHT:
         if (event.getAction() == KeyEvent.PRESS) moveRight = true;
         else if (event.getAction() == KeyEvent.RELEASE) moveRight = false;
         break;
       case MOVE_UP:
         if (event.getAction() == KeyEvent.PRESS) moveUp = true;
         else if (event.getAction() == KeyEvent.RELEASE) moveUp = false;
         break;
       case MOVE_DOWN:
         if (event.getAction() == KeyEvent.PRESS) moveDown = true;
         else if (event.getAction() == KeyEvent.RELEASE) moveDown = false;
         break;
       case STOP:
         if (event.getAction() == KeyEvent.PRESS) moveStop = true;
         else if (event.getAction() == KeyEvent.RELEASE) moveStop = false;
         break;
       case CAMERA_UP:
         if (event.getAction() == KeyEvent.PRESS) playerFocus.y = height/2 - cameraSensitivityOffset - 50;
         else if (event.getAction() == KeyEvent.RELEASE) playerFocus.y = height/2;
         break;
       case CAMERA_DOWN:
         if (event.getAction() == KeyEvent.PRESS) playerFocus.y = height/2 + cameraSensitivityOffset + 50;
         else if (event.getAction() == KeyEvent.RELEASE) playerFocus.y = height/2;
         break;
       case CAMERA_LEFT:
         if (event.getAction() == KeyEvent.PRESS) playerFocus.x = width/2 - cameraSensitivityOffset - 50;
         else if (event.getAction() == KeyEvent.RELEASE) playerFocus.x = width/2;
         break;
       case CAMERA_RIGHT:
         if (event.getAction() == KeyEvent.PRESS) playerFocus.x = width/2 + cameraSensitivityOffset + 50;
         else if (event.getAction() == KeyEvent.RELEASE) playerFocus.x = width/2;
         break;
     }
   }
   
   public void mouseEvent(MouseEvent event) {
    switch(event.getAction()) {
      case MouseEvent.MOVE:
        playerFocus.x = event.getX();
        playerFocus.y = event.getY();
        break;
    }
  }
  
}

abstract class KeyboardMap {
  HashMap<Command, Key> bindings;
  
  public KeyboardMap() {
    bindings = new HashMap();
  }
  
  public Command parseKeyEvent(KeyEvent event) {
    Key eventKey = new Key(event.getKey(), event.getKeyCode());
    for (Command command : bindings.keySet()) {
      //println(bindings.get(command).value + " CODED: " + bindings.get(command).isSpecial + " es igual a " + eventKey.value + " CODED: " + eventKey.isSpecial);
      //println(bindings.get(command).equals(eventKey));
      if (bindings.get(command).equals(eventKey)) return command;
    }
    return null;
  }
}

class Key {
  int value;
  boolean isSpecial;
  
  public Key(int value) {
    this.value = value;
    isSpecial = false;
  }
  
  public Key(int value, int code) {
    if (value == CODED) {
      this.isSpecial = true;
      this.value = code;
    } else {
      this.isSpecial = false;
      this.value = value;
    }
  }
  
  public Key(int value, boolean isSpecial) {
    this.value = value;
    this.isSpecial = isSpecial;
  }
  
  @Override
  boolean equals(Object other) {
    if (other == null || this.getClass() != other.getClass()) return false;
    Key otherKey = (Key) other;
    //println("Comparando con: " + otherKey.value + " CODED: " + otherKey.isSpecial);
    //println(this.isSpecial == otherKey.isSpecial);
    //println(value == otherKey.value);
    return this.isSpecial == otherKey.isSpecial && value == otherKey.value;
  }
}
