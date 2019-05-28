/**
 * Lane - Lane is the connection bewtween two nodes in roadmap graph, and implements all possibilities for agents to move in them
 * @author        Marc Vilella & Javier Zarate
 * @credits       Aaron Steed http://www.robotacid.com/PBeta/AILibrary/Pathfinder/index.html
 * @version       2.1
 * @see           Node
 */
private class Lane {

  private String name;
  private Accessible access;

  private Node initNode;
  private Node finalNode;
  private float distance;
  private ArrayList<PVector> vertices = new ArrayList();
  private boolean open = true;

  private int maxCrowd = 15;
  private ArrayList<Agent> crowd = new ArrayList();
  private float occupancy;
  private PVector center;

  public float ms;
  public float ratio;
  public float vul;
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
  public Lane(String name, Accessible access, Node initNode, Node finalNode, ArrayList<PVector> vertices) {
    this.name = name;
    this.access = access;
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
    closed =true;
  }

  public void probInjured() {
    if (closed) {
      for (Agent people : crowd) {
        float rand = random(0.0, 1.0);
        if (rand < 0.001) {
          people.injured = true;
          people.working = false;
        }
      }
    }
  }


  /**
   * Get a copy of all vertices that shape the lane
   * @return list of vertices in lane
   */
  public ArrayList<PVector> getVertices() {
    return new ArrayList(vertices);
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
      //println(vertices.get(i-1), vertices.get(i
      PVector utmsInit = new PVector(
        map(vertices.get(i-1).x, 0+100, width-100, boundaries[0].x, boundaries[1].x), 
        map(vertices.get(i-1).y, height-100, 0+100, boundaries[0].y, boundaries[1].y)
        );
      PVector utmsFinal = new PVector(
        map(vertices.get(i).x, 0+100, width-100, boundaries[0].x, boundaries[1].x), 
        map(vertices.get(i).y, height-100, 0+100, boundaries[0].y, boundaries[1].y)
        );
      dist += utmsInit.dist( utmsFinal );
      //dist += vertices.get(i-1).dist( vertices.get(i) );
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
    return open;
  }

  /**
   *Check if the agent could go throw the lane
   *@return if is true or not
   */
  public boolean allows(Agent agent) {
    return access.allows(agent);
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
   * Get the following vertex in lane
   * @param vertex  Vertex in lane
   * @return  next vertex, or null if vertex is last vertex or doesn't exist in lane
   */
  public PVector nextVertex(PVector vertex) {
    int i = vertices.indexOf(vertex) + 1;
    if (i > 0 && i < vertices.size()) return vertices.get(i);
    return null;
  }


  /**
   * Check if vertex is last of lane
   * @param vertex  Vertex to check
   * @return true if vertex is the last one in lane, false otherwise
   */
  public boolean isLastVertex( PVector vertex ) {
    return vertex.equals( vertices.get( vertices.size() - 1 ) );
  }


  /**
   * Find contrariwise lane, if exists. Contrariwise is alane that follows the same vertices in opposite direction.
   * @return contrariwise lane, or null if it doesn't exists
   */
  public Lane findContrariwise() {
    for (Lane otherLane : finalNode.outboundLanes()) {
      if ( otherLane.isContrariwise(this) ) return otherLane;
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
      node.connect(finalNode, dividedVertices, name, access);
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
    if ( node.getPosition().equals(vertices.get(0)) ) return initNode;
    else if ( node.getPosition().equals(finalNode.getPosition()) ) return finalNode;
    for (int i = 1; i < vertices.size(); i++) {
      if ( Geometry.inLine(node.getPosition(), vertices.get(i-1), vertices.get(i)) ) {

        ArrayList<PVector> splittedVertices = new ArrayList();
        splittedVertices.add(node.getPosition());
        splittedVertices.addAll( vertices.subList(i, vertices.size()) );
        node.connect(finalNode, splittedVertices, name, access);

        vertices = new ArrayList( vertices.subList(0, i) );
        vertices.add(node.getPosition());
        finalNode = node;
        distance = calcLength();
        return node;
      }
    }
    return null;
  }
  
  
  public void drawTraffic(PGraphics canvas) {
    float valor = map(ms, 3.524063035, 5.421770832, 0.0, 1.0);
    float newStroke = map(ratio, 0, 1.8, 0, 5);
    color occupColor = lerpColor(#FFFFFF, #FF0000, valor);
    canvas.stroke(occupColor, 127); 
    canvas.strokeWeight(int(newStroke));
    for (int i = 1; i < vertices.size(); i++) {
      PVector prevVertex = vertices.get(i-1);
      PVector vertex = vertices.get(i);
      canvas.line(prevVertex.x, prevVertex.y, vertex.x, vertex.y);
    }
  }

  /**
   * Draw lane, applying color settings depending on data to show
   * @param canvas  Canvas to draw lane
   * @param stroke  Lane width in pixels
   * @param c  Lane color
   */

  public void draw(PGraphics canvas, int stroke, color c) {
    color occupColor = lerpColor(c, #FF0000, occupancy);    // Lane occupancy color interpolation
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



  /**
   * Add reference to an agent that is crossing in the lane. Recalculate occupancy
   * @param agent  The agent crossing the lane
   */
  public void addAgent(Agent agent) {
    crowd.add(agent);
    occupancy = (float) crowd.size() / maxCrowd;
  }


  /**
   * Remove reference to agent that was crossing in the lane, but it's not anymore. Recalculate occupancy
   * @param agent  The agent that was crossing the lane
   */
  public void removeAgent(Agent agent) {
    crowd.remove(agent);
    occupancy = (float) crowd.size() / maxCrowd;
  }


  /**
   * Return lane description (NAME and VERTICES count)
   * @return lane description
   */
  @Override
    public String toString() {
    return name + " with " + vertices.size() + "vertices [" + vertices + "]" + "traffic: " + ms;
  }

  public boolean select(int mouseX, int mouseY) {
    selected = dist(center.x, center.y, mouseX, mouseY) < 3;
    return selected;
  }
}
