import java.util.Map;
import oscP5.*;


public class PoseControl extends ControlScheme {

  private CommandLatencyGenerator latencyGen;
  
  public PoseControl(PoseDetectionService poseDetectionService){
    poseDetectionService.register(this);
    Command[] commands = {Command.MOVE_FORWARD, Command.MOVE_BACKWARD, Command.MOVE_LEFT, Command.MOVE_RIGHT};
    latencyGen = new CommandLatencyGenerator(commands, 4);
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
        
    if(controlCoords.y - anchorCoords.y < -cameraSensitivityOffset) moveForward = latencyGen.delayedFlagValue(Command.MOVE_FORWARD, true);
    else  moveForward = latencyGen.delayedFlagValue(Command.MOVE_FORWARD, false);
    
    if (controlCoords.y - anchorCoords.y > cameraSensitivityOffset) moveBackward = latencyGen.delayedFlagValue(Command.MOVE_BACKWARD, true);
    else moveBackward = latencyGen.delayedFlagValue(Command.MOVE_BACKWARD, false);
    
    if (controlCoords.x - anchorCoords.x < -cameraSensitivityOffset) moveLeft = latencyGen.delayedFlagValue(Command.MOVE_LEFT, true);
    else moveLeft = latencyGen.delayedFlagValue(Command.MOVE_LEFT, false);
    
    if (controlCoords.x - anchorCoords.x > cameraSensitivityOffset) moveRight = latencyGen.delayedFlagValue(Command.MOVE_RIGHT, true);
    else moveRight = latencyGen.delayedFlagValue(Command.MOVE_RIGHT, false);
    
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
  
}

public class CommandLatencyGenerator {
  
  private int latency;
  private HashMap<Command, Integer> latencyCounters;
  private HashMap<Command, Boolean> previousFlagValues;
  
  public CommandLatencyGenerator(Command[] commands, int latency) {
    this.latency = latency;
    latencyCounters = new HashMap();
    previousFlagValues = new HashMap();
    for (Command command : commands) {
       latencyCounters.put(command, 0);
       previousFlagValues.put(command, false);
    }
  }
  
  public boolean delayedFlagValue(Command command, boolean commandFlagValue) {
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

public class PoseDetectionService {
  private OscP5 oscP5;
  private OscProperties properties;
  
  PoseControl[] subscribers ;
  
  public PoseDetectionService() {
    properties = new OscProperties();
    properties.setDatagramSize(10000); 
    properties.setListeningPort(9527);
    oscP5 = new OscP5(this, properties);
    subscribers = new PoseControl[0];
    oscP5.plug(this,"parseData","/poses/xml");
  }
  
  public void register(PoseControl subscriber) {
    PoseControl[] updatedSubscribers = new PoseControl[subscribers.length + 1];
    System.arraycopy(subscribers, 0, updatedSubscribers, 0, subscribers.length);
    updatedSubscribers[subscribers.length] = subscriber;
    subscribers = updatedSubscribers;
  }
  
  public void parseData(String rawPoseData) {
    XML xmlPoseData = parseXML(rawPoseData);
    int detectedPoseNum = xmlPoseData.getInt("nPoses");
    
    if(subscribers.length == 0 || detectedPoseNum < subscribers.length) return;
    
    XML[] poses = xmlPoseData.getChildren("pose");
    for (int i = 0; i < subscribers.length; i++) {
      subscribers[i].update(new Pose(poses[i]));
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
