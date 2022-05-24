

class LoadingScene extends Scene {
  
  public LoadingScene() {
    viewports.add(new Viewport(width, height, new PVector(0,0), Viewport.DEFAULT_PRIORITY) {
      private float opacity = 0.0;
      
      @Override
      protected void renderContent() {
        canvas.background(0);
        canvas.translate(width/2.0 - 25, height/2.0, -200);
        canvas.textSize(10);
        //fill(color(255, 255, 255));
        canvas.fill(255, 255.0 - opacity);
        opacity += 2;
        if (opacity >= 255.0) opacity = 0.0;
        canvas.text("LOADING...", 0, 0);
        canvas.fill(255);
      }
    });
  }

}
