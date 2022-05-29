

class LoadingScene extends Scene {
  
  public LoadingScene() {
    uiComponents.add(new UIComponent(width, height, new PVector(0,0), UIComponent.DEFAULT_PRIORITY) {
      
      private float opacity = 0.0;
      
      @Override
      protected void renderContent() {
        canvas.background(0);
        canvas.translate(width/2.0 - 25, height/2.0);
        canvas.textSize(20);
        canvas.fill(255, 255.0 - opacity);
        opacity += 4;
        if (opacity >= 255.0) opacity = 0.0;
        canvas.text("LOADING...", 0, 0);
        canvas.fill(255);
      }
      
      @Override
      public void dispose() {
      
      }
    });
  }

}
