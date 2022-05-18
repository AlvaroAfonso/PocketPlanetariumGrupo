import java.util.Map;
import oscP5.*;


public class PoseControl extends ControlScheme {

  private int[] detectionBuffer;
  
  public PoseControl(PoseDetectionService poseDetectionService){
    poseDetectionService.register(this);
    this.detectionBuffer = new int[4];
    for(int i=0; i<4; i++){
      this.detectionBuffer[i]=0; //Move forward, backwards, left, right
    }
    cameraSensitivity = 5;
    cameraSensitivityOffset = 100;
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
    
    
    if(controlCoords.y - anchorCoords.y < -cameraSensitivityOffset){
      if(this.detectionBuffer[0]>4){
        moveForward = true;
      }else{
        this.detectionBuffer[0]++;
      }
    } else{
      if(this.detectionBuffer[0]>0){
        this.detectionBuffer[0]--;
      }else{
        moveForward=false;
      }
    }
    
    if(controlCoords.y - anchorCoords.y > cameraSensitivityOffset){
      if(this.detectionBuffer[1]>4){
        moveBackward = true;
      }else{
        this.detectionBuffer[1]++;
      }
    } else{
      if(this.detectionBuffer[1]>0){
        this.detectionBuffer[1]--;
      }else{
        moveBackward=false;
      }
    }
    
    if(controlCoords.x - anchorCoords.x < -cameraSensitivityOffset){
      if(this.detectionBuffer[2]>4){
        moveLeft = true;
      }else{
        this.detectionBuffer[2]++;
      }
    } else{
      if(this.detectionBuffer[2]>0){
        this.detectionBuffer[2]--;
      }else{
        moveLeft=false;
      }
    }
    
    if(controlCoords.x - anchorCoords.x > cameraSensitivityOffset){
      if(this.detectionBuffer[3]>4){
        moveRight = true;
      }else{
        this.detectionBuffer[3]++;
      }
    } else{
      if(this.detectionBuffer[3]>0){
        this.detectionBuffer[3]--;
      }else{
        moveRight=false;
      }
    }
  }
  
  
  private void parseCameraControls(Pose pose, String controlPart, String anchorPart){  
    PVector controlCoords = pose.getPartCoords(controlPart);
    PVector anchorCoords = pose.getPartCoords(anchorPart);
    
    if (controlCoords == null || anchorCoords == null) return;
    
    if(controlCoords.y - anchorCoords.y < -1.5*cameraSensitivityOffset) {
      playerFocus.y = height/2 - cameraSensitivityOffset - 50;
    } else if(controlCoords.y - anchorCoords.y > 1.5*cameraSensitivityOffset) {
      playerFocus.y = height/2 + cameraSensitivityOffset + 50;
    } else{
      playerFocus.y = height/2;
    }
    
    if(controlCoords.x - anchorCoords.x < -cameraSensitivityOffset) {
      playerFocus.x = width/2 - cameraSensitivityOffset - 50;
    } else if(controlCoords.x - anchorCoords.x > cameraSensitivityOffset) {
      playerFocus.x = width/2 + cameraSensitivityOffset + 50;
    } else {
      playerFocus.x = width/2;
    }
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
    oscP5.plug(this,"parseData","/poses/xml");
    subscribers = new PoseControl[0];
  }
  
  public void register(PoseControl subscriber) {
    PoseControl[] updatedSubscribers = new PoseControl[subscribers.length + 1];
    System.arraycopy(subscribers, 0, updatedSubscribers, 0, subscribers.length);
    updatedSubscribers[subscribers.length] = subscriber;
    subscribers = updatedSubscribers;
  }
  
  public void parseData(String rawPoseData){
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
