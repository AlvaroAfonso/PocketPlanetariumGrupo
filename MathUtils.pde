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


public float innerProduct(PVector a, PVector b) {
    return  acos( a.dot(b) / (a.mag() * b.mag()) );
}


public PVector toPVector(Vector3D target) {
  return new PVector( (float) target.getX(), (float) target.getY(), (float) target.getZ());
}

public Vector3D toVector3D(PVector target) {
  return new Vector3D(target.x, target.y, target.z);
}
