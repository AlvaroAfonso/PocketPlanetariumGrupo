import java.util.Map;
import oscP5.*;

// used sub classes
public class Keypoint{
  PVector position;
  float score;
  public Keypoint(){
    this.position = new PVector(0,0);
    this.score = 0;
  }
}
public class Pose{
  HashMap<String,Keypoint> keypoints;
  float score;
  public Pose(){
    this.keypoints = new HashMap<String,Keypoint>();
    this.score = 0;
  }
}








public class oscReceiver{
  private OscP5 oscP5;
  private OscProperties myProperties;
  oscReceiver(){
    this.myProperties = new OscProperties();
    this.myProperties.setDatagramSize(10000); 
    this.myProperties.setListeningPort(9527);
    this.oscP5 = new OscP5(this, myProperties);
  }
}
