import controlP5.*;


public final int BG_COLOR = color(2, 48, 71, 100);
public final int PRIMARY_COLOR = color(33, 158, 188, 255);
public final int SECONDARY_COLOR = color(251, 133, 0, 255);
public final int INTERACT_COLOR = color(255, 183, 3, 255);

public final int PRIMARY_FONT_COLOR = color(255, 255, 255, 255);
public final int SECONDARY_FONT_COLOR = color(0, 0, 0, 255);


public final int TITLE_SIZE = 40;
public final float HEADING_SIZE = 0.5*TITLE_SIZE;
public final float BODY_SIZE = 0.3*TITLE_SIZE;
public final float CALL_TO_ACTION_SIZE = 0.4*TITLE_SIZE;

public PFont TITLE_FONT;
public PFont HEADING_FONT;
public PFont BODY_FONT;
public PFont CALL_TO_ACTION_FONT;


public void loadFonts() {
  TITLE_FONT = createFont("Arial Bold", TITLE_SIZE, true);
  HEADING_FONT = createFont("Arial Bold", HEADING_SIZE, true);
  BODY_FONT = createFont("Arial Bold", HEADING_SIZE, true);
  CALL_TO_ACTION_FONT = createFont("Arial Bold", CALL_TO_ACTION_SIZE, true);
}



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
  
  public ClickableButton(ControlP5 controlP5, String name) {
    super(controlP5, name);
    this.addCallback(handler);
    isClicked = false;
  }
  
  public void click() {
    this.isClicked = true;
  }
  
  public boolean wasClicked() {
    if (isClicked) {
      isClicked = false;
      return true;
    }
    return false;
  }
  
}

class DraggableSlider extends Slider {
  
  private class DraggableSliderHandler implements CallbackListener {
    
    private DraggableSlider slider;
    
    public DraggableSliderHandler(DraggableSlider slider) {
      this.slider = slider;
    }
    
    public void controlEvent(CallbackEvent event) {
      if (event.getAction() == ControlP5.ACTION_DRAG) slider.valueChanged = true;
    }
  }
  
  private CallbackListener handler = new DraggableSliderHandler(this); 
  private boolean valueChanged;

  public DraggableSlider(ControlP5 controlP5, String name, int sliderWidth, int sliderHeight, PVector position, int rangeMin, int rangeMax, int ticks) {
    super(controlP5, name);  
    valueChanged = false;
    
    this.setSize(sliderWidth, sliderHeight);
    this.setPosition(position.x, position.y);
    this.setRange(rangeMin, rangeMax);
    this.setNumberOfTickMarks(ticks);
    this.snapToTickMarks(true);
    this.showTickMarks(false);
    this.setSliderMode(Slider.FIX);
    
    this.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE);
    this.getCaptionLabel().setFont(HEADING_FONT);
    
    this.setDecimalPrecision(0);
    this.getValueLabel().align(ControlP5.CENTER, ControlP5.CENTER);
    this.getValueLabel().setFont(BODY_FONT);
    
    this.setColorBackground(PRIMARY_COLOR);
    this.setColorForeground(SECONDARY_COLOR);
    this.setColorActive(INTERACT_COLOR);
    
    this.addCallback(handler);
  }  
  
  public boolean changed() {
    if (valueChanged) {
      valueChanged = false;
      return true;
    }
    return false;
  }
  
}

class TypableTextField extends Textfield {
  
  private class TypableTextFieldHandler implements CallbackListener {
    
    private TypableTextField textfield;
    
    public TypableTextFieldHandler(TypableTextField textfield) {
      this.textfield = textfield;
    }
    
    public void controlEvent(CallbackEvent event) {
      if (event.getAction() == ControlP5.ACTION_PRESS || event.getAction() == ControlP5.ACTION_RELEASE) textfield.valueChanged = true;
    }
  }
  
  private CallbackListener handler = new TypableTextFieldHandler(this); 
  private boolean valueChanged;
  
  public TypableTextField(ControlP5 controlP5, String name, int fieldWidth, int fieldHeight, PVector position) {
    super(controlP5, name);  
    this.setSize(fieldWidth, fieldHeight);
    this.setPosition(position.x, position.y);
    
    this.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE);
    this.getCaptionLabel().setFont(HEADING_FONT);
    
    //this.setColor(PRIMARY_COLOR);
    this.setColorBackground(PRIMARY_COLOR);
    this.setColorForeground(SECONDARY_COLOR);
    this.setColorActive(INTERACT_COLOR);
    
    this.setFont(BODY_FONT);
    
    this.setAutoClear(false);
    this.addCallback(handler);
  }
  
  public boolean changed() {
    if (valueChanged) {
      valueChanged = false;
      return true;
    }
    return false;
  }
  
}

class ControllerSelector extends ScrollableList {
  
  private class ControllerSelectorHandler implements CallbackListener {
    
    private ControllerSelector selector;
    
    public ControllerSelectorHandler(ControllerSelector selector) {
      this.selector = selector;
    }
    
    public void controlEvent(CallbackEvent event) {
      
      println("event from controller : "+event.getController().getValue()+" from "+event.getController());
      /*
      if (event.getAction() == ControlP5.ACTION_PRESS) {
        controllerRepository.free(selectedController);
        controllerRepository.fetchController(playerID, selectedController);
        selector.setCaptionLabel(selectedController);
        selector.setItems(controllerRepository.getAvailableControllerNames());
      }
      */
    }
  }
  
  private CallbackListener handler = new ControllerSelectorHandler(this); 
  private int playerID;
  private String selectedController;
  
  public ControllerSelector(ControlP5 controlP5, String name, int selectorWidth, PVector position, int playerID, String selectedController) {
    super(controlP5, name);
    this.setPosition(position.x, position.y);
    
    this.setColorBackground(PRIMARY_COLOR);
    this.setColorForeground(SECONDARY_COLOR);
    this.setColorActive(INTERACT_COLOR);
    this.setFont(BODY_FONT);
    
    this.playerID = playerID;
    this.selectedController = selectedController;
    
    this.setCaptionLabel(selectedController);
    this.setItems(controllerRepository.getAvailableControllerNames());
    
    this.setSize(selectorWidth, this.getItems().size() * 35);
    this.setBarHeight(35);
    this.setItemHeight(35);
    
    this.setOpen(false);
  }
  
}
