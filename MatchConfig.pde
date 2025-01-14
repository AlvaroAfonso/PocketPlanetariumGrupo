/*
*  -Index-
*    1. SCENE ARGS
*    2. SCENE 
*    3. VIEWPORT
*      3.1. VIEWPORT UI COMPONENTS
*    4. UI COMPONENTS
*    5. SCENE CONTROLS
*/


public class MatchConfigurationScene extends Scene {
  
  ConfigMenu menu = new ConfigMenu(this, width, height, new PVector(0,0), Panel.DEFAULT_PRIORITY + 1);
  ArrayList<PlayerSpriteViewport> spriteViewports = new ArrayList(); 

  public MatchConfigurationScene() {
    panels.add(new MenuBackground());
    panels.add(menu);
    
    appRoot.registerMethod("draw", this);
  }
  
  public void draw() {
    if (menu.playerCards.size() != spriteViewports.size()) {
      while (menu.playerCards.size() != spriteViewports.size()) {
        if (menu.playerCards.size() > spriteViewports.size()) {
          int cardIndex = menu.config.players.size()-1;
          PlayerSpriteViewport spriteViewport = new PlayerSpriteViewport(menu.config.players.get(menu.config.players.size() - (menu.config.players.size() - spriteViewports.size())),
                                                                         menu.playerCardWidth / 4, menu.playerCardWidth / 4,
                                                                         new PVector(menu.padding + cardIndex * menu.playerCardWidth + cardIndex * menu.sectionMargin + menu.playerCardWidth - menu.innerSectionPadding - menu.playerCardWidth/4, 
                                                                                     menu.padding + menu.generalSettingsCard.getBackgroundHeight() + menu.sectionMargin), 
                                                                         menu.priority + 1);
          spriteViewports.add(spriteViewport);
        } else if (menu.playerCards.size() < spriteViewports.size()) {
          PlayerSpriteViewport spriteViewportToRemove = spriteViewports.get(spriteViewports.size() - 1);
          spriteViewports.remove(spriteViewportToRemove);
        }
      }
      
      for (PlayerSpriteViewport spriteViewport : spriteViewports) {
        int cardIndex = spriteViewports.indexOf(spriteViewport);
        spriteViewport.resize(menu.playerCardWidth / 4, menu.playerCardWidth / 4);
        spriteViewport.screenCoords = new PVector(menu.padding + cardIndex * menu.playerCardWidth + cardIndex * menu.sectionMargin + menu.playerCardWidth - menu.innerSectionPadding - menu.playerCardWidth/4, 
                                                  menu.padding + menu.generalSettingsCard.getBackgroundHeight() + menu.sectionMargin);
      }
    }
    
    for (PlayerSpriteViewport spriteViewport : spriteViewports) {
      spriteViewport.display();
    }
  }
  
  @Override
  public void dispose() {
    appRoot.unregisterMethod("draw", this);
    for (Panel panel : panels) {
      panel.dispose();      
    }
  }

}

class PlayerSpriteViewport extends Viewport {
  
  Player player;
  
  public PlayerSpriteViewport(Player player,int viewportWidth, int viewportHeight, PVector screenCoords, int priority) {
    super(viewportWidth, viewportHeight, screenCoords, priority);
    this.player = player;
  }
  
  @Override
  protected void renderContent() {
    canvas.imageMode(CENTER);
    canvas.translate(canvas.width/2, canvas.height/2);
    canvas.pushMatrix();
      canvas.rotateY(0.6 * frameCount/60);
      canvas.background(BG_COLOR);
      canvas.pushStyle();
        canvas.scale((float) canvas.width / (float) player.sprite.width);
        if (player.spriteColor != null) canvas.tint(player.spriteColor);
        canvas.image(player.sprite, 0, 0);
      canvas.popStyle();
    canvas.popMatrix();
  }
  
  @Override
  public void dispose() {
  
  }
}


class ConfigMenu extends UIComponent { 
  
  MatchConfigurationScene parentScene;
  
  private ControlP5 controlP5;
  
  private VersusMatchConfig config;
  
  Group generalSettingsCard;
  DraggableSlider playerNum;
  DraggableSlider playerLives;
  DraggableSlider playerSpeed;
  DraggableSlider bulletSpeed;
  DraggableSlider orbitSpeed;
  
  ArrayList<Group> playerCards;
  ArrayList<HashMap<String, Object>> playerCardElements;
  int activePlayerCards;
  int playerCardWidth;
  
  ClickableButton playButton;
  private float buttonWidth; 
  private float buttonHeight;
  
  int padding;
  int sectionMargin;
  int innerSectionPadding;
  int innerSectionMargin;
  
  public ConfigMenu(MatchConfigurationScene parentScene, int componentWidth, int componentHeight, PVector screenCoords, int priority) {
    super(componentWidth, componentHeight,  screenCoords, priority);
    this.parentScene = parentScene;
    controlP5 = new ControlP5(appRoot);
    controlP5.setGraphics(this.canvas, (int) this.screenCoords.x, (int) this.screenCoords.y);
    controlP5.setBackground(BG_COLOR);
    
    soundsManager.playBackgroundMusic(BackgroundMusic.AMBIENCE);
    
    padding = (int) (0.03 * componentWidth);
    sectionMargin = (int) (0.025 * componentWidth);
    innerSectionPadding = (int) (0.02 * componentWidth);
    innerSectionMargin = (int) (0.030 * componentWidth);
    
    buttonWidth = 300;
    buttonHeight = 35;
    
    setupDefaultConfiguration();
    setupDefaultGeneralSettings();
    setupDefaultPlayerCards();
    
    playButton = new ClickableButton(controlP5, "FIGHT!");
    playButton.setPosition(canvas.width/2 - buttonWidth/2, canvas.height - buttonHeight - sectionMargin)
               .setSize((int) buttonWidth, (int) buttonHeight)
               .setFont(CALL_TO_ACTION_FONT)
               .setColorBackground(SECONDARY_COLOR)
               .setColorForeground(PRIMARY_COLOR)
               .setColorActive(INTERACT_COLOR)
               ;
  }
  
  private void setupDefaultConfiguration() {
    config = new VersusMatchConfig();
    config.addPlayer(new Player("Player1", 0, controllerRepository.fetchController(0, ControllerID.MAIN_KEYBOARD), new PVector(random(-40, 4), 0, random(40, 50))));
    config.addPlayer(new Player("Player2", 1, controllerRepository.fetchController(1, ControllerID.ALT_KEYBOARD), new PVector(random(-40, 4), 0, random(40, 50))));
    config.setPlayerLives(3);
    config.setPlayerSpeed(600);
    config.setBulletSpeed(500);
    config.setOrbitationSpeedUp(1);
    
  }
  
  private void setupDefaultGeneralSettings() {
    generalSettingsCard = controlP5.addGroup("Match Settings")
                .disableCollapse()
                .setWidth(canvas.width - 2*padding)
                .setPosition(padding, padding)
                .setBackgroundHeight(325)
                .setBackgroundColor(BG_COLOR)
                ;
    
    int sliderWidth = generalSettingsCard.getWidth()/2 - 2*innerSectionPadding - innerSectionMargin;
    int sliderHeight = 35;
    
    playerNum = new DraggableSlider(controlP5, "Number of Players", 
                                   sliderWidth, sliderHeight, 
                                   new PVector(innerSectionPadding, innerSectionPadding ),
                                   2, 4, 3);
                                                    
    playerLives = new DraggableSlider(controlP5, "Player Lives", 
                                   sliderWidth, sliderHeight, 
                                   new PVector(innerSectionPadding, 
                                               innerSectionPadding + playerNum.getHeight() + innerSectionMargin),
                                   1, 5, 5);    
                                                    
    playerSpeed = new DraggableSlider(controlP5, "Max Player Speed", 
                                   sliderWidth, sliderHeight, 
                                   new PVector(innerSectionPadding + playerNum.getWidth() + innerSectionMargin, 
                                               innerSectionPadding),
                                   500, 1000, 50);
                                                    
    bulletSpeed = new DraggableSlider(controlP5, "Max Bullet Speed", 
                                   sliderWidth, sliderHeight, 
                                   new PVector(innerSectionPadding + playerLives.getWidth() + innerSectionMargin, 
                                               innerSectionPadding + playerSpeed.getHeight() + innerSectionMargin),
                                   500, 1000, 50);
                                   
    orbitSpeed = new DraggableSlider(controlP5, "Planet Orbitation Speed", 
                                   sliderWidth, sliderHeight, 
                                   new PVector(generalSettingsCard.getWidth()/2 - sliderWidth/2, 
                                               innerSectionPadding + playerSpeed.getHeight() + bulletSpeed.getHeight() + 2*innerSectionMargin),
                                   1, 1000, 100); 
                                   
    playerNum.setValue(config.players.size());
    playerLives.setValue(config.playerLives);
    playerSpeed.setValue(config.playerSpeed);
    bulletSpeed.setValue(config.bulletSpeed);
    orbitSpeed.setValue(config.orbitationSpeedUp);                                   
                                   
    playerNum.setGroup(generalSettingsCard);
    playerLives.setGroup(generalSettingsCard);
    playerSpeed.setGroup(generalSettingsCard);
    bulletSpeed.setGroup(generalSettingsCard);
    orbitSpeed.setGroup(generalSettingsCard);
  }
  
  private void setupDefaultPlayerCards() {
    playerCards = new ArrayList();
    playerCardElements = new ArrayList();
    
    playerCardWidth = (canvas.width - 2*padding - sectionMargin*(config.players.size() - 1)) / config.players.size();
    
    for (int i = 0; i < config.players.size(); i++) {      
      createPlayerConfigurationCard();
    }
  }
  
  private void addPlayer() {
    println(controllerRepository.getAvailableControllers());
    ControllerID controllerID = controllerRepository.getAvailableControllers().get(0);
    config.addPlayer(new Player("Player" + (config.players.size() + 1), config.players.size(), controllerRepository.fetchController(config.players.size(), controllerID), new PVector(random(-40, 4), 0, random(40, 50))));
    
    createPlayerConfigurationCard();
  }
  
  private void removePlayer() {
    int playerIndex = config.players.size() - 1;
    Player lastPlayer = config.players.get(playerIndex);
    controllerRepository.freeController(lastPlayer.controller);
    config.removePlayer(lastPlayer);
    
    // CLEAR CARD
    playerCardElements.remove(playerIndex);
    playerCards.get(playerIndex).remove();
    playerCards.remove(playerIndex);
  }
  
  private void updateCards() {
    playerCardWidth = (canvas.width - 2*padding - sectionMargin*(config.players.size() - 1)) / (config.players.size());
    for (Group playerCard : playerCards) {
      int cardIndex = playerCards.indexOf(playerCard);
      
      playerCard.setWidth(playerCardWidth);
      playerCard.setPosition(padding + cardIndex*playerCardWidth + cardIndex*sectionMargin, 
                           padding + generalSettingsCard.getBackgroundHeight() + sectionMargin);
      
      ((Controller) playerCardElements.get(cardIndex).get("Name")).setWidth(playerCardWidth/3 - 2*innerSectionPadding);
      ((Controller) playerCardElements.get(cardIndex).get("Controller")).setWidth((int)(playerCardWidth/1.5) - 2*innerSectionPadding);
      ((ControllerGroup) playerCardElements.get(cardIndex).get("Instructions")).setWidth(playerCardWidth - 2*innerSectionPadding);
      
      playerCard.update();
    }
  }
  
  private void createPlayerConfigurationCard() {
    int cardIndex = playerCards.size();
    Group playerCard = new Group(controlP5, "Player " + (cardIndex + 1))
              .disableCollapse()
              .setWidth(playerCardWidth)
              .setBackgroundHeight(canvas.height - generalSettingsCard.getBackgroundHeight() - 2*padding - 2*sectionMargin - (int) buttonHeight)
              .setPosition(padding + cardIndex*playerCardWidth + cardIndex*sectionMargin, 
                           padding + generalSettingsCard.getBackgroundHeight() + sectionMargin)
              .setBackgroundColor(BG_COLOR)
              ;      
    playerCards.add(playerCard);
    
    HashMap<String, Object> elements = new HashMap();
    playerCardElements.add(elements);
    
    TypableTextField nameField = new TypableTextField(controlP5, "Player " + (cardIndex + 1) + " Name", 
                                              playerCardWidth/3 - 2*innerSectionPadding, 35,
                                              new PVector(innerSectionPadding, innerSectionPadding));                                    
    nameField.setValue(config.players.get(cardIndex).name);   
    
    ColorPicker colorPicker = new ColorPicker(controlP5, "Player " + (cardIndex + 1) + " Color");
    colorPicker.setPosition(innerSectionPadding, innerSectionPadding + nameField.getHeight() + innerSectionMargin);
    if (cardIndex > 0) colorPicker.setColorValue(color(random(255), random(255), random(255), 255));
    else colorPicker.setColorValue(color(0, 0, 0, 0));
    
    ControllerSelector controllerSelector = new ControllerSelector(controlP5, "Player " + (cardIndex + 1) + " Controller",
                                              (int)(playerCardWidth/1.5) - 2*innerSectionPadding,
                                              new PVector(innerSectionPadding, innerSectionPadding + nameField.getHeight() + colorPicker.getBackgroundHeight() + 3*innerSectionMargin),
                                              cardIndex, config.players.get(cardIndex));
    
    Textarea controllerInstructions = new Textarea(controlP5, "Player " + (cardIndex + 1) + " Controls");
    controllerInstructions.setPosition(innerSectionPadding, innerSectionPadding + nameField.getHeight() + controllerSelector.getHeight() + 4*innerSectionMargin);
    controllerInstructions.setSize(playerCardWidth - 2*innerSectionPadding, playerCard.getBackgroundHeight() - 2*innerSectionPadding - nameField.getHeight() - controllerSelector.getHeight() - 2*innerSectionMargin);
    controllerInstructions.setFont(DETAIL_FONT);
    controllerInstructions.setLineHeight(20);
    controllerInstructions.setColor(PRIMARY_FONT_COLOR);
    //controllerInstructions.setColorBackground(color(255,100));
    controllerInstructions.setColorForeground(SECONDARY_COLOR);           
    
    String controllerInstructionsText = "";
    for (String line : controllerRepository.getControllerID(config.players.get(cardIndex).controller).instructions) {
      controllerInstructionsText += line + "\n";
    }
    controllerInstructions.setText(controllerInstructionsText);
                                                                                                     
    nameField.setGroup(playerCard);
    colorPicker.setGroup(playerCard);
    controllerSelector.setGroup(playerCard);   
    controllerInstructions.setGroup(playerCard);   
    
    elements.put("Name", nameField);
    elements.put("Color", colorPicker);
    elements.put("Controller", controllerSelector);
    elements.put("Instructions", controllerInstructions);
  }
  
  @Override
  public void renderContent() {
    // Match Settings
    if (playerNum.getValue() != config.players.size()) {
      while(playerNum.getValue() != config.players.size()) {
        if (playerNum.getValue() > config.players.size()) addPlayer();
        if (playerNum.getValue() < config.players.size()) removePlayer();
      }
      updateCards();
    }
    if (playerLives.changed()) config.setPlayerLives((int) playerLives.getValue());
    if (playerSpeed.changed()) config.setPlayerSpeed((int) playerSpeed.getValue());
    if (bulletSpeed.changed()) config.setBulletSpeed((int) bulletSpeed.getValue());
    if (orbitSpeed.changed()) config.setOrbitationSpeedUp((int) orbitSpeed.getValue());
    
    // Player Cards
    ArrayList<ControllerSelector> controllerSelectors = new ArrayList();
    ArrayList<Textarea> controllerInstructions = new ArrayList();
    boolean aNewControllerWasSelected = false;
    for (Group playerCard : playerCards) {
      int playerCardIndex = playerCards.indexOf(playerCard);
      
      TypableTextField nameField = (TypableTextField) playerCardElements.get(playerCardIndex).get("Name");
      ColorPicker colorPicker = (ColorPicker) playerCardElements.get(playerCardIndex).get("Color");
      ControllerSelector controllerSelector = (ControllerSelector) playerCardElements.get(playerCardIndex).get("Controller");
      Textarea instructions = (Textarea) playerCardElements.get(playerCardIndex).get("Instructions");
      
      controllerSelectors.add(controllerSelector);
      controllerInstructions.add(instructions);
      
      if (nameField.changed()) config.players.get(playerCardIndex).name = nameField.getText();
      if (colorPicker.getColorValue() != color(0, 0, 0, 0)) config.players.get(playerCardIndex).spriteColor = color(colorPicker.getArrayValue(0), colorPicker.getArrayValue(1), colorPicker.getArrayValue(2), 255);
      else config.players.get(playerCardIndex).spriteColor = null;
      if (controllerSelector.newControllerWasSelected()) aNewControllerWasSelected = true;
    }
    if (aNewControllerWasSelected) {
      for (ControllerSelector controllerSelector : controllerSelectors) {
        controllerSelector.updateAvailableControllers();
      }
      for (Textarea instructions : controllerInstructions) {
        String controllerInstructionsText = "";
        for (String line : controllerRepository.getControllerID(config.players.get(controllerInstructions.indexOf(instructions)).controller).instructions) {
          controllerInstructionsText += line + "\n";
        }
        instructions.setText(controllerInstructionsText);
      }
    }
    
    // Start Game
    if (playButton.wasClicked()) switchScene(new MatchScene(config));
  }
  
   @Override
  public void dispose() {
    parentScene = null;
    controlP5.dispose();
    controlP5.setVisible(false);
    controlP5.setAutoDraw(false);
  }
  
}
