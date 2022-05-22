import processing.sound.*;


class SoundsManager {
  
  private SoundFile ambientMusic;
  private SoundFile spaceshipTheme;
  //private SoundFile spaceshipEngine;
  
  private SinOsc spaceshipEngine;
  private boolean selectFreq = true;
  private float freqHighNave = 500;
  private float freqLowNave = 450;
  
  SoundsManager(PApplet parent) {
    ambientMusic = new SoundFile(parent, "./data/music/mrthenoronha - ambient.wav");
    spaceshipTheme = new SoundFile(parent, "./data/music/legend1060 - spaceship theme.wav");
    //spaceshipEngine = new SoundFile(parent, "./data/music/loumarchais - spaceship movement.wav");
    ambientMusic.amp(0.5);
    spaceshipEngine = new SinOsc(appRoot);
    spaceshipTheme.amp(0.5);
    spaceshipEngine.amp(0.5);
  }
  
  void playBackgroundMusic() {
    if (mode == GENERAL_VIEW) {
      ambientMusic.loop(); 
    } else {
      spaceshipTheme.loop();
    }
  }
  
  void switchBackgroundMusic() {
    if (mode == GENERAL_VIEW && spaceshipTheme.isPlaying()) {
      spaceshipTheme.stop();
      ambientMusic.loop();
    }
    if (mode == EXPLORE && ambientMusic.isPlaying()) {
      ambientMusic.stop();
      spaceshipTheme.loop();
    }
  }
  
  void startSpaceshipEngine() {
    if(selectFreq){
    //print(freqHighNave);
      spaceshipEngine.freq(freqHighNave);
    }else{
      //print(freqLowNave);
      spaceshipEngine.freq(freqLowNave);
    }
    selectFreq = !selectFreq;
    spaceshipEngine.play();
  }
  
  void stopSpaceshipEngine() {
    spaceshipEngine.stop();
  }
  
}
