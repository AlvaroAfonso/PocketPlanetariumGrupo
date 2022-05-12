public PVector rodriguesRotation(PVector vector, PVector rotationAxis, float rotationAngle) {
  PVector rotatedVector = PVector.mult(vector, cos(rotationAngle), null);
  rotatedVector.add(PVector.cross(rotationAxis, vector, null).mult(sin(rotationAngle)));
  rotatedVector.add(PVector.mult(rotationAxis, rotationAxis.dot(vector) * (1 - cos(rotationAngle)), null));
  return rotatedVector;
}


public PVector quaternionRotation(PVector originalVector, PVector rotationAxis, float angle) {
  rotationAxis = PVector.mult(rotationAxis, sin(angle/2), null);
  Rotation quaternionRotor = new Rotation(cos(angle/2), rotationAxis.x, rotationAxis.y, rotationAxis.z, true);
  Vector3D nonNativeRotatedVector = quaternionRotor.applyTo(new Vector3D(originalVector.x, originalVector.y, originalVector.z));
  return toPVector(nonNativeRotatedVector);
}


public Rotation generateQuaternionRotor(PVector rotationAxis, float angle) {
  rotationAxis = PVector.mult(rotationAxis, sin(angle/2), null);
  return new Rotation(cos(angle/2), rotationAxis.x, rotationAxis.y, rotationAxis.z, true);
}


public static PMatrix generateBillboardMatrix(PMatrix currentMatrix) {
  float[] elemns = currentMatrix.get(null);
  PMatrix billboardMatrix = new PMatrix3D();
  for (int i = 0; i < 11; i++) {
    if (i % 4 == 3) continue;
    elemns[i] = 0.0;
  }
  for (int i = 0; i < 3; i++) {
    elemns[i * 4 + i] = 1.0;
  }
  billboardMatrix.set(elemns);
  return billboardMatrix;
}

public float distanceBetween(PVector pointA, PVector pointB) {
  return sqrt(pow(pointA.x - pointB.x, 2) + pow(pointA.y - pointB.y, 2) + pow(pointA.z - pointB.z, 2));
}


public float innerProduct(PVector a, PVector b) {
    return  acos( a.dot(b) / (a.mag() * b.mag()) );
}


public PVector toPVector(Vector3D target) {
  return new PVector( (float) target.getX(), (float) target.getY(), (float) target.getZ());
}

public Vector3D toVector3D(PVector target) {
  return new Vector3D(target.x, target.y, target.z);
}
