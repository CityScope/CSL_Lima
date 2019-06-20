/**
 * Lane - Lane is the connection bewtween two nodes in roadmap graph, and implements all possibilities for agents to move in them
 * @author        Marc Vilella & Javier Zárate
 * @credits       Aaron Steed http://www.robotacid.com/PBeta/AILibrary/Pathfinder/index.html
 * @version       2.1
 * @see           Node
 */
private class Lane {

  private String name;

  private Node initNode;
  private Node finalNode;
  private float distance;
  private ArrayList<PVector> vertices = new ArrayList<PVector>();

  private PVector center;

  public boolean closed = false;
  private boolean selected = false;

  public int load = 0;


  /**
   * Initiate Lane with name, init and final nodes and inbetween vertices
   * @param name  Name of the street containing the lane
   * @param initNode  Node where the lane starts
   * @param finalNode  Node where the lane ends
   * @param vertices  List of vertices that give shape to lane
   */
  public Lane(String name, Node initNode, Node finalNode, ArrayList<PVector> vertices) {
    this.name = name;
    this.initNode = initNode;
    this.finalNode = finalNode;
    this.center = new PVector((initNode.position.x+finalNode.position.x)/2, (initNode.position.y+finalNode.position.y)/2);

    if (vertices != null && vertices.size() != 0) this.vertices = new ArrayList(vertices);
    else {
      this.vertices.add(initNode.getPosition());
      this.vertices.add(finalNode.getPosition());
    }
    distance = calcLength();
  }


  /**
   * Get the end node, where the lane is connected
   * @return end node
   */
  public Node getEnd() {
    return finalNode;
  }

  public void closeLane() {
    closed = true;
  }


  /**
   * Get a copy of all vertices that shape the lane
   * @return list of vertices in lane
   */
  public ArrayList<PVector> getVertices() {
    return new ArrayList<PVector>(vertices);
  }


  /**
   * Get the i vertex in lane
   * @param i  Position of vertex in lane
   * @return vertex in position i, null if position does not exist
   */
  public PVector getVertex(int i) {
    if (i >= 0  && i < vertices.size()) return vertices.get(i).copy();
    return null;
  }


  /**
   * Calculate the length of lane
   * @return length of lane in pixels
   */
  public float calcLength() {
    float dist = 0;
    for (int i = 1; i < vertices.size(); i++) {
      PVector utmsInit = new PVector(
        map(vertices.get(i-1).x, 0+100, width-100, boundaries[0].x, boundaries[1].x), 
        map(vertices.get(i-1).y, height-100, 0+100, boundaries[0].y, boundaries[1].y)
        );
      PVector utmsFinal = new PVector(
        map(vertices.get(i).x, 0+100, width-100, boundaries[0].x, boundaries[1].x), 
        map(vertices.get(i).y, height-100, 0+100, boundaries[0].y, boundaries[1].y)
        );
      dist += utmsInit.dist( utmsFinal );
    };
    return dist;
  }


  /**
   * Get the length of the lane
   * @return Length of lane in pixels 
   */
  public float getLength() {
    return distance;
  }


  /**
   * Check if lane is open
   * @return true if lane is open, false otherwise
   */
  public boolean isOpen() {
    return true;
  }


  /**
   * Check if lane contains a specific vertex
   * @param vertex  Position to compare with existent vertices
   * @return true if vertex is in lane, false otherwise
   */
  public boolean contains(PVector vertex) {
    return vertices.indexOf(vertex) >= 0;
  }


  /**
   * Find contrariwise lane, if exists. Contrariwise is alane that follows the same vertices in opposite direction.
   * @return contrariwise lane, or null if it doesn't exists
   */
  public Lane findContrariwise() {
    for (Lane otherLane : finalNode.outboundLanes()) {
      if (otherLane.isContrariwise(this)) return otherLane;
    }
    return null;
  }


  /**
   * Check if lane is contrariwise. Contrariwise is the lane that follows the same vertices in opposite direction.
   * @param lane  Lane to compare
   * @return true if both lanes are contrariwise, false otherwise
   */
  public boolean isContrariwise(Lane lane) {
    ArrayList<PVector> reversedVertices = new ArrayList(lane.getVertices());
    Collections.reverse(reversedVertices);
    return vertices.equals(reversedVertices);
  }


  /**
   * Find point in lane closest to specified position
   * @param position  Position to find closest point
   * @return closest point position in lane 
   */
  public PVector findClosestPoint(PVector position) {
    Float minDistance = Float.NaN;
    PVector closestPoint = null;
    for (int i = 1; i < vertices.size(); i++) {
      PVector projectedPoint = Geometry.scalarProjection(position, vertices.get(i-1), vertices.get(i));
      float distance = PVector.dist(position, projectedPoint);
      if (minDistance.isNaN() || distance < minDistance) {
        minDistance = distance;
        closestPoint = projectedPoint;
      }
    }
    return closestPoint;
  }


  /**
   * Divide a lane by a new Node if it matches with any lane's vertex position. Connect to the node, and create
   * a new lane from new node to actual final node.
   * @param node  New node to divide lane by
   * @return true if lane was succesfully divided, false otherwise
   */
  protected boolean divide(Node node) {
    int i = vertices.indexOf(node.getPosition());
    if (i > 0 && i < vertices.size()-1) {
      ArrayList<PVector> dividedVertices = new ArrayList( vertices.subList(i, vertices.size()) );
      node.connect(finalNode, dividedVertices, name);
      vertices = new ArrayList( vertices.subList(0, i+1) );
      finalNode = node;
      distance = calcLength();
      return true;
    }
    return false;
  }


  /**
   * Split a lane by a new Node if its position is in lane. Connect to the node, and create
   * a new lane from new node to actual final node.
   * @param node New node to split lane by
   * @return true if lane was succesfully splited, false otherwise
   */
  protected Node split(Node node) {
    if (node.getPosition().equals(vertices.get(0))) return initNode;
    else if ( node.getPosition().equals(finalNode.getPosition()) ) return finalNode;
    for (int i = 1; i < vertices.size(); i++) {
      if (Geometry.inLine(node.getPosition(), vertices.get(i-1), vertices.get(i))) {

        ArrayList<PVector> splittedVertices = new ArrayList();
        splittedVertices.add(node.getPosition());
        splittedVertices.addAll( vertices.subList(i, vertices.size()) );
        node.connect(finalNode, splittedVertices, name);

        vertices = new ArrayList( vertices.subList(0, i) );
        vertices.add(node.getPosition());
        finalNode = node;
        distance = calcLength();
        return node;
      }
    }
    return null;
  }


  /**
   * Draw lane, applying color settings depending on data to show
   * @param canvas  Canvas to draw lane
   * @param stroke  Lane width in pixels
   * @param c  Lane color
   */

  public void draw(PGraphics canvas, int stroke, color c) {
    color occupColor = lerpColor(c, #FF0000, color(255, 255, 255));
    canvas.stroke(occupColor, 200); 
    canvas.strokeWeight(stroke);
    if (load > 0) canvas.strokeWeight(3);
    if (closed) {
      canvas.stroke(#e062e0);
    }
    for (int i = 1; i < vertices.size(); i++) {
      PVector prevVertex = vertices.get(i-1);
      PVector vertex = vertices.get(i);
      canvas.line(prevVertex.x, prevVertex.y, vertex.x, vertex.y);
    }
  }


  public boolean select(int mouseX, int mouseY) {
    selected = dist(center.x, center.y, mouseX, mouseY) < 3;
    return selected;
  }
}
