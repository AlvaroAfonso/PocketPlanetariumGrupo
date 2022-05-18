
abstract class  Scene {
  
  private Viewport[] viewports;

  public void display() {
    for (Viewport view : viewports) {
      view.renderGraphics();      
    }
  }
}

class MenuState extends Scene {
  
}


class MatchConfigState extends Scene {


}

class MatchState extends Scene {

}
