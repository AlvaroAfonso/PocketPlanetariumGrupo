
class MainMenu extends Scene {

  public MainMenu() {
    viewports.add(new MenuBackground());
    uiComponents.add(new Menu((int) (width/6), (int) (height/3), new PVector(width/2, height/2), "Battle4CIU"));
  }
  
}

class MenuBackground extends Viewport {
  
  WorldModel gameWorld;
  
  public MenuBackground() {
    super(width, height, new PVector(0,0), Panel.DEFAULT_PRIORITY);
    this.gameWorld = new WorldModel(canvas, solarSystemData);
  }

   @Override
   protected void renderContent() {
     canvas.background(0);
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
    controlP5.setBackground(color(90, 90, 100, 180));
    controlP5.setGraphics(this.canvas, (int) this.screenCoords.x, (int) this.screenCoords.y); 
    
    buttonWidth = canvas.width - 60;
    buttonHeight = 30;
    
    int titleSize = 40;
    
    controlP5.addTextlabel("Title")
                    .setText(title)
                    .setPosition(canvas.width/2 - titleSize * title.length()/4, 30)
                    .setColorValue(color(255))
                    .setFont(createFont("Arial", titleSize))
                    ;
     playButton = new ClickableButton(controlP5);
     playButton.setPosition(canvas.width/2 - buttonWidth/2, canvas.height/2 - buttonHeight/2 + 30)
               .setSize((int) buttonWidth, (int) buttonHeight)
               .setFont(createFont("Arial Bold", 0.4*titleSize, true))
               ;
  }

   @Override
   protected void renderContent() {
     if (!playButton.isClicked) return; 
     if(nPosePlayers==0){
        player1 = new Player("Player1", new MouseKeyboardControl(new MainKeyboardMap(), false), new PVector(20, 0, 50));
        player2 = new Player("Player2", new MouseKeyboardControl(new AltKeyboardMap(), true), new PVector(-20, 0, 50));
      } else if(nPosePlayers==1){
        player1 = new Player("Player1", new PoseControl(poseDetectionService), new PVector(20, 0, 50));
        player2 = new Player("Player2", new MouseKeyboardControl(new MainKeyboardMap(), false), new PVector(-20, 0, 50));
      } else {
        player1 = new Player("Player1", new PoseControl(poseDetectionService), new PVector(20, 0, 50));
        player2 = new Player("Player2", new PoseControl(poseDetectionService), new PVector(-20, 0, 50));
      }
  
     ArrayList<Player> players = new ArrayList();
     players.add(player1);
     players.add(player2);
    switchScene(new VersusMatchScene(new VersusMatchConfig(players, solarSystemData)));
   }
   
   @Override
  public void dispose() {
    controlP5.dispose();
    controlP5.setVisible(false);
    controlP5.setAutoDraw(false);
  }

}
