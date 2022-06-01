/*
*  -Index-
*    1. SCENE ARGS
*    2. SCENE 
*    3. VIEWPORT
*      3.1. VIEWPORT UI COMPONENTS
*    4. UI COMPONENTS
*    5. SCENE CONTROLS
*/


class VersusMatchConfigurationScene extends Scene {

  public VersusMatchConfigurationScene() {
    panels.add(new MenuBackground());
    panels.add(new ConfigMenu(width, height, new PVector(0,0), Panel.DEFAULT_PRIORITY + 1));
  }

}


class ConfigMenu extends UIComponent { 
  
  private ControlP5 controlP5;
  
  private VersusMatchConfig config;
  
  Group generalSettingsCard;
  DraggableSlider playerNum;
  DraggableSlider playerLives;
  DraggableSlider playerSpeed;
  DraggableSlider bulletSpeed;
  DraggableSlider orbitSpeed;
  
  ArrayList<Group> playerCards;
  ArrayList<HashMap<String, Controller>> playerCardElements;
  int activePlayerCards;
  int playerCardWidth;
  
  ClickableButton playButton;
  private float buttonWidth; 
  private float buttonHeight;
  
  int padding;
  int sectionMargin;
  int innerSectionPadding;
  int innerSectionMargin;
  
  public ConfigMenu(int componentWidth, int componentHeight, PVector screenCoords, int priority) {
    super(componentWidth, componentHeight,  screenCoords, priority);
    controlP5 = new ControlP5(appRoot);
    controlP5.setGraphics(this.canvas, (int) this.screenCoords.x, (int) this.screenCoords.y);
    controlP5.setBackground(BG_COLOR);
    
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
      
      playerCardElements.get(cardIndex).get("Name").setWidth(playerCardWidth/3 - 2*innerSectionPadding);
      playerCardElements.get(cardIndex).get("Controller").setWidth((int)(playerCardWidth/1.5) - 2*innerSectionPadding);
      
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
    
    HashMap<String, Controller> elements = new HashMap();
    playerCardElements.add(elements);
    
    TypableTextField nameField = new TypableTextField(controlP5, "Player " + (cardIndex + 1) + " Name", 
                                              playerCardWidth/3 - 2*innerSectionPadding, 35,
                                              new PVector(innerSectionPadding, innerSectionPadding));                                    
    nameField.setValue(config.players.get(cardIndex).name);                                              
    
    ControllerSelector controllerSelector = new ControllerSelector(controlP5, "Player " + (cardIndex + 1) + " Controller",
                                              (int)(playerCardWidth/1.5) - 2*innerSectionPadding,
                                              new PVector(innerSectionPadding, innerSectionPadding + nameField.getHeight() + innerSectionMargin),
                                              cardIndex, config.players.get(cardIndex));
                                                                                                     
    nameField.setGroup(playerCard);
    controllerSelector.setGroup(playerCard);   
    
    elements.put("Name", nameField);
    elements.put("Controller", controllerSelector);
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
    boolean aNewControllerWasSelected = false;
    for (Group playerCard : playerCards) {
      int playerCardIndex = playerCards.indexOf(playerCard);
      
      ControllerSelector controllerSelector = (ControllerSelector) playerCardElements.get(playerCardIndex).get("Controller");
      TypableTextField nameField = (TypableTextField) playerCardElements.get(playerCardIndex).get("Name");
      
      controllerSelectors.add(controllerSelector);
      if (controllerSelector.newControllerWasSelected()) aNewControllerWasSelected = true;
      
      if (nameField.changed()) config.players.get(playerCardIndex).name = nameField.getText();
    }
    if (aNewControllerWasSelected) {
      for (ControllerSelector controllerSelector : controllerSelectors) {
        controllerSelector.updateAvailableControllers();
      }
    }
    
    // Start Game
    if (playButton.wasClicked()) switchScene(new MatchScene(config));
  }
  
   @Override
  public void dispose() {
    controlP5.dispose();
    controlP5.setVisible(false);
    controlP5.setAutoDraw(false);
  }
  
}
