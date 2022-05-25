
interface Collisionable {
  
  CollisionMesh getCollisionMesh();
  
}

interface CollisionMesh {}


class HitBox implements CollisionMesh {
  
  PVector position;
  float boxWidth;
  float boxHeight;
  float boxDepth;
  
  public HitBox(float size, PVector position) {
    boxWidth = size;
    boxHeight = size;
    boxDepth = size;
    this.position = position;
  }
  
  public HitBox(float boxWidth, float boxHeight, float boxDepth, PVector position) {
    this.boxWidth = boxWidth;
    this.boxHeight = boxHeight;
    this.boxDepth = boxDepth;
    this.position = position;
  }
  
  public HitBox(PShape model, PVector position) {
    HashMap<String,Float> modelBounds = new HashMap();
    modelBounds.put("xMin", MAX_FLOAT);
    modelBounds.put("xMax", MIN_FLOAT);
    modelBounds.put("yMin", MAX_FLOAT);
    modelBounds.put("yMax", MIN_FLOAT);
    modelBounds.put("zMin", MAX_FLOAT);
    modelBounds.put("zMax", MIN_FLOAT);
    getMeshBounds(model, modelBounds);
    boxWidth = modelBounds.get("xMax") - modelBounds.get("xMin");
    boxHeight = modelBounds.get("yMax") - modelBounds.get("yMin");
    boxDepth = modelBounds.get("zMax") - modelBounds.get("zMin");
    this.position = position;
  }
  
  public HitBox(PImage sprite, float scale, PVector position) {
    boxWidth = 0.8 * sprite.width * scale;
    boxHeight = 0.8 * sprite.height * scale;
    boxDepth = 0.2 * sprite.height * scale;
    this.position = position;
  }
  
  public void getMeshBounds(PShape mesh, HashMap<String,Float> boundContainer) {
    if (mesh.getChildCount() > 0) {
      for (PShape child : mesh.getChildren()) {
        getMeshBounds(child, boundContainer);
      }
    }
    PVector vertex;
    for (int i = 0; i < mesh.getVertexCount(); i++) {
      vertex = mesh.getVertex(i);
      if (vertex.x < boundContainer.get("xMin")) {
        boundContainer.put("xMin", vertex.x);
      } 
      if (vertex.x > boundContainer.get("xMax")) {
        boundContainer.put("xMax", vertex.x);
      }
      if (vertex.y < boundContainer.get("yMin")) {
        boundContainer.put("yMin", vertex.y);
      } 
      if (vertex.y > boundContainer.get("yMax")) {
        boundContainer.put("yMax", vertex.y);
      }
      if (vertex.z < boundContainer.get("zMin")) {
        boundContainer.put("zMin", vertex.z);
      }
      if (vertex.z > boundContainer.get("zMax")) {
        boundContainer.put("zMax", vertex.z);
      }
    }
  }
  
  public boolean isCollidingWith(Collisionable body) {
    CollisionMesh collisionMesh = body.getCollisionMesh();
    if (collisionMesh.getClass() == HitBox.class) return isCollidingWith((HitBox) collisionMesh);
    else return isCollidingWith((HitSphere) collisionMesh);
  }
  
  public boolean isCollidingWith(HitBox a) {
    return (a.position.x - a.boxWidth/2 <= this.position.x + this.boxWidth/2 && a.position.x + a.boxWidth/2 >= this.position.x - this.boxWidth/2) &&
           (a.position.y - a.boxHeight/2 <= this.position.y + this.boxHeight/2 && a.position.y + a.boxHeight/2 >= this.position.y - this.boxHeight/2) &&
           (a.position.z - a.boxDepth/2 <= this.position.z + this.boxDepth/2 && a.position.z + a.boxDepth/2 >= this.position.z - this.boxDepth/2);
  }
  
  public boolean isCollidingWith(HitSphere a) {
    return (a.position.x - a.radius <= this.position.x + this.boxWidth/2 && a.position.x + a.radius >= this.position.x - this.boxWidth/2) &&
           (a.position.y - a.radius <= this.position.y + this.boxHeight/2 && a.position.y + a.radius >= this.position.y - this.boxHeight/2) &&
           (a.position.z - a.radius <= this.position.z + this.boxDepth/2 && a.position.z + a.radius >= this.position.z - this.boxDepth/2);
  }

}

class HitSphere implements CollisionMesh {
  
  PVector position;
  float radius;
  
  public HitSphere(float radius, PVector position) {
   this.radius = radius;
   this.position = position;
  }
  
}
