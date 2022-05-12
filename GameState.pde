
interface GameState {
  public void run();
}

class MenuState implements GameState {
  
  Viewport[] viewports;

  public void run() {
    for (Viewport view : viewports) {
      view.renderGraphics();      
    }
  }

}


class MatchConfigState implements GameState {

  public void run() {
  
  }

}

class MatchState implements GameState {

  public void run() {
  
  }

}
