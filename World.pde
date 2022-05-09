public float astronomicalUnit = 1.4959878707E+8 / DISTANCE_SCALE; // AU in kilometers
public float time_acceleration =  30 * 60 * 24 * SPEED_FACTOR; 
  
  
public final float SOLAR_MASS = 2E30;       // kg
public final float EARTH_MASS = 5.9722E24;  // kg

public float earthRadius = 6378/SIZE_SCALE; // km

public float earthRotationPeriod = 60 * 60 * 24 / time_acceleration;
public float earthOrbitalPeriod =  365 * earthRotationPeriod;

public float GRAVITATIONAL_CONSTANT = 39.478 * pow(astronomicalUnit, 3) /  pow(earthOrbitalPeriod, 2); // AU^3 / (years^2 * SolarMass)

public PVector lightFall = new PVector(-4.799998, 0.5, -1.4901161E-8);


class AstronomicalBody {
  
  final String name;
  PShape model;
  
  // P.E. -> Proportional to Earth's
  
  // Physical Characteristics
  final float mass;            // Solar Mass units
  final float radius;          // P.E.
  final float axialTilt;
  final float rotationPeriod;  // P.E.
  
  // Orbital Characteristics
  float centralBodyRadius;
  float centralBodyMass;      // Solar Mass units
  float semi_major_axis;      // P.E.
  float eccentricity;
  float semi_minor_axis;
  float linear_eccentricity;
  float orbitalInclination;
  float orbitalPeriod;        // P.E.
  
  ArrayList<AstronomicalBody> orbitatingBodies;
  
  // Rotation
  float currentRotationAngle = 0; // Radians
  
  // Orbitation
  float distanceToCentralBody;
  float currentOrbitalAngle; // Radians
  float currentAngularSpeed; // Radians/time
  
  AstronomicalBody(String name, float mass, float radius, float axialTilt, float rotationPeriod){
    this.name = name;
    this.mass = mass;
    this.radius = radius * earthRadius;

    this.axialTilt = axialTilt;
    // ---------------------------- Both Orbitation & Rotation periods are expected in Earth years
    this.rotationPeriod = rotationPeriod; 
    orbitatingBodies = new ArrayList();
    
    println("Creating: " + this.name
             + "\n\tMass: " + this.mass
             + "\n\tRadius: " + this.radius
             + "\n\tAxial_tilt: " + this.axialTilt
             + "\n\trotationPeriod: " + this.rotationPeriod
             + "\n\tsemiMajorAxis: " + this.semi_major_axis
             + "\n\teccentricity: " + this.eccentricity
             + "\n\torbitalInclination: " + this.orbitalInclination
             + "\n\torbitalPeriod: " + this.orbitalPeriod);
  }
  
  AstronomicalBody(String name, float mass, float radius, float centralBodyMass, float centralBodyRadius, float axialTilt, float rotationPeriod,
                   float semi_major_axis, float eccentricity, float orbitalInclination, float orbitalPeriod){
    this.name = name;
    this.mass = mass;
    this.radius = radius * earthRadius;
    this.centralBodyMass = centralBodyMass;
    this.centralBodyRadius = centralBodyRadius;
    this.axialTilt = axialTilt;
    // ------------------------ Both Orbitation & Rotation periods are expected in Earth years 
    this.rotationPeriod = rotationPeriod; 
    this.semi_major_axis = semi_major_axis * astronomicalUnit;
    this.eccentricity = eccentricity;
    this.semi_minor_axis = sqrt(-pow(this.semi_major_axis, 2) * (pow(eccentricity, 2) - 1));
    this.linear_eccentricity = sqrt(pow(this.semi_major_axis, 2) - pow(semi_minor_axis, 2));
    this.orbitalInclination = orbitalInclination;
    this.orbitalPeriod = orbitalPeriod;
    this.currentOrbitalAngle = random(-TWO_PI,TWO_PI);
    orbitatingBodies = new ArrayList();
    println("Creating: " + this.name
             + "\n\tAxial_tilt: " + this.axialTilt
             + "\n\tRadius: " + this.radius
             + "\n\trotationPeriod: " + this.rotationPeriod
             + "\n\tsemiMajorAxis: " + this.semi_major_axis
             + "\n\teccentricity: " + this.eccentricity
             + "\n\torbitalInclination: " + this.orbitalInclination
             + "\n\torbitalPeriod: " + this.orbitalPeriod);
  }
  
  void rotateAxial() {
    currentRotationAngle +=   (TWO_PI / (rotationPeriod * earthOrbitalPeriod)) * timeSinceLastStep;
    if (currentRotationAngle > TWO_PI || currentRotationAngle < -TWO_PI) currentRotationAngle = 0;
  }
  
  void orbitate() {
      if (orbitalPeriod == 0) return;
      distanceToCentralBody = semi_major_axis * (1 - pow(eccentricity,2)) / (1 + eccentricity * cos(PI - currentOrbitalAngle));
      distanceToCentralBody += centralBodyRadius + this.radius;
      currentAngularSpeed =  sqrt(GRAVITATIONAL_CONSTANT * centralBodyMass / pow(distanceToCentralBody - centralBodyRadius - this.radius, 3));
      currentOrbitalAngle += currentAngularSpeed * timeSinceLastStep;
      if (currentOrbitalAngle > TWO_PI || currentOrbitalAngle < -TWO_PI) currentOrbitalAngle = 0;
  }
  
  void update() {
    rotateAxial();
    orbitate();
    for (AstronomicalBody orbitatingBody : orbitatingBodies) {
      orbitatingBody.update();
    }
  }
  
  String toString() {
    String bodystring = name + "\n";
    for  (AstronomicalBody orbitatingBody : orbitatingBodies) {
      bodystring += "\t" + orbitatingBody.name + "\n";
    }
    return bodystring;
  }
}



class World {
  
  final AstronomicalBody sun = new AstronomicalBody("Sun", 1, 109 * earthRadius, 0, 0.0686301);
  
  public World() {
    Table planets = loadTable("./data/Planets.csv", "header");
    Table moons = loadTable("./data/Moons.csv", "header");
    for (TableRow planetRow : planets.rows()) {
      AstronomicalBody planet = createAstronomicalBody(planetRow, sun.radius, sun.mass);
      //if (!planet.name.equals("Earth")) continue;     
      loadPlanetMoons(moons, planet);
      sun.orbitatingBodies.add(planet);      
      //if (planet.name.equals("Earth")) break;
    }
  }
  
  public void speedUpTime() {
    SPEED_FACTOR = SPEED_FACTOR == 1 ? SPEED_FACTOR + 9 : SPEED_FACTOR + 10;
    if (SPEED_FACTOR > 10000) SPEED_FACTOR = 10000;
    updateTimeParams();
  }
  
  public void slowDownTime() {
    SPEED_FACTOR -= 10;
    if (SPEED_FACTOR < 1) SPEED_FACTOR = 1;
    updateTimeParams();
  }
  
  public void update() {
    sun.update();
  }
  
  private void loadPlanetMoons(Table moons, AstronomicalBody planet){
    for (TableRow moonRow : moons.rows()) {
      String moonPlanet = moonRow.getString("Planet");
      if (moonPlanet.compareTo(planet.name) > 0) return; 
      if (moonPlanet.equals(planet.name)) {
        AstronomicalBody moon = createAstronomicalBody(moonRow, planet.radius, planet.mass);
        planet.orbitatingBodies.add(moon);
      }
    }
  }
  
  private AstronomicalBody createAstronomicalBody(TableRow row, float attractorRadius, float attractorMass) {
    String name = row.getString("Name");
    float mass = row.getFloat("Mass") * EARTH_MASS / SOLAR_MASS; // Expected in SOLAR MASS units
    float radius = row.getFloat("Radius");
    float axialTilt = row.getFloat("Axial_tilt");
    float rotationPeriod = row.getFloat("Rotation_period");
    float semiMajorAxis = row.getFloat("Semi_major_axis");
    float eccentricity = row.getFloat("Eccentricity");
    float orbitalInclination = row.getFloat("Orbital_inclination");
    float orbitalPeriod = row.getFloat("Orbital_period");
    return new AstronomicalBody(name, mass, radius, attractorMass, attractorRadius, axialTilt, rotationPeriod, semiMajorAxis, eccentricity, orbitalInclination, orbitalPeriod);
  }
  
  private void updateTimeParams() {
    time_acceleration =  30 * 60 * 24 * SPEED_FACTOR; 
    earthRotationPeriod = 60 * 60 * 24 / time_acceleration; 
    earthOrbitalPeriod =  365 * earthRotationPeriod;
    GRAVITATIONAL_CONSTANT = 39.478 * pow(astronomicalUnit, 3) /  pow(earthOrbitalPeriod, 2); // AU^3 / (years^2 * SolarMass)
  }
}


class WorldModel {
  
  private final World worldData;
  private final PGraphics canvas;
  private final HashMap<String, PShape> astronomicalBodyMeshes;
    
  public WorldModel(PGraphics canvas, World worldData){
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
  
  public void display(boolean displayData) {
    canvas.pushMatrix();
      canvas.translate (width/2, height/2, 0);
      canvas.pointLight(255, 255, 255, 0, 0, 0);
      displayAstronomicalBody(worldData.sun);
      if (displayData) {
        //canvas.noLights();
        //displayAstronomicalBodyData(worldData.sun);
      }
    canvas.popMatrix();
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
       
      if (body.name == "Sun") {
        canvas.pushStyle();
          canvas.noLights();
          canvas.shape(astronomicalBodyMeshes.get(body.name));
        canvas.popStyle();
      } else {
        // ----------------------------------------- Display
        canvas.shape(astronomicalBodyMeshes.get(body.name));
      }
        
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
  
}
