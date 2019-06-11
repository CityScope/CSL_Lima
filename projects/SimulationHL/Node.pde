/**
 * Road - Node is the main element for roadmap, defining road intersections
 * @author        Marc Vilella
 * @credits       Aaron Steed http://www.robotacid.com/PBeta/AILibrary/Pathfinder/index.html
 * @version       2.0
 * @see           Lane
 */
private class Node implements Placeable, Comparable<Node> {

  protected int id;
  protected final PVector position;
  protected ArrayList<Lane> lanes = new ArrayList();
  protected boolean selected;
  private String direction = null;

  // Pathfinding variables
  private Node parent;
  private float f;
  private float g;

  protected int vul; 


  /**
   * Initiate node with its position. ID is defined to -1 until it is finally placed into roadmap
   * @param position  Node's position
   */
  public Node(PVector position) {
    id = -1;
    this.position = position;
  }


  /**
   * Set node ID
   * @param id    ID of the node
   */
  public void setID(int id) {
    this.id = id;
  }


  /**
   * Get node ID
   * @return node ID
   */
  public int getID() {
    return id;
  }


  /**
   * Save node into roadmap.
   * @param roads  Roadmap to add node
   */
  public void place(Roads roads) {
    roads.add(this);
  }


  /**
   * Get node position
   * @return node position
   */
  public PVector getPosition() {
    return position.copy();
  }


  /**
   * Get all outbound lanes from the node
   * @return outbound lanes
   */
  public ArrayList<Lane> outboundLanes() {
    return lanes;
  }


  /**
   * Get shortest lane that goes to a specified node, if exists
   * @param node  Destination node
   * @return shortest lane to destination node, null if no lane goes to node
   */
  public Lane shortestLaneTo(Node node) {
    Float shortestLaneLength = Float.NaN;
    Lane shortestLane = null;
    for (Lane lane : lanes) {
      if (node.equals(lane.getEnd())) {
        if (shortestLaneLength.isNaN() || lane.getLength() < shortestLaneLength) {
          shortestLaneLength = lane.getLength();
          shortestLane = lane;
        }
      }
    }
    return shortestLane;
  }


  /**
   * Create a lane that connects node with another node
   * @param node  Node to connect
   * @param vertices  List of vertices that shape the lane
   * @param name  Name of the lane
   */
  protected void connect(Node node, ArrayList<PVector> vertices, String name) {
    lanes.add(new Lane(name, this, node, vertices));
  }


  /**
   * Create a bidirectional connection (two lanes) between node and another node
   * @param node  Node to connect
   * @param vertices  List of vertices that shape the lanes
   * @param name  Name of the lanes
   */
  protected void connectBoth(Node node, ArrayList<PVector> vertices, String name) {
    connect(node, vertices, name);
    if (vertices != null) Collections.reverse(vertices);
    node.connect(this, vertices, name);
  }


  /**
   * Set the direction of the street (to connect a Cluster to this node) 
   * @param direction  Cluster direction ID
   */
  protected void setDirection(String direction) {
    this.direction = direction;
  }


  /**
   * Get the direction of the street (to connect a Cluster to this node) 
   * @return the direction ID of the next Cluster
   */
  protected String getDirection() {
    return direction;
  }


  /**
   * Draw the node and outbound lanes with default colors
   * @param canvas  Canvas to draw node
   */
  public void draw(PGraphics canvas) {
    canvas.fill(#000000); 
    canvas.ellipse(position.x, position.y, 3, 3);
    draw(canvas, 1);
  }


  /**
   * Draw outbound lanes with specified colors
   * @param canvas  Canvas to draw node
   * @param stroke  Lane width in pixels
   * @param c  Lanes color
   */
  public void draw(PGraphics canvas, int stroke) {
    for (Lane lane : lanes) {
      float valor = map(lane.load, 0, 150, 0, 1);
      color occupColor = lerpColor(#E0E3E5, #FF0000, valor);
      lane.draw(canvas, stroke, occupColor);
      if (lane.selected) {
        lane.closeLane();
      }
    }
    if (selected) canvas.text(toString(), position.x, position.y);
  }


  /**
   * Select node if mouse is hover
   * @param mouseX  Horizontal mouse position in screen
   * @param mouseY  Vertical mouse position in screen
   * @return true if node is selected, false otherwise
   */
  public boolean select(int mouseX, int mouseY) {
    selected = dist(position.x, position.y, mouseX, mouseY) < 3;
    return selected;
  }


  /**
   * PATHFINDING METHODS
   * Update and get pathfinding variables (parent node, f and g)
   */
  public void setParent(Node parent) {
    this.parent = parent;
  }

  public Node getParent() {
    return parent;
  }

  public void setG(float g) {
    this.g = g;
  }

  public float getG() {
    return g;
  }

  public void setF(Node nextNode) {
    float h =  position.dist(nextNode.getPosition());
    f = g + h;
  }

  public float getF() {
    return f;
  }

  public void reset() {
    parent = null;
    f = g = 0.0;
  }


  /**
   * Return agent description (ID, POSITION and LANEs)
   * @return node description
   */
  @Override
    public String toString() {
    return id + ": " + position + " [" + lanes.size() + "]";
  }


  /**
   * Compare node to other node, where comparing means checking which one has the lowest f (accumulated cost in pathfinding). It is used in
   * PriorityQueue structure in the A* pathfinding algorithm.
   * @param node  Node to compare f (accumulated cost)
   * @return -1 if cost is lower, 0 if costs are equal or 1 if cost is higher
   */
  @Override
    public int compareTo(Node node) {
    return f < node.getF() ? -1 : f == node.getF() ? 0 : 1;
  }
}
