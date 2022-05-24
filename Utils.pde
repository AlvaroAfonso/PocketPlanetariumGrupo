/*
*  -Index-
*    1. VECTOR ALGEBRA
*    2. QUATERNIONS & ROTATIONS
*    3. BILLBOARDING
*    4. SORTED ARRAY LIST
*/


/*-------------------------------- 
1. VECTOR ALGEBRA
--------------------------------*/
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


/*-------------------------------- 
2. QUATERNIONS & ROTATIONS
--------------------------------*/
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


/*-------------------------------- 
3. BILLBOARDING
--------------------------------*/
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


/*-------------------------------- 
4. SORTED ARRAY LIST
--------------------------------*/
public class SortedArrayList<T> implements List<T> {
  
  private List<T> innerList;
  private Comparator<T> comparator;
  
  public SortedArrayList(Comparator<T> comparator) {
    innerList = new ArrayList();
    this.comparator = comparator;
  }
  
  public void sort() {
    Collections.sort(innerList, comparator);
  }
  
  @Override
  public boolean add(T item) {
    boolean result = innerList.add(item);
    this.sort();
    return result;
  }
  
  @Override
  public void add(int index, T item) {
    throw new UnsupportedOperationException();
  }
  
  @Override
  public boolean addAll(Collection<? extends T> items) {
    for (T item : items) {
      add(item);
    }
    return true;
  }
  
  @Override
  public boolean addAll(int index, Collection<? extends T> items) {
    throw new UnsupportedOperationException();
  }
  
  @Override
  public T remove(int index) {
    T result = innerList.remove(index);
    this.sort();
    return result;
  }
  
  @Override
  public boolean remove(Object obj) {
    boolean result = innerList.remove(obj);
    this.sort();
    return result;
  }
  
  @Override
  public boolean removeAll(Collection<?> items) {
    boolean result = innerList.removeAll(items);
    this.sort();
    return result;
  }
  
  @Override
  public T set(int index, T item) {
    throw new UnsupportedOperationException();
  }
  
  @Override
  public boolean contains(Object obj) {
    return innerList.contains(obj);
  }
  
   @Override
  public boolean containsAll(Collection<?> items) {
    return innerList.containsAll(items);
  }
  
  @Override
  public int size() {
    return innerList.size();
  }
  
  @Override
  public boolean isEmpty() {
    return innerList.isEmpty();
  }
  
  @Override
  public int indexOf(Object obj) {
    return innerList.indexOf(obj);
  }
  
  @Override
  public int lastIndexOf(Object obj) {
    return innerList.lastIndexOf(obj);
  }
  
  @Override
  public T get(int index) {
    return innerList.get(index);
  }
  
  @Override
  public List<T> subList(int fromIndex, int toIndex) {
    return innerList.subList(fromIndex, toIndex);
  }
  
  @Override
  public boolean retainAll(Collection<?> items) {
    return innerList.retainAll(items);
  }
  
  @Override
  public void clear() {
    innerList.clear();
  }
  
  @Override
  public Object[] toArray() {
    return innerList.toArray();
  }
  
  @Override
  public <T> T[] toArray(T[] targetContainer) {
    return innerList.toArray(targetContainer);
  }
  
  @Override
  public Iterator<T> iterator() {
    return innerList.iterator();
  }
  
  @Override
  public ListIterator<T> listIterator() {
    return innerList.listIterator();
  }
  
  @Override
  public ListIterator<T> listIterator(int index) {
    return innerList.listIterator(index);
  }

}
