import oscP5.*;

/*
*  -Index-
*    1. GENERAL CONTROL
*    2. KEYBOARD MAPPINGS
*    3. KEYBOARD CONTROL 
*    4. GENERAL KEYBOARD MAP
*    5. POSE CONTROL
*    6. POSE DETECTION SERVICE
*    7. COMMAND DELAYER
*/



/*-------------------------------- 
1. GENERAL CONTROL
--------------------------------*/
enum ControllerID {
  MAIN_MOUSE_KEYBOARD("Mouse & Keyboard [WASD]"),
  ALT_MOUSE_KEYBOARD("Mouse & Keyboard [IJKL]"),
  MAIN_KEYBOARD("Keyboard [WASD]"),
  ALT_KEYBOARD("Keyboard [IJKL]"),
  POSE_DETECTION("Pose Detection");
  
  private String name;
  
  private ControllerID(String name) {
    this.name = name;
  }
}

class ControllerRepository {
  
  private HashMap<ControllerID, Control> keyboardControllers;
  private ArrayList<Control> poseControllers;
  
  private final boolean AVAILABLE = true;
  private HashMap<ControllerID, Boolean> controllerAvailabilityMap;
  
  public ControllerRepository() {
    keyboardControllers = new HashMap();
    keyboardControllers.put(ControllerID.MAIN_MOUSE_KEYBOARD, new MouseKeyboardControl(new MainKeyboardMap(), true));
    keyboardControllers.put(ControllerID.ALT_MOUSE_KEYBOARD, new MouseKeyboardControl(new AltKeyboardMap(), true));
    keyboardControllers.put(ControllerID.MAIN_KEYBOARD, new MouseKeyboardControl(new MainKeyboardMap(), false));
    keyboardControllers.put(ControllerID.ALT_KEYBOARD, new MouseKeyboardControl(new AltKeyboardMap(), false));
    
    poseControllers = new ArrayList();
    
    controllerAvailabilityMap = new HashMap();
    controllerAvailabilityMap.put(ControllerID.MAIN_MOUSE_KEYBOARD, AVAILABLE);
    controllerAvailabilityMap.put(ControllerID.ALT_MOUSE_KEYBOARD, AVAILABLE);
    controllerAvailabilityMap.put(ControllerID.MAIN_KEYBOARD, AVAILABLE);
    controllerAvailabilityMap.put(ControllerID.ALT_KEYBOARD, AVAILABLE);
    controllerAvailabilityMap.put(ControllerID.POSE_DETECTION, AVAILABLE);
  }
  
  public ArrayList<ControllerID> getAvailableControllers() {
    ArrayList<ControllerID> availableControllers = new ArrayList(); 
    for (ControllerID controller : controllerAvailabilityMap.keySet()) {
      if (controllerAvailabilityMap.get(controller) != AVAILABLE) continue;
      switch (controller) {
          case MAIN_MOUSE_KEYBOARD:
            if (controllerAvailabilityMap.get(ControllerID.ALT_MOUSE_KEYBOARD) == AVAILABLE && controllerAvailabilityMap.get(ControllerID.MAIN_KEYBOARD) == AVAILABLE) {
                  availableControllers.add(ControllerID.MAIN_MOUSE_KEYBOARD);
            } 
            break;
          case ALT_MOUSE_KEYBOARD:
            if (controllerAvailabilityMap.get(ControllerID.MAIN_MOUSE_KEYBOARD) == AVAILABLE && controllerAvailabilityMap.get(ControllerID.ALT_KEYBOARD) == AVAILABLE) {
                  availableControllers.add(ControllerID.ALT_MOUSE_KEYBOARD);
            }
            break;
          case MAIN_KEYBOARD:
            if (controllerAvailabilityMap.get(ControllerID.MAIN_MOUSE_KEYBOARD) == AVAILABLE) {
                  availableControllers.add(ControllerID.MAIN_KEYBOARD);
            }
            break;
          case ALT_KEYBOARD:
            if (controllerAvailabilityMap.get(ControllerID.ALT_MOUSE_KEYBOARD) == AVAILABLE) {
                  availableControllers.add(ControllerID.MAIN_KEYBOARD);
            }
            break;
          case POSE_DETECTION:
            availableControllers.add(ControllerID.POSE_DETECTION);
            break;
        }
    }
    return availableControllers;
  } 
  
  public Control fetchController(int requesterID, ControllerID targetController) {
    Control controller = null;
    println("Requested " + targetController.name + " " + (controllerAvailabilityMap.get(targetController) == AVAILABLE));
    if (controllerAvailabilityMap.get(targetController) != AVAILABLE) return controller;
    
    if (targetController == ControllerID.POSE_DETECTION) {
      controller = new PoseControl();
      poseDetectionService.register((PoseControl) controller, requesterID);
      poseControllers.add(controller);
      return controller;
    }
    
    controllerAvailabilityMap.put(targetController, !AVAILABLE);
    
    return keyboardControllers.get(targetController);
  }
  
  public Control fetchController(int requesterID, String targetControllerName) {
    Control controller = null;
    
    for (ControllerID controllerID : controllerAvailabilityMap.keySet()) {
      if (controllerAvailabilityMap.get(controllerID) == AVAILABLE && controllerID.name.equals(targetControllerName)) {
        
        if (controllerID == ControllerID.POSE_DETECTION) {
          controller = new PoseControl();
          poseDetectionService.register((PoseControl) controller, requesterID);
          poseControllers.add(controller);
          return controller;
        }
        
        controllerAvailabilityMap.put(controllerID, !AVAILABLE);
        
        return keyboardControllers.get(controllerID);
      } 
      if (controllerID.name.equals(targetControllerName)) println("Requested " + targetControllerName + " " + (controllerAvailabilityMap.get(controllerID) == AVAILABLE));
    }   
    return controller;
  }
  
  public void freeController(Control targetController) {
    println("Trying to free " + targetController);
    for (Control controller : poseControllers) {
      if (controller == targetController) {
        println("Freeing " + ControllerID.POSE_DETECTION.name);
        poseDetectionService.unregister((PoseControl) targetController);
        poseControllers.remove(targetController);
        return;
      }
    }
    for (ControllerID controllerID : keyboardControllers.keySet()) {
      if (keyboardControllers.get(controllerID) == targetController) {
        println("Freeing " + controllerID.name);
        controllerAvailabilityMap.put(controllerID, AVAILABLE);
      }
    }
  }
  
  public String getControllerName(Control controller) {
    if (controller.getClass() == PoseControl.class) return ControllerID.POSE_DETECTION.name;
    for (ControllerID controllerID : keyboardControllers.keySet()) {
      if (keyboardControllers.get(controllerID) == controller) return controllerID.name;
    }
    return "";
  }
  
  public ArrayList<String> getAvailableControllerNames(String selectedController) {
    ArrayList<String> availableControllerNames = new ArrayList(); 
    for (ControllerID controller : controllerAvailabilityMap.keySet()) {
      
      if (controller.name.equals(selectedController)) {        
        switch (controller) {
          case MAIN_MOUSE_KEYBOARD:
            availableControllerNames.add(ControllerID.MAIN_KEYBOARD.name);
            if (controllerAvailabilityMap.get(ControllerID.ALT_MOUSE_KEYBOARD) == AVAILABLE && controllerAvailabilityMap.get(ControllerID.ALT_KEYBOARD) == AVAILABLE) {
                  availableControllerNames.add(ControllerID.ALT_MOUSE_KEYBOARD.name);
                  availableControllerNames.add(ControllerID.ALT_KEYBOARD.name);
            } 
            break;
          case ALT_MOUSE_KEYBOARD:
            availableControllerNames.add(ControllerID.ALT_KEYBOARD.name);
            if (controllerAvailabilityMap.get(ControllerID.MAIN_MOUSE_KEYBOARD) == AVAILABLE && controllerAvailabilityMap.get(ControllerID.MAIN_KEYBOARD) == AVAILABLE) {
                  availableControllerNames.add(ControllerID.MAIN_MOUSE_KEYBOARD.name);
                  availableControllerNames.add(ControllerID.MAIN_KEYBOARD.name);
            }
            break;
          case MAIN_KEYBOARD:
            if (controllerAvailabilityMap.get(ControllerID.MAIN_MOUSE_KEYBOARD) == AVAILABLE && controllerAvailabilityMap.get(ControllerID.ALT_MOUSE_KEYBOARD) == AVAILABLE) {
              availableControllerNames.add(ControllerID.MAIN_MOUSE_KEYBOARD.name);
            }
            if (controllerAvailabilityMap.get(ControllerID.ALT_MOUSE_KEYBOARD) == AVAILABLE && controllerAvailabilityMap.get(ControllerID.ALT_KEYBOARD) == AVAILABLE) {
                  availableControllerNames.add(ControllerID.ALT_MOUSE_KEYBOARD.name);
                  availableControllerNames.add(ControllerID.ALT_KEYBOARD.name);
            }
            break;
          case ALT_KEYBOARD:
            if (controllerAvailabilityMap.get(ControllerID.ALT_MOUSE_KEYBOARD) == AVAILABLE && controllerAvailabilityMap.get(ControllerID.MAIN_MOUSE_KEYBOARD) == AVAILABLE) {
              availableControllerNames.add(ControllerID.ALT_MOUSE_KEYBOARD.name);
            }
            if (controllerAvailabilityMap.get(ControllerID.MAIN_MOUSE_KEYBOARD) == AVAILABLE && controllerAvailabilityMap.get(ControllerID.MAIN_KEYBOARD) == AVAILABLE) {
              availableControllerNames.add(ControllerID.MAIN_MOUSE_KEYBOARD.name);
              availableControllerNames.add(ControllerID.MAIN_KEYBOARD.name);
            }
            break;
          case POSE_DETECTION:
            if (controllerAvailabilityMap.get(ControllerID.MAIN_MOUSE_KEYBOARD) == AVAILABLE
                && controllerAvailabilityMap.get(ControllerID.ALT_MOUSE_KEYBOARD) == AVAILABLE
                && controllerAvailabilityMap.get(ControllerID.MAIN_KEYBOARD) == AVAILABLE) availableControllerNames.add(ControllerID.MAIN_MOUSE_KEYBOARD.name);
                
            if (controllerAvailabilityMap.get(ControllerID.ALT_MOUSE_KEYBOARD) == AVAILABLE
                && controllerAvailabilityMap.get(ControllerID.MAIN_MOUSE_KEYBOARD) == AVAILABLE
                && controllerAvailabilityMap.get(ControllerID.ALT_KEYBOARD) == AVAILABLE) availableControllerNames.add(ControllerID.ALT_MOUSE_KEYBOARD.name);
                
            if (controllerAvailabilityMap.get(ControllerID.MAIN_KEYBOARD) == AVAILABLE
                && controllerAvailabilityMap.get(ControllerID.MAIN_MOUSE_KEYBOARD) == AVAILABLE) availableControllerNames.add(ControllerID.MAIN_KEYBOARD.name);
                
            if (controllerAvailabilityMap.get(ControllerID.ALT_KEYBOARD) == AVAILABLE
                && controllerAvailabilityMap.get(ControllerID.ALT_MOUSE_KEYBOARD) == AVAILABLE) availableControllerNames.add(ControllerID.ALT_KEYBOARD.name);
            break;
        }
      }
    }
    
    if (!selectedController.equals(ControllerID.POSE_DETECTION.name)) availableControllerNames.add(ControllerID.POSE_DETECTION.name);
    
    Collections.sort(availableControllerNames);
    return availableControllerNames;
  } 

}


/*-------------------------------- 
1. GENERAL CONTROL
--------------------------------*/
abstract class Control {
  
  class PlayerFocus {
    float x;
    float y;    
    public PlayerFocus(float x, float y) {
      this.x = x;
      this.y = y;
    }
  }
  
  private String name;
  
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
  
  boolean activateBlaster = false;

  // system controls
  
  public abstract void dispose();
  
}


interface Command {

}


/*-------------------------------- 
2. KEYBOARD MAPPINGS
--------------------------------*/
class MainKeyboardMap extends KeyboardMap {
  public MainKeyboardMap() {
    super();
    bindings.put(PlayerCommand.MOVE_FORWARD, new Key('w'));
    bindings.put(PlayerCommand.MOVE_BACKWARD, new Key('s'));
    bindings.put(PlayerCommand.MOVE_LEFT, new Key('a'));
    bindings.put(PlayerCommand.MOVE_RIGHT, new Key('d'));
    bindings.put(PlayerCommand.MOVE_UP, new Key('q'));
    bindings.put(PlayerCommand.MOVE_DOWN, new Key('e'));
    bindings.put(PlayerCommand.STOP, new Key('r'));
    bindings.put(PlayerCommand.SHOOT, new Key('c'));
    
    bindings.put(PlayerCommand.CAMERA_UP, new Key('t'));
    bindings.put(PlayerCommand.CAMERA_DOWN, new Key('g'));
    bindings.put(PlayerCommand.CAMERA_LEFT, new Key('f'));
    bindings.put(PlayerCommand.CAMERA_RIGHT, new Key('h'));
  }
}

class AltKeyboardMap extends KeyboardMap {
  public AltKeyboardMap() {
    super();
    bindings.put(PlayerCommand.MOVE_FORWARD, new Key('i'));
    bindings.put(PlayerCommand.MOVE_BACKWARD, new Key('k'));
    bindings.put(PlayerCommand.MOVE_LEFT, new Key('j'));
    bindings.put(PlayerCommand.MOVE_RIGHT, new Key('l'));
    bindings.put(PlayerCommand.MOVE_UP, new Key('u'));
    bindings.put(PlayerCommand.MOVE_DOWN, new Key('o'));
    bindings.put(PlayerCommand.STOP, new Key('p'));
    bindings.put(PlayerCommand.SHOOT, new Key('b'));
    
    bindings.put(PlayerCommand.CAMERA_UP, new Key(CODED, UP));
    bindings.put(PlayerCommand.CAMERA_DOWN, new Key(CODED, DOWN));
    bindings.put(PlayerCommand.CAMERA_LEFT, new Key(CODED, LEFT));
    bindings.put(PlayerCommand.CAMERA_RIGHT, new Key(CODED, RIGHT));
  }
}


/*-------------------------------- 
3. KEYBOARD CONTROL
--------------------------------*/
public class MouseKeyboardControl extends Control {
  
  KeyboardMap keyMap;
  boolean useMouse;
  
  public MouseKeyboardControl(KeyboardMap keyMap, boolean useMouse) {
    this.keyMap = keyMap;
    this.useMouse = useMouse;
    if (useMouse) {
      playerFocus = new PlayerFocus(mouseX, mouseY);
      cameraSensitivity = 2;
      cameraSensitivityOffset = 150;
      appRoot.registerMethod("mouseEvent", this);
    } else {
      playerFocus = new PlayerFocus(width/2, height/2);
      cameraSensitivity = 20;
      cameraSensitivityOffset = 0;
    }
    appRoot.registerMethod("keyEvent", this);
  }
  
   public void keyEvent(KeyEvent event) {
     PlayerCommand command = keyMap.parseKeyEvent(event);
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
       case SHOOT:
         if (event.getAction() == KeyEvent.PRESS) activateBlaster = true;
         else if (event.getAction() == KeyEvent.RELEASE) activateBlaster = false;
         break;
       case CAMERA_UP:
         if (event.getAction() == KeyEvent.PRESS) playerFocus.y = height/2 - cameraSensitivityOffset - 50;
         else if (event.getAction() == KeyEvent.RELEASE && playerFocus.y < height/2) playerFocus.y = height/2;
         break;
       case CAMERA_DOWN:
         if (event.getAction() == KeyEvent.PRESS) playerFocus.y = height/2 + cameraSensitivityOffset + 50;
         else if (event.getAction() == KeyEvent.RELEASE && playerFocus.y > height/2) playerFocus.y = height/2;
         break;
       case CAMERA_LEFT:
         if (event.getAction() == KeyEvent.PRESS) playerFocus.x = width/2 - cameraSensitivityOffset - 50;
         else if (event.getAction() == KeyEvent.RELEASE && playerFocus.x < width/2) playerFocus.x = width/2;
         break;
       case CAMERA_RIGHT:
         if (event.getAction() == KeyEvent.PRESS) playerFocus.x = width/2 + cameraSensitivityOffset + 50;
         else if (event.getAction() == KeyEvent.RELEASE && playerFocus.x > width/2) playerFocus.x = width/2;
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
  
  @Override
   public void dispose() {
     appRoot.unregisterMethod("keyEvent", this);
     if (useMouse) appRoot.unregisterMethod("mouseEvent", this);
   }  
}


/*-------------------------------- 
4. GENERAL KEYBOARD MAP
--------------------------------*/
abstract class KeyboardMap {
  HashMap<PlayerCommand, Key> bindings;
  
  public KeyboardMap() {
    bindings = new HashMap();
  }
  
  public PlayerCommand parseKeyEvent(KeyEvent event) {
    Key eventKey = new Key(event.getKey(), event.getKeyCode());
    for (PlayerCommand command : bindings.keySet()) {
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
    return this.isSpecial == otherKey.isSpecial && value == otherKey.value;
  }
}


/*-------------------------------- 
5. POSE CONTROL
--------------------------------*/
public class PoseControl extends Control {

  private CommandDelayer latencyGen;
  
  public PoseControl() {
    PlayerCommand[] commands = {PlayerCommand.MOVE_FORWARD, PlayerCommand.MOVE_BACKWARD, PlayerCommand.MOVE_LEFT, PlayerCommand.MOVE_RIGHT};
    latencyGen = new CommandDelayer(commands, 4);
    cameraSensitivity = 3.5;
    cameraSensitivityOffset = 80;
    playerFocus = new PlayerFocus(width/2,height/2);
  }
  
  public void update(Pose newPose) {
    parseMovementControls(newPose,"leftWrist","leftShoulder");
    parseCameraControls(newPose,"rightWrist","rightShoulder");
  }
  
  private void parseMovementControls(Pose pose, String controlPart, String anchorPart){
    PVector controlCoords = pose.getPartCoords(controlPart);
    PVector anchorCoords = pose.getPartCoords(anchorPart);
    
    if (controlCoords == null || anchorCoords == null) return;
        
    if(controlCoords.y - anchorCoords.y < -cameraSensitivityOffset) moveForward = latencyGen.delayedFlagValue(PlayerCommand.MOVE_FORWARD, true);
    else  moveForward = latencyGen.delayedFlagValue(PlayerCommand.MOVE_FORWARD, false);
    
    if (controlCoords.y - anchorCoords.y > cameraSensitivityOffset) moveBackward = latencyGen.delayedFlagValue(PlayerCommand.MOVE_BACKWARD, true);
    else moveBackward = latencyGen.delayedFlagValue(PlayerCommand.MOVE_BACKWARD, false);
    
    if (controlCoords.x - anchorCoords.x < -cameraSensitivityOffset) moveLeft = latencyGen.delayedFlagValue(PlayerCommand.MOVE_LEFT, true);
    else moveLeft = latencyGen.delayedFlagValue(PlayerCommand.MOVE_LEFT, false);
    
    if (controlCoords.x - anchorCoords.x > cameraSensitivityOffset) moveRight = latencyGen.delayedFlagValue(PlayerCommand.MOVE_RIGHT, true);
    else moveRight = latencyGen.delayedFlagValue(PlayerCommand.MOVE_RIGHT, false);
    
    moveStop = (!moveForward && !moveBackward && !moveLeft && !moveRight);
  }
  
  
  private void parseCameraControls(Pose pose, String controlPart, String anchorPart){  
    PVector controlCoords = pose.getPartCoords(controlPart);
    PVector anchorCoords = pose.getPartCoords(anchorPart);
    
    if (controlCoords == null || anchorCoords == null) return;
    
    if(controlCoords.y - anchorCoords.y < -1.5*cameraSensitivityOffset)  playerFocus.y = height/2 - cameraSensitivityOffset - 50;
    else if (controlCoords.y - anchorCoords.y > 1.5*cameraSensitivityOffset)  playerFocus.y = height/2 + cameraSensitivityOffset + 50;
    else playerFocus.y = height/2;
    
    if (controlCoords.x - anchorCoords.x < -cameraSensitivityOffset)  playerFocus.x = width/2 - cameraSensitivityOffset - 50;
    else if (controlCoords.x - anchorCoords.x > cameraSensitivityOffset)  playerFocus.x = width/2 + cameraSensitivityOffset + 50;
    else  playerFocus.x = width/2;
  }
  
  @Override
   public void dispose() {
     poseDetectionService.unregister(this);
   } 
  
}


/*-------------------------------- 
6. POSE DETECTION SERVICE
--------------------------------*/
public class PoseDetectionService {
  private OscP5 oscP5;
  private OscProperties properties;
  
  PoseControl[] subscribers ;
  int activeSubs;
  
  public PoseDetectionService() {
    properties = new OscProperties();
    properties.setDatagramSize(10000); 
    properties.setListeningPort(9527);
    oscP5 = new OscP5(this, properties);
    subscribers = new PoseControl[4];
    activeSubs = 0;
    oscP5.plug(this,"parseData","/poses/xml");
  }
  
  public void register(PoseControl subscriber, int subscriberID) {
    subscribers[subscriberID] = subscriber;
    activeSubs++;
  }
  
  public void unregister(PoseControl subscriber) {
    for (int i  = 0; i < subscribers.length; i++ ) {
      if (subscribers[i] == subscriber) {
        subscribers[i] = null;
        activeSubs--;
      }
    }
  }
  
  public void parseData(String rawPoseData) {
    XML xmlPoseData = parseXML(rawPoseData);
    int detectedPoseNum = xmlPoseData.getInt("nPoses");
    
    if(activeSubs == 0 || detectedPoseNum < activeSubs) return;
    
    XML[] poses = xmlPoseData.getChildren("pose");
    for (int i = 0; i < subscribers.length; i++) {
      if (subscribers[i] != null) subscribers[i].update(new Pose(poses[poses.length - i - 1]));
    }
  }
  
}

public class Pose {
  
  HashMap<String,Keypoint> keypoints;
  float score;
  
  public Pose(XML poseData) {
    score = poseData.getFloat("score");
    keypoints = new HashMap();
    for (XML keypointData : poseData.getChildren("keypoint")) {
      keypoints.put(keypointData.getString("part"), new Keypoint(keypointData));
    }
  }
  
  public PVector getPartCoords(String partName) {
    if (!keypoints.containsKey(partName)) return null;
    return keypoints.get(partName).position;
  }
  
}

public class Keypoint {
  
  PVector position;
  float score;
  
  public Keypoint(XML keypointData) {
    position = new PVector(keypointData.getFloat("x"), keypointData.getFloat("y"));
    score = keypointData.getFloat("score");
  }
  
}


/*-------------------------------- 
7. COMMAND DELAYER
--------------------------------*/
public class CommandDelayer {
  
  private int latency;
  private HashMap<PlayerCommand, Integer> latencyCounters;
  private HashMap<PlayerCommand, Boolean> previousFlagValues;
  
  public CommandDelayer(PlayerCommand[] commands, int latency) {
    this.latency = latency;
    latencyCounters = new HashMap();
    previousFlagValues = new HashMap();
    for (PlayerCommand command : commands) {
       latencyCounters.put(command, 0);
       previousFlagValues.put(command, false);
    }
  }
  
  public boolean delayedFlagValue(PlayerCommand command, boolean commandFlagValue) {
    int latencyCounter = latencyCounters.get(command);
    boolean previousFlagValue = previousFlagValues.get(command);
    
    if (commandFlagValue == previousFlagValue) return commandFlagValue;
    
    if (latencyCounter++ == latency) {
      latencyCounters.put(command, 0);
      previousFlagValues.put(command, commandFlagValue);
      return commandFlagValue;
    }
    
    return previousFlagValue;
  }
} 
