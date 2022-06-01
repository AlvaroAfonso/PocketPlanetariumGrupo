/*
*  -Index-
*    1. SCENE
*    2. PANEL
*    3. UI COMPONENT
*    4. VIEWPORT
*/


/*-------------------------------- 
1. SCENE
--------------------------------*/
public abstract class  Scene {
  
  SortedArrayList<Panel> panels;
  
  public Scene() {
    PriorityPanelComparator priorityPanelComparator = new PriorityPanelComparator();
    panels = new SortedArrayList(priorityPanelComparator);
  }

  public void display() {
    for (Panel panel : panels) {
      panel.display();      
    }
  }
  
  public void dispose() {
    for (Panel panel : panels) {
      panel.dispose();      
    }
  }
  
}


/*-------------------------------- 
2. PANEL
--------------------------------*/
public class PriorityPanelComparator implements Comparator<Panel> {
  @Override
  public int compare(Panel panelA, Panel panelB) { 
    if (panelA.priority > panelB.priority) return 1;
    if (panelA.priority < panelB.priority) return -1;
    return 0;
  }
}

public abstract class Panel {
  
  public final static int DEFAULT_PRIORITY = 0;
  
  protected PGraphics canvas; 
  protected String renderer;
  
  protected PVector screenCoords;
  public int priority;
  
  
  public Panel(int panelWidth, int panelHeight, PVector screenCoords, int priority, String renderer) {
    this.renderer = renderer;
    this.canvas = createGraphics(panelWidth, panelHeight, renderer);
    this.screenCoords = screenCoords;
    this.priority = priority;
  }
  
  public void display() {
    canvas.beginDraw();
    renderContent();
    canvas.endDraw();
    image(canvas, screenCoords.x, screenCoords.y);
  }
  
  public void resize(int newWidth, int newHeight) {
    this.canvas = createGraphics(newWidth, newHeight, renderer);
  }
  
  public abstract void dispose();
  
  protected abstract void renderContent();
  
}


/*-------------------------------- 
3. UI COMPONENT
--------------------------------*/
public abstract class UIComponent extends Panel {
  
  private boolean isDisabled;

  public UIComponent(int componentWidth, int componentHeight, PVector screenCoords, int priority) {
    super(componentWidth, componentHeight, screenCoords, priority, P2D);  
    isDisabled = false;
  }
  
}


/*-------------------------------- 
4. VIEWPORT
--------------------------------*/
public abstract class Viewport extends Panel {
   
  public Viewport(int viewportWidth, int viewportHeight, PVector screenCoords, int priority) {
    super(viewportWidth, viewportHeight, screenCoords, priority, P3D);  
  }
}
