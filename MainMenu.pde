
class MainMenu extends Scene {

  public MainMenu() {
    panels.add(new MenuBackground());
    panels.add(new Menu((int) (width/6), (int) (height/3), new PVector(width/2, height/2), "Battle4CIU"));
  }
  
}

class MenuBackground extends Viewport {
  
  WorldModel gameWorld;
  private PImage background = loadImage("./data/images/Milky Way.jpg");
  
  public MenuBackground() {
    super(width, height, new PVector(0,0), Panel.DEFAULT_PRIORITY);
    this.gameWorld = new WorldModel(canvas, solarSystemData);
    background.resize(width, height);
  }

   @Override
   protected void renderContent() {
     canvas.background(background); 
     solarSystemData.update();
     gameWorld.display(true);
     canvas.camera(canvas.width/2, canvas.height/2 - 20, 70,   canvas.width/2 - 50, canvas.height/2, 0,   0, 1, 0);
     canvas.perspective(PI/3.0, (float)canvas.width/canvas.height, 1, 100000);
   }
   
   @Override
   public void dispose() {
   }
}

class Menu extends UIComponent {
  
  private ControlP5 controlP5;
  
  private int menuWidth;
  private int menuHeight;
  
  private float buttonWidth; 
  private float buttonHeight;
  
  ClickableButton playButton;
  
  public Menu(int menuWidth, int menuHeight, PVector screenCoords, String title) {
    super(menuWidth, menuHeight, new PVector(screenCoords.x - menuWidth/2, screenCoords.y - menuHeight/2), Panel.DEFAULT_PRIORITY + 1000);
    controlP5 = new ControlP5(appRoot);
    controlP5.setBackground(BG_COLOR);
    controlP5.setGraphics(this.canvas, (int) this.screenCoords.x, (int) this.screenCoords.y); 
    
    buttonWidth = canvas.width - 60;
    buttonHeight = 30;
    
    
    controlP5.addTextlabel("Title")
                    .setText(title)
                    .setPosition(canvas.width/2 - TITLE_SIZE * title.length()/4, 30)
                    .setColorValue(PRIMARY_FONT_COLOR)
                    .setFont(TITLE_FONT)
                    ;
     playButton = new ClickableButton(controlP5, "Play");
     playButton.setPosition(canvas.width/2 - buttonWidth/2, canvas.height/2 - buttonHeight/2 + 30)
               .setSize((int) buttonWidth, (int) buttonHeight)
               .setFont(CALL_TO_ACTION_FONT)
               .setColorBackground(SECONDARY_COLOR)
               .setColorForeground(PRIMARY_COLOR)
               .setColorActive(INTERACT_COLOR)
               ;
  }

   @Override
   protected void renderContent() {
     if (!playButton.wasClicked()) return;
     switchScene(new MatchConfigurationScene());
   }
   
   @Override
  public void dispose() {
    controlP5.dispose();
    controlP5.setVisible(false);
    controlP5.setAutoDraw(false);
  }

}
