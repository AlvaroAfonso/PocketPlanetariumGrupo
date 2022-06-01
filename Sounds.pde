import processing.sound.*;

public enum BackgroundMusic  {
  AMBIENCE,
  BATTLE
}

class SoundsManager {
  
  private SoundFile ambientMusic;
  private SoundFile spaceshipTheme;
  //private SoundFile spaceshipEngine;
  
  private SinOsc[] spaceshipEngine = new SinOsc[4];
  private SinOsc blasterSound;
  private SinOsc explosionSound;
  private int explosionCountdown=0;;
  private float freqBlaster = 0;    // used for countdown
  private boolean[] selectFreq = new boolean[4];
  private float freqHighNave = 500;
  private float freqLowNave = 450;
  private float freqHighBlaster= 860;
  private float freqLowBlaster = 740;
  private float baseFreqExplosion = 260;
  private float currentFreqExplosion;
  
  SoundsManager() {
    ambientMusic = new SoundFile(appRoot, "./data/music/mrthenoronha - ambient.wav");
    spaceshipTheme = new SoundFile(appRoot, "./data/music/legend1060 - spaceship theme.wav");
    ambientMusic.amp(0.5);
    spaceshipTheme.amp(0.5);
    blasterSound = new SinOsc(appRoot);
    blasterSound.amp(0.75);
    explosionSound = new SinOsc(appRoot);
    explosionSound.amp(0.75);
    for(int i=0; i<4; i++){
      spaceshipEngine[i] = null;
      selectFreq[i] = false;
    }
  }
  
  void registerEngine(int id){
    spaceshipEngine[id]=new SinOsc(appRoot);
    spaceshipEngine[id].amp(0.5);
  }
  
  void blasterFX(){
    if(freqBlaster<freqLowBlaster){
      freqBlaster=freqHighBlaster;
      blasterSound.freq(freqBlaster);
      blasterSound.play();
    }
  }
  
  void explosionFX(){
    if(explosionCountdown<=0){
      explosionCountdown=51;
      currentFreqExplosion=baseFreqExplosion;
      explosionSound.freq(currentFreqExplosion);
      explosionSound.play();
    }
  }
  
  void playBackgroundMusic(BackgroundMusic music) {
    if (music == BackgroundMusic.AMBIENCE) {
      ambientMusic.loop(); 
    } else if (music == BackgroundMusic.BATTLE) {
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
  
  void startSpaceshipEngine(int id) {
    if(selectFreq[id]){
      spaceshipEngine[id].freq(freqHighNave);
    }else{
      //print(freqLowNave);
      spaceshipEngine[id].freq(freqLowNave);
    }
    selectFreq[id] = !selectFreq[id];
    spaceshipEngine[id].play();
  }
  
  void stopSpaceshipEngine(int id) {
    spaceshipEngine[id].stop();
  }
  
  void update(){
    if(freqBlaster>=freqLowBlaster){
      freqBlaster-=5;
      blasterSound.freq(freqBlaster);
      blasterSound.play();
    } else{
      blasterSound.stop();
    }
    if(explosionCountdown>0){
      if(explosionCountdown%3==0){
        currentFreqExplosion += random(-15,15);
        explosionSound.freq(currentFreqExplosion);
        explosionSound.play();
      }
      explosionCountdown--;
    } else{
      explosionSound.stop();
    }
  }
  
}
