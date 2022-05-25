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
  
  SortedArrayList<Viewport> viewports;
  SortedArrayList<UIComponent> uiComponents;
  
  public Scene() {
    PriorityPanelComparator priorityPanelComparator = new PriorityPanelComparator();
    viewports = new SortedArrayList(priorityPanelComparator);
    uiComponents = new SortedArrayList(priorityPanelComparator);
  }

  public void display() {
    for (Viewport viewport : viewports) {
      viewport.display();      
    }
    for (UIComponent uiComponent : uiComponents) {
      uiComponent.display();      
    }
  }
  
  public void dispose() {
    for (Viewport viewport : viewports) {
      viewport.dispose();      
    }
    for (UIComponent uiComponent : uiComponents) {
      uiComponent.dispose();      
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
  
  protected PVector screenCoords;
  public int priority;
  
  
  public Panel(int panelWidth, int panelHeight, PVector screenCoords, int priority, String renderer) {
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
