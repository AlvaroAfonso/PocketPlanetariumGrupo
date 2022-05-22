
public abstract class  Scene {
  
  TreeSet<Viewport> viewports;
  TreeSet<UIComponent> uiComponents;
  
  public Scene() {
    viewports = new TreeSet();
    uiComponents = new TreeSet();
  }
  
  /*
  public Scene() {
    panels = new TreeSet(new Comparator<Panel>() {
      @Override
      public int compare(Panel paneA, Panel paneB) {
        if (paneA.priority > paneB.priority) return 1;
        if (paneA.priority < paneB.priority) return -1;
        return 0;
      }
    });
  }
  */

  public void display() {
    for (Viewport viewport : viewports) {
      viewport.display();      
    }
    for (UIComponent uiComponent : uiComponents) {
      uiComponent.display();      
    }
  }
  
}


public abstract class Panel implements Comparable<Panel> {
  
  public final static int DEFAULT_PRIORITY = 0;
  
  protected PApplet parent;
  protected PGraphics canvas; 
  
  protected PVector screenCoords;
  public int priority;
  
  
  public Panel(PApplet parent, int panelWidth, int panelHeight, PVector screenCoords, int priority, String renderer) {
    this.parent = parent;
    this.canvas = createGraphics(panelWidth, panelHeight, renderer);
    this.screenCoords = screenCoords;
    this.priority = priority;
  }
  
  @Override
  public int compareTo(Panel otherPanel) { 
    if (this.priority > otherPanel.priority) return 1;
    if (this.priority < otherPanel.priority) return -1;
    return 0;
  }
  
  public void display() {
    canvas.beginDraw();
    renderContent();
    canvas.endDraw();
    image(canvas, screenCoords.x, screenCoords.y);
  }
  
  protected abstract void renderContent();
  
}


public abstract class UIComponent extends Panel {

  public UIComponent(PApplet parent, int componentWidth, int componentHeight, PVector screenCoords, int priority) {
    super(parent, componentWidth, componentHeight, screenCoords, priority, P2D);  
  }
  
}

public abstract class Viewport extends Panel {
  
  TreeSet<UIComponent> uiComponents;
  
  public Viewport(PApplet parent, int viewportWidth, int viewportHeight, PVector screenCoords, int priority) {
    super(parent, viewportWidth, viewportHeight, screenCoords, priority, P3D);  
    uiComponents = new TreeSet();
  }
  
  @Override
  protected void renderContent() {
    renderGraphics();
    for (UIComponent uiComponent : uiComponents) {
      uiComponent.display();      
    }
  }
  
  protected abstract void renderGraphics();
}
