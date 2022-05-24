/*/*
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
---------------------------------*/


/*-------------------------------- 
2. SCENE
--------------------------------*/
class MainMenu extends Scene {

  public MainMenu() {
    viewports.add(new MenuBackground());
  }
  
}

/*--------------------------------  
3. VIEWPORT
--------------------------------*/
class MenuBackground extends Viewport {
  
  WorldModel gameWorld;
  
  public MenuBackground() {
    super(width, height, new PVector(0,0), Panel.DEFAULT_PRIORITY);
    this.gameWorld = new WorldModel(canvas, solarSystemData);
  }

   @Override
   protected void renderContent() {
     gameWorld.display(true);
   }
}


/*-------------------------------- 
3.1. VIEWPORT UI COMPONENTS
--------------------------------*/


/*--------------------------------  
4. UI COMPONENTS
--------------------------------*/


/*--------------------------------  
5. CONTROLS
--------------------------------*/
