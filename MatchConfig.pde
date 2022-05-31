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
    viewports.add(new MenuBackground());
    uiComponents.add(new ConfigMenu(width, height, new PVector(0,0), Panel.DEFAULT_PRIORITY + 1000));
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
    
    playButton = new ClickableButton(controlP5, "Start!");
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
    config.playerLives = 3;
    config.playerMaxSpeed = 600;
    config.bulletSpeed = 500;
    config.planetOrbitationSpeedUp = 1;
    config.addPlayer(new Player("Player1", controllerRepository.fetchController(0, ControllerID.MAIN_KEYBOARD), new PVector(20, 0, 50)));
    config.addPlayer(new Player("Player2", controllerRepository.fetchController(1, ControllerID.ALT_KEYBOARD), new PVector(-20, 0, 50)));
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
                                   1, 10, 10);   
                                   
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
    
    ControllerSelector controllerSelector = new ControllerSelector(controlP5, "Player " + (cardIndex + 1) + " Controller",
                                              playerCardWidth/2 - 2*innerSectionPadding,
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
    if (playerNum.changed()) {
      // Add/Remove Players & Player Cards
    }
    if (playerLives.changed()) config.playerLives = (int) playerLives.getValue();
    if (playerSpeed.changed()) config.playerMaxSpeed = (int) playerSpeed.getValue();
    if (bulletSpeed.changed()) config.bulletSpeed = (int) bulletSpeed.getValue();
    if (orbitSpeed.changed()) config.planetOrbitationSpeedUp = (int) orbitSpeed.getValue();
    
    
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
    if (playButton.wasClicked()) switchScene(new VersusMatchScene(config));
  }
  
   @Override
  public void dispose() {
    controlP5.dispose();
    controlP5.setVisible(false);
    controlP5.setAutoDraw(false);
  }
  
}
