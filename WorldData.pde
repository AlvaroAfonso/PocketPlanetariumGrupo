public float astronomicalUnit = 1.4959878707E+8 / DISTANCE_SCALE; // AU in kilometers
public float time_acceleration =  30 * 60 * 24 * SPEED_FACTOR; 
  
  
public final float SOLAR_MASS = 2E30;       // kg
public final float EARTH_MASS = 5.9722E24;  // kg

public float earthRadius = 6378/SIZE_SCALE; // km

public float earthRotationPeriod = 60 * 60 * 24 / time_acceleration;
public float earthOrbitalPeriod =  365 * earthRotationPeriod;

public float GRAVITATIONAL_CONSTANT = 39.478 * pow(astronomicalUnit, 3) /  pow(earthOrbitalPeriod, 2); // AU^3 / (years^2 * SolarMass)

public PVector lightFall = new PVector(-4.799998, 0.5, -1.4901161E-8);



class WorldData {
  
  final AstronomicalBody sun = new AstronomicalBody("Sun", 1, 109 * earthRadius, 0, 0.0686301);
  
  public WorldData() {
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
  
  void loadPlanetMoons(Table moons, AstronomicalBody planet){
    for (TableRow moonRow : moons.rows()) {
      String moonPlanet = moonRow.getString("Planet");
      if (moonPlanet.compareTo(planet.name) > 0) return; 
      if (moonPlanet.equals(planet.name)) {
        AstronomicalBody moon = createAstronomicalBody(moonRow, planet.radius, planet.mass);
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
  
  void update() {
    updateTimeParams();
    sun.update();
  }

}



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
