
class WorldRender {
  
  private final WorldData worldData;
  private final PGraphics canvas;
  private final HashMap<String, PShape> astronomicalBodyMeshes;
    
  public WorldRender(PGraphics canvas, WorldData worldData){
    this.canvas = canvas;
    this.worldData = worldData;
    this.astronomicalBodyMeshes = new HashMap();
    
    generateAstronomicalBodyMesh(worldData.sun, "./data/images/Sun.jpg");
    
    for (AstronomicalBody planet : worldData.sun.orbitatingBodies) {
      generateAstronomicalBodyMesh(planet, "./data/images/Low-Res Planets/" + planet.name + ".jpg");
      for (AstronomicalBody moon : planet.orbitatingBodies) {
       // generateAstronomicalBodyMesh(moon, "./data/images/Moons/" + moon.name + ".jpg");
        generateAstronomicalBodyMesh(moon, null);
      }
    }
  }
  
  private void generateAstronomicalBodyMesh(AstronomicalBody body, String texturePath) {
    PShape mesh = canvas.createShape(SPHERE, body.radius);
    if (texturePath != null) {
      PImage texture = loadImage(texturePath);
      mesh.setTexture(texture);
    }
    astronomicalBodyMeshes.put(body.name, mesh);
  }
  
  private void displayAstronomicalBody(AstronomicalBody body) {
    // --------------------------- Inclinación de orbita
    canvas.rotateZ(radians(-body.orbitalInclination));
    // -------------------------------- Posición angular
    canvas.rotateY(body.currentOrbitalAngle);      
    
    canvas.pushMatrix();
      // ----------------------------- Distancia al centro
      canvas.translate(body.distanceToCentralBody,0,0);
  
      // OrbitatingBodies
      for (AstronomicalBody orbitatingBody : body.orbitatingBodies) {
        displayAstronomicalBody(orbitatingBody);
      }
      
      // ------------------------------- Inclinación axial
      canvas.rotateZ(radians(body.axialTilt));      
   
      // ---------------------------------------- Rotacion
      //model.rotateY(TWO_PI / (rotationPeriod * earthOrbitalPeriod)); 
      canvas.rotateY(body.currentRotationAngle);
       
      
      // ----------------------------------------- Display
      canvas.shape(astronomicalBodyMeshes.get(body.name));
        
    canvas.popMatrix();
    
    // -------------------------------- Posición angular
    canvas.rotateY(-body.currentOrbitalAngle);  
    
    // --------------------------- Inclinación de orbita
    canvas.rotateZ(radians(body.orbitalInclination));
  } 
  
  private void displayAstronomicalBodyData(AstronomicalBody body) {
    // --------------------------- Inclinación de orbita
    canvas.rotateZ(radians(-body.orbitalInclination));
    
    // --------------------------- Orbit Display
    if (body.eccentricity > 0.0) {
      canvas.pushMatrix();
        canvas.translate(body.linear_eccentricity, 0, 0);
        canvas.pushMatrix();
          //rotateY(PI/2.0);
          canvas.rotateX(PI/2.0);
          canvas.stroke(255);
          canvas.noFill();
          canvas.ellipse(0, 0, 2 * (body.semi_major_axis + body.centralBodyRadius + body.radius), 2 * (body.semi_minor_axis + body.centralBodyRadius + body.radius));
          canvas.noStroke();
        canvas.popMatrix();
      canvas.popMatrix();
    }
    
    // -------------------------------- Posición angular
    canvas.rotateY(body.currentOrbitalAngle);      
    
    canvas.pushMatrix();
      // ----------------------------- Distancia al centro
      canvas.translate(body.distanceToCentralBody,0,0);
  
      // OrbitatingBodies
      for (AstronomicalBody orbitatingBody : body.orbitatingBodies) {
        displayAstronomicalBodyData(orbitatingBody);
      }
      
      // ------------------------------- Inclinación axial
      canvas.rotateZ(radians(body.axialTilt));
      
      // ------------------------------- Name Display
      canvas.pushMatrix();
        PMatrix billboardMatrix = generateBillboardMatrix(getMatrix());
        canvas.resetMatrix();
        canvas.applyMatrix(billboardMatrix);
        //translate(radius > 200 ? -900 : -400, -2 * radius, 0);
        canvas.translate(-min(body.radius, 0.75), -1.2*body.radius);
        canvas.fill(color(255, 255, 255));
        //textSize(radius > 200 ? 900 : 400);
        canvas.textSize(2 * min(body.radius, 0.7));
        canvas.text(body.name, 0, 0);
      canvas.popMatrix();

    canvas.popMatrix();
    
    // -------------------------------- Posición angular
    canvas.rotateY(-body.currentOrbitalAngle);  
    
    // --------------------------- Inclinación de orbita
    canvas.rotateZ(radians(body.orbitalInclination));    
  }
  
  public void display(boolean displayData) {
    canvas.pushMatrix();
      canvas.translate (width/2, height/2, 0);
      //activateLights(canvas);
      displayAstronomicalBody(worldData.sun);
      if (displayData) {
        canvas.noLights();
        //displayAstronomicalBodyData(worldData.sun);
      }
    canvas.popMatrix();
  }
  
  void activateLights(PGraphics canvas) {
    canvas.pointLight(255, 255, 255, 0, 0, 0); 
    canvas.lightFalloff(lightFall.x, lightFall.y, lightFall.z);
    canvas.ambientLight(255, 255, 255, 0, 0, 0);
  }
  
}
