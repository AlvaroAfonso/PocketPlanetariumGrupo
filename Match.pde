/*
*  -Index-
*    1. SCENE ARGS
*    2. SCENE 
*    3. VIEWPORT
*      3.1. VIEWPORT UI COMPONENTS
*    4. UI COMPONENTS
*    5. SCENE CONTROLS
*/


/*-------------------------------- 
        1. SCENE ARGS
--------------------------------*/
public enum Layout {
    HORIZONTAL,
    VERTICAL  
}

public class VersusMatchConfig {

  ArrayList<Player> players;
  World worldData;
  
  Layout viewportLayout;
  
  int playerLives;
  int playerSpeed;
  int bulletSpeed;
  int orbitationSpeedUp;
  
  public VersusMatchConfig() {
    players = new ArrayList();
    worldData = solarSystemData;
    viewportLayout = Layout.VERTICAL;
  }
  
  public VersusMatchConfig(ArrayList<Player> players, World worldData) {
    this.players = players;
    this.worldData = worldData;
    viewportLayout = Layout.VERTICAL;
  }
  
  public void addPlayer(Player newPlayer) {
    players.add(newPlayer);
  }
  
  public void removePlayer(Player playerToRemove) {
    players.remove(playerToRemove);
  }
  
  public void setPlayerLives(int lives) {
    this.playerLives = lives;
    for (Player player : players) {
      player.setLives(lives);
    }
  }
  
  public void setPlayerSpeed(int speed) {
    this.playerSpeed = speed;
    for (Player player : players) {
      player.setMaxSpeed(speed);
    }
  }
  
  public void setBulletSpeed(int speed) {
    this.bulletSpeed = speed;
    for (Player player : players) {
      player.setBulletSpeed(speed);
    }
  }
  
  public void setOrbitationSpeedUp(int speedUp) {
    this.orbitationSpeedUp = speedUp;
    worldData.setSpeedUp(speedUp);
  }
  
}


/*--------------------------------  
            2. SCENE
--------------------------------*/
public class MatchScene extends Scene {
  
  VersusMatchConfig config;
  private ArrayList<Player> players;
  private World worldData;
  
  ArrayList<Collisionable> collisionableBodies;
  
  private int defeatCounter = 0;
  private boolean gameOver = false;
  
  public MatchScene(VersusMatchConfig config) {
    super();    
    this.config = config;
    this.players = config.players;
    this.worldData = config.worldData;
    
    collisionableBodies = new ArrayList();
    for (Player player : players) {
      collisionableBodies.add(player);
    }
    
    int viewportWidth = config.viewportLayout == Layout.VERTICAL ? width/config.players.size() : width;
    int viewportHeight = config.viewportLayout == Layout.HORIZONTAL ? height/config.players.size() : height;
    
    for (Player player : players) {
      PVector viewportCoords = config.viewportLayout == Layout.VERTICAL ? new PVector(players.indexOf(player)*viewportWidth, 0) : new PVector(0, players.indexOf(player)*viewportHeight);
      panels.add(new PlayerViewport(viewportWidth, viewportHeight, viewportCoords, player, players, worldData));
      panels.add(new PlayerHUD(player, viewportWidth, viewportHeight, viewportCoords, Panel.DEFAULT_PRIORITY + 1));
      
    }

    appRoot.registerMethod("pre", this);
    
  }
  
  public void pre() {    
    
    if (gameOver) return;
    
    // Update Positions
    worldData.update();
    for (Player player : players) {
      if (player.isDefeated) continue;
      player.update();
    }
    
    // Check Collisions
    HashMap<Integer,Integer> totalBlasterCollisions = new HashMap();
    for (Player player : players) {
      player.blaster.trackPlayers(players);
      HashMap<Integer,Integer> blasterCollisions = player.blaster.checkCollisions(collisionableBodies);
      for (Integer collisionedBodyIndex : blasterCollisions.keySet()) {
        Integer previousCollisions = totalBlasterCollisions.get(collisionedBodyIndex);
        if (previousCollisions != null) totalBlasterCollisions.put(collisionedBodyIndex, previousCollisions + blasterCollisions.get(collisionedBodyIndex));
        else totalBlasterCollisions.put(collisionedBodyIndex, blasterCollisions.get(collisionedBodyIndex));
      }
    }
    
    // Update Lives & Check for Game Over
    for (int playerIndex = 0; playerIndex < players.size(); playerIndex++) {
      Player blastedPlayer = players.get(playerIndex);
        
      if (blastedPlayer.isDefeated) continue;
        
      Integer playerCollisions = totalBlasterCollisions.get(playerIndex);
        
      if (playerCollisions != null) blastedPlayer.setLives(blastedPlayer.lives - playerCollisions);
      if (blastedPlayer.isDefeated) defeatCounter++;
    }
    
    if (defeatCounter >= players.size() - 1) gameOver();
    
  } 
  
  private void gameOver() {
    gameOver = true;
    Player winner = null;
    for (Player player: players) {
      if (player.lives > 0) {
        winner = player;
        break;
      }
    }
    panels.add(new GameOverModal(this, winner, width, height, new PVector(0, 0), Panel.DEFAULT_PRIORITY + 1));   
  }
  
  @Override 
  public void dispose() {
    appRoot.unregisterMethod("pre", this);
    for (Panel panel : panels) {
      panel.dispose();      
    }
  }

}


/*-------------------------------- 
          3. VIEWPORT
--------------------------------*/
public class PlayerViewport extends Viewport {
  
  private Player currentPlayer;
  private ArrayList<PlayerModel> playerModels;
  private ArrayList<BlasterModel> blasterModels;
  private WorldModel gameWorld;
  
  private Camera cam;
  
  public PlayerViewport(int viewportWidth, int viewportHeight, PVector screenCoords, Player currentPlayer, ArrayList<Player> players, World world) {
    super(viewportWidth, viewportHeight, screenCoords, DEFAULT_PRIORITY);
    this.currentPlayer = currentPlayer;
    this.gameWorld = new WorldModel(canvas, world);
    this.cam = new NativeThirdPersonCamera(canvas, currentPlayer);
    this.playerModels = new ArrayList();
    this.blasterModels = new ArrayList();
    for (Player player : players) {
      playerModels.add(new PlayerModel(canvas, player));
      blasterModels.add(new BlasterModel(canvas, player.blaster));
    }
  }  
  
  @Override
  protected void renderContent() {
    canvas.background(0); 
    gameWorld.display(true);
    
    for (BlasterModel blasterModel : blasterModels) {
      blasterModel.display();
    } 
      
    //We sort the players from farthest to closest based on their distance to current player.
    Collections.sort(playerModels, new Comparator<PlayerModel>() {
      @Override
      public int compare(PlayerModel modelA, PlayerModel modelB) {
        float distanceA = distanceBetween(cam.getPosition(), modelA.player.position);
        float distanceB = distanceBetween(cam.getPosition(), modelB.player.position);
        if (distanceA > distanceB) return -1;
        if (distanceA < distanceB) return 1;
        return 0;
      }
    });
    
    for (PlayerModel playerModel : playerModels) {
      if (!playerModel.player.isDefeated) playerModel.display();
    }    
  }
  
  @Override
   public void dispose() {
     println("Disposing PlayerView");
     appRoot.unregisterMethod("pre", this);
     //currentPlayer.controller.dispose();
     controllerRepository.freeController(currentPlayer.controller);
   }
  
}


/*-------------------------------- 
3. UI COMPONENTS
--------------------------------*/
class PlayerHUD extends UIComponent { 
  
  private ControlP5 controlP5;
  
  Player player;
  
  Knob speedmeter;
  Slider lifeBar;
  Textlabel defeatLabel;
  
  public PlayerHUD(Player player, int componentWidth, int componentHeight, PVector screenCoords, int priority) {
    super(componentWidth, componentHeight,  screenCoords, priority);
    this.player = player;

    controlP5 = new ControlP5(appRoot);
    //controlP5.setBackground(BG_COLOR);
    controlP5.setGraphics(this.canvas, (int) screenCoords.x, (int) screenCoords.y);   
    
    setupPlayerLife();
    setupSpeedmeter(80);
    
    defeatLabel = controlP5.addTextlabel("Defeat")
                    .setText("Defeated")
                    .setPosition(canvas.width/2 - TITLE_SIZE * 2, canvas.height/2 - TITLE_SIZE * 2)
                    .setColorValue(SECONDARY_COLOR)
                    .setFont(TITLE_FONT)
                    .setVisible(false)
                    ;
  }
  
  private void setupPlayerLife() {
    lifeBar = controlP5.addSlider("Life")
                .setSize(canvas.width/4, 35)
                .setPosition(15, 15)
                .setRange(0, player.lives)
                .setValue(player.lives)
                .setNumberOfTickMarks(player.lives)
                .snapToTickMarks(true)
                .showTickMarks(false)
                .setSliderMode(Slider.FIX)
                .setColorBackground(PRIMARY_COLOR)
                .setColorForeground(SECONDARY_COLOR)
                .setColorActive(INTERACT_COLOR)
                .setLabelVisible(false)
                .setLock(true)
                ;
  }
  
  private void setupSpeedmeter(int radius) {
    speedmeter = controlP5.addKnob("Speed")
               .setRange(0, player.maxSpeed / LIGHT_SPEED)
               .setValue(0)
               .setPosition(canvas.width - 3*radius, canvas.height - 3*radius)
               .setRadius(radius)
               .setColorForeground(PRIMARY_FONT_COLOR)
               .setColorBackground(PRIMARY_COLOR)
               .setLock(true)
               ;
  }
  
  private void showDefeatScreen() {
    lifeBar.setVisible(false);
    speedmeter.setVisible(false);
    controlP5.setBackground(BG_DEFEAT_COLOR);
    defeatLabel.setVisible(true);
  }
  
  @Override
  protected void renderContent() {
    if (player.isDefeated) {
      if (!defeatLabel.isVisible()) showDefeatScreen();
      return;
    } else {
      controlP5.setBackground(color(0, 0, 0, 0));
      defeatLabel.setVisible(false);
    }
    lifeBar.setValue(player.lives);
    if (player.controller.moveForward || player.controller.moveBackward 
        || player.controller.moveLeft || player.controller.moveRight 
        || player.controller.moveUp || player.controller.moveDown) speedmeter.setColorForeground(INTERACT_COLOR);
    else speedmeter.setColorForeground(PRIMARY_FONT_COLOR);
    speedmeter.setValue(player.speed.mag()/LIGHT_SPEED  * 60 * DISTANCE_SCALE);
  }
  
  @Override
  public void dispose() {
    controlP5.dispose();
    controlP5.setVisible(false);
    controlP5.setAutoDraw(false);
  }

}

class GameOverModal extends UIComponent {

  private ControlP5 controlP5;
  
  private MatchScene parentScene;
  
  Textlabel matchResult;
  
  private float buttonWidth; 
  private float buttonHeight;
  ClickableButton returnToSettingsButton;
  
  private Player winner;
  
  public GameOverModal(MatchScene parentScene, Player winner, int componentWidth, int componentHeight, PVector screenCoords, int priority) {
    super(componentWidth, componentHeight,  screenCoords, priority);
    this.parentScene = parentScene;
    this.winner = winner;
    
    controlP5 = new ControlP5(appRoot);
    controlP5.setGraphics(this.canvas, (int) screenCoords.x, (int) screenCoords.y);
    
    buttonWidth = canvas.width/4;
    buttonHeight = 30;
    
    String matchResultContent;
    if (winner == null) {
      controlP5.setBackground(BG_TIE_COLOR);
      matchResultContent = "It's a TIE!";
    } else {
      controlP5.setBackground(BG_COLOR);
      matchResultContent = "WINNER: " + winner.name;
    }   
     matchResult = controlP5.addTextlabel("Match Result")
                    .setText(matchResultContent)
                    .setPosition(canvas.width/2 - TITLE_SIZE * matchResultContent.length()/4, canvas.height/2 - 3*TITLE_SIZE)
                    .setColorValue(PRIMARY_FONT_COLOR)
                    .setFont(TITLE_FONT)
                    ;
               
    returnToSettingsButton = new ClickableButton(controlP5, "Return to Settings");
    returnToSettingsButton.setPosition(canvas.width/2 - buttonWidth/2, canvas.height/2 - buttonHeight/2 + matchResult.getHeight() + 50)
               .setSize((int) buttonWidth, (int) buttonHeight)
               .setFont(CALL_TO_ACTION_FONT)
               .setColorBackground(PRIMARY_COLOR)
               .setColorForeground(SECONDARY_COLOR)
               .setColorActive(INTERACT_COLOR)
               ;
    
  }
  
  @Override
  protected void renderContent() {    
    if (returnToSettingsButton.wasClicked()) {
      parentScene.dispose();
      switchScene(new VersusMatchConfigurationScene());
    }
  }
  
  @Override
  public void dispose() {
    controlP5.setBackground(color(0, 0, 0, 0));
    controlP5.dispose();
    controlP5.setVisible(false);
    controlP5.setAutoDraw(false);
  }

}
