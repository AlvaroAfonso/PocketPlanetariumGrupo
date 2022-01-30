public float astronomicalUnit = 1.4959878707E+8 / DISTANCE_SCALE; // AU in kilometers
public float time_acceleration =  30 * 60 * 24 * SPEED_FACTOR; 
  
  
public final float SOLAR_MASS = 2E30;       // kg
public final float EARTH_MASS = 5.9722E24;  // kg

public float earthRadius = 6378/SIZE_SCALE; // km

public float earthRotationPeriod = 60 * 60 * 24 / time_acceleration;
public float earthOrbitalPeriod =  365 * earthRotationPeriod;

public float GRAVITATIONAL_CONSTANT = 39.478 * pow(astronomicalUnit, 3) /  pow(earthOrbitalPeriod, 2); // AU^3 / (years^2 * SolarMass)

public PVector lightFall = new PVector(-4.799998, 0.5, -1.4901161E-8);


class SolarSystem {
  
  final AstronomicalBody sun = new AstronomicalBody("Sun", 1, 109 * earthRadius, 0, 0.0686301);
  
  SolarSystem(){
    PImage sunTexture = loadImage("./data/images/Sun.jpg");
    sun.model.setTexture(sunTexture);
    loadPlanets();
  }
  
  void loadPlanets() {
    Table planets = loadTable("./data/Planets.csv", "header");
    Table moons = loadTable("./data/Moons.csv", "header");
    for (TableRow planetRow : planets.rows()) {
      AstronomicalBody planet = createAstronomicalBody(planetRow, sun.radius, sun.mass);
      
      //if (!planet.name.equals("Earth")) continue;
      
      PImage planetTexture = loadImage("./data/images/Low-Res Planets/" + planet.name + ".jpg");
      planet.model.setTexture(planetTexture);
      loadPlanetMoons(moons, planet);
      sun.orbitatingBodies.add(planet);
      
      //if (planet.name.equals("Earth")) break;
    }

  }
  
  void loadPlanetMoons(Table moons, AstronomicalBody planet){
    for (TableRow moonRow : moons.rows()) {
      String moonPlanet = moonRow.getString("Planet");
      if (moonPlanet.compareTo(planet.name) > 0) return; 
      if (moonPlanet.equals(planet.name)) {
        AstronomicalBody moon = createAstronomicalBody(moonRow, planet.radius, planet.mass);
        //PImage moonTexture = loadImage("./data/images/Moons/" + moon.name + ".jpg");
        //moon.model.setTexture(moonTexture);
        planet.orbitatingBodies.add(moon);
      }
    }
  }
  
  AstronomicalBody createAstronomicalBody(TableRow row, float attractorRadius, float attractorMass) {
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
  
  void updateTimeParams() {
    if (speedUp) {
      SPEED_FACTOR = SPEED_FACTOR == 1 ? SPEED_FACTOR + 9 : SPEED_FACTOR + 10;
      if (SPEED_FACTOR > 10000) SPEED_FACTOR = 10000;
    } else if (slowDown) {
      SPEED_FACTOR -= 10;
      if (SPEED_FACTOR < 1) SPEED_FACTOR = 1;
    } else {
      return;
    }
    time_acceleration =  30 * 60 * 24 * SPEED_FACTOR; 
    earthRotationPeriod = 60 * 60 * 24 / time_acceleration; 
    earthOrbitalPeriod =  365 * earthRotationPeriod;
    GRAVITATIONAL_CONSTANT = 39.478 * pow(astronomicalUnit, 3) /  pow(earthOrbitalPeriod, 2); // AU^3 / (years^2 * SolarMass)
  }
  
  void display() {
    updateTimeParams();
    pushMatrix();
    translate (width/2, height/2, 0);
    activateLights();
    sun.display();
    if (showHUD) {
      noLights();
      sun.displayData();
    }
    popMatrix();
  }
  
  void activateLights() {
    pointLight(255, 255, 255, 0, 0, 0); 
    lightFalloff(lightFall.x, lightFall.y, lightFall.z);
    ambientLight(255, 255, 255, 0, 0, 0);
  }
  
}
