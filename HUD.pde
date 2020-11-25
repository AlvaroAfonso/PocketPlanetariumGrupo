public static PMatrix generateBillboardMatrix(PMatrix currentMatrix) {
  float[] elemns = currentMatrix.get(null);
  PMatrix billboardMatrix = new PMatrix3D();
  for (int i = 0; i < 11; i++) {
    if (i % 4 == 3) continue;
    elemns[i] = 0.0;
  }
  for (int i = 0; i < 3; i++) {
    elemns[i * 4 + i] = 1.0;
  }
  billboardMatrix.set(elemns);
  return billboardMatrix;
}


class HUD { 
  
  private final int LEFT_MARGIN = 50;
  private final int TOP_MARGIN = 70;
  
  private final int TEXT_SIZE = 25;
  private final int LINE_SPACING = TEXT_SIZE + 5;
  private final int PARAGRAPH_SPACING = TEXT_SIZE + 45;
  
  private int lines;
  private int paragraphs;
  
  void show() {
    lines = 0;
    paragraphs = 0;
    
    cameraControl.beginHUD();
    
    textSize(TEXT_SIZE);
    fill(color(255, 255, 255));
    
    if (mode == GENERAL_VIEW) {
      text("PRESS ENTER TO EXPLORE!!", width/2.0 - 6 * TEXT_SIZE, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("INSTRUCTIONS", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("------------", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("Press TAB to toggle HUD", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("Press UP or DOWN to speed up time", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      
      paragraphs++;
      text("Click and drag to control the camera", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    } else {
      text("Press ENTER to return to general view", width/2.0 - 9 * TEXT_SIZE, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("INSTRUCTIONS", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("------------", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("Press TAB to toggle HUD", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("Press UP or DOWN to speed up time", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      
      paragraphs++;
      text("SPACESHIP CONTROLS", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("------------------", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("Move the mouse to look around", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("DO NOT CLICK, CAMERA IS STILL BUGGY", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      
      paragraphs++;
      text("Note - Spaceship is subject to INERTIA!", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("Use W A S D to accelerate with respect to where you look", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("Use X and SPACE to accelerate Downwards or Upwards", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      text("Press R to STOP", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      
      paragraphs++;
      float currentSpeed = spaceship.speed.mag()*60 * DISTANCE_SCALE;
      if (currentSpeed < 300000) {
        text("Speed: " + currentSpeed + "km/s", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      } else {
        text("Speed: ~" + (int)currentSpeed/300000 + " x Speed of light", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
      }
      
    }
    
    paragraphs++;
    text("TIME", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    text("----", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    text(earthRotationPeriod + "s = A day in Earth", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    text(earthOrbitalPeriod/60 + "min = A year in Earth", LEFT_MARGIN,  TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    text("SPEED UP: " + SPEED_FACTOR, LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    
    paragraphs++;
    text("DISTANCE", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    text("--------", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    text("1 pixel = " + DISTANCE_SCALE + "km", LEFT_MARGIN,  TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    
    paragraphs++;
    text("SIZE", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    text("----", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    text("Size scale: 1 pixel = " + SIZE_SCALE + "km", LEFT_MARGIN, TOP_MARGIN + lines++ * LINE_SPACING + paragraphs * PARAGRAPH_SPACING);
    
    cameraControl.endHUD();
    
  }
  
}
