import controlP5.*;

class ClickableButton extends Button {
  
  private class ClickableButtonHandler implements CallbackListener {
    
    private ClickableButton button;
    
    public ClickableButtonHandler(ClickableButton button) {
      this.button = button;
    }
    
    public void controlEvent(CallbackEvent theEvent) {
      if (theEvent.getAction() == ControlP5.ACTION_CLICK) button.click();
    }
  }
  
  private CallbackListener handler = new ClickableButtonHandler(this);  
  boolean isClicked;
  
  public ClickableButton(ControlP5 controlP5) {
    super(controlP5, "play");
    this.addCallback(handler);
    isClicked = false;
  }
  
  public void click() {
    this.isClicked = true;
  }
  
}


class PlayerHUD extends UIComponent { 
  
  private ControlP5 controlP5;
  
  Player player;
  
  Knob speedmeter;
  
  public PlayerHUD(Player player, int componentWidth, int componentHeight, PVector screenCoords, int priority) {
    super(componentWidth, componentHeight,  screenCoords, priority);
    this.player = player;

    controlP5 = new ControlP5(appRoot);
    controlP5.setBackground(color(0, 0, 0, 0));
    controlP5.setGraphics(this.canvas, (int) screenCoords.x, (int) screenCoords.y);   
    
    setupPlayerLife();
    setupSpeedmeter(80);
  }
  
  private void setupPlayerLife() {
    // TO BE DONE
  }
  
  private void setupSpeedmeter(int radius) {
    speedmeter = controlP5.addKnob("Speed")
               .setRange(0, player.maxSpeed / LIGHT_SPEED)
               .setValue(0)
               .setPosition(canvas.width - 3*radius, canvas.height - 3*radius)
               .setRadius(radius)
               .setColorForeground(color(255))
               .setColorBackground(color(0, 100, 170))
               .setLock(true)
               ;
  }
  
  @Override
  protected void renderContent() {
    if (player.controller.moveForward || player.controller.moveBackward 
        || player.controller.moveLeft || player.controller.moveRight 
        || player.controller.moveUp || player.controller.moveDown) speedmeter.setColorForeground(color(255, 255, 0));
    else speedmeter.setColorForeground(color(255));
    speedmeter.setValue(player.speed.mag()/LIGHT_SPEED  * 60 * DISTANCE_SCALE);
  }
  
  @Override
  public void dispose() {
    controlP5.dispose();
    controlP5.setVisible(false);
    controlP5.setAutoDraw(false);
  }

}
