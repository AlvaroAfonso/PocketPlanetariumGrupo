

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
    model = createShape(SPHERE, this.radius);
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
    this.orbitalInclination = orbitalInclination;
    this.orbitalPeriod = orbitalPeriod;
    this.currentOrbitalAngle = random(-TWO_PI,TWO_PI);
    model = createShape(SPHERE, this.radius);
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
  
  void display() { 
    
    rotateAxial();
    orbitate();
    
    /*
    if(this.name.equals("Earth")) {
      print("Displaying " + this.name);
      println("\n\tCurrent Rotation Period: " + rotationPeriod * earthOrbitalPeriod + " s"
              + "\n\tCurrent Rotation Angular Speed: " + TWO_PI / (rotationPeriod * earthOrbitalPeriod) + " rad/s"
              + "\n\tCurrent Orbital Angular Speed: " + currentAngularSpeed + " rad/s"
              + "\n\tExpected Orbit time: " + TWO_PI / currentAngularSpeed/60 + " min"
              + "\n\tTime since last draw: " + timeSinceLastStep + " s"
              );
    } 
    */
            
    // --------------------------- Inclinación de orbita
    rotateZ(radians(-orbitalInclination));
    
     // -------------------------------- Posición angular
    rotateY(currentOrbitalAngle);      
    
    pushMatrix();
      // ----------------------------- Distancia al centro
      translate(distanceToCentralBody,0,0);
  
      // OrbitatingBodies
      for (AstronomicalBody orbitatingBody : orbitatingBodies) {
        orbitatingBody.display();
      }
      
      // ------------------------------- Inclinación axial
      rotateZ(radians(axialTilt));
   
      // ---------------------------------------- Rotacion
      //model.rotateY(TWO_PI / (rotationPeriod * earthOrbitalPeriod)); 
      rotateY(currentRotationAngle);
       
      
      // ----------------------------------------- Display
      shape(model);
        
    popMatrix();
    
    // -------------------------------- Posición angular
    rotateY(-currentOrbitalAngle);  
    
    // --------------------------- Inclinación de orbita
    rotateZ(radians(orbitalInclination));
  }
  
  
  void displayData() {    
    // --------------------------- Inclinación de orbita
    rotateZ(radians(-orbitalInclination));
    
    // --------------------------- Orbit Display
    if (eccentricity > 0.0) {
      pushMatrix();
        float a = semi_major_axis + centralBodyRadius + this.radius;
        float b = sqrt(-pow(semi_major_axis, 2) * (pow(eccentricity, 2) - 1)) + centralBodyRadius + this.radius;
        //translate(-sqrt(pow(a, 2) - pow(b, 2)), 0, 0);
        //translate(-eccentricity*a, 0, 0);
            
        pushMatrix();
          //rotateY(PI/2.0);
          rotateX(PI/2.0);
          stroke(255);
          noFill();
          ellipse(0, 0, 2 * a, 2 * b );
          noStroke();
        popMatrix();
      popMatrix();
    }
    
    // -------------------------------- Posición angular
    rotateY(currentOrbitalAngle);      
    
    pushMatrix();
      // ----------------------------- Distancia al centro
      translate(distanceToCentralBody,0,0);
  
      // OrbitatingBodies
      for (AstronomicalBody orbitatingBody : orbitatingBodies) {
        orbitatingBody.displayData();
      }
      
      // ------------------------------- Inclinación axial
      rotateZ(radians(axialTilt));
      
      // ------------------------------- Name Display
      pushMatrix();
        PMatrix billboardMatrix = generateBillboardMatrix(getMatrix());
        resetMatrix();
        applyMatrix(billboardMatrix);
        translate(radius > 200 ? -900 : -400, -2 * radius, 0);
        fill(color(255, 255, 255));
        textSize(radius > 200 ? 900 : 400);
        text(name, 0, 0);
      popMatrix();

    popMatrix();
    
    // -------------------------------- Posición angular
    rotateY(-currentOrbitalAngle);  
    
    // --------------------------- Inclinación de orbita
    rotateZ(radians(orbitalInclination));  
  }
  
  String toString() {
    String bodystring = name + "\n";
    for  (AstronomicalBody orbitatingBody : orbitatingBodies) {
      bodystring += "\t" + orbitatingBody.name + "\n";
    }
    return bodystring;
  }
}
