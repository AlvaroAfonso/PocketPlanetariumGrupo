

class LoadingScene extends Scene {
  
  public LoadingScene() {
    uiComponents.add(new UIComponent(width, height, new PVector(0,0), UIComponent.DEFAULT_PRIORITY) {
      
      private float opacity = 0.0;
      private final String loadingText = "LOADING...";
      
      @Override
      protected void renderContent() {
        canvas.background(0);
        canvas.translate(width/2.0 - TITLE_SIZE * loadingText.length()/3, height/2.0);
        canvas.textSize(TITLE_SIZE);
        canvas.fill(255, 255.0 - opacity);
        opacity += 3;
        if (opacity >= 255.0) opacity = 0.0;
        canvas.text(loadingText, 0, 0);
        canvas.fill(255);
      }
      
      @Override
      public void dispose() {
      
      }
    });
  }

}
