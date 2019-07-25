/**
 * Path - Class defining the path an agent must follow to arrive to its destination. It's autocontained, and able to be updated and recalculated 
 * @author        Marc Vilella & Javier Zárate
 * @credits       aStar method inspired in Aaron Steed's Pathfinding class http://www.robotacid.com/PBeta/AILibrary/Pathfinder/index.html
 * @version       2.0
 * @see           Node, Lane
 */
public class Path {

  private final Roads ROADMAP;

  private ArrayList<Lane> lanes = new ArrayList<Lane>();
  private float distance = 0;

  // Path movement variables
  private Node inNode = null;
  private Lane currentLane;
  private PVector toVertex;
  private boolean arrived = false;
  private POI poi;


  public Path(POI poi, Roads roads) {
    ROADMAP = roads;
    this.poi = poi;
  }


  /**
   * Check if path is computed and available
   * @return true if path is computed, false otherwise
   */
  public boolean available() {
    return lanes.size() > 0;
  }    


  /**
   * Calculate path length
   * @return path length in pixels
   */
  private float calcLength() {
    float distance = 0;
    for (Lane lane : lanes) distance += lane.getLength();
    return distance;
  }


  /**
   * Get path length
   * @return path length
   */
  public float getLength() {
    return distance;
  }


  /**
   * Check if agent has arrived to the end of the path
   * @return true if agent has arrived, false otherwise
   */
  public boolean hasArrived() {
    return arrived;
  }


  /**
   * Return the node where the agent is placed
   * @return node where agent is placed
   */
  public Node inNode() {
    return inNode;
  }


  /**
   * Reset path paramters to initial state
   */
  public void reset() {
    lanes = new ArrayList<Lane>();
    currentLane = null;
    arrived = false;
    distance = 0;
  }


  /**
   * Draw path
   * @param stroke  Path stroke
   * @param c    Path color
   */
  public void draw(PGraphics canvas, int stroke, color c) {
    for (Lane lane : lanes) {
      lane.draw(canvas, stroke, c);
    }
  }


  /**
   * Find a path between two points
   * @param origin  Origin node of the path
   * @param destination  Destination node of the path
   * @return true if a path has been found, false otherwise   
   */
  public boolean findPath(Node origin, Node destination) {
    if (origin != null && destination != null) {
      lanes = aStar(origin, destination);
      if (lanes.size() > 0) {
        distance = calcLength();
        inNode = origin;
        currentLane = lanes.get(0);
        toVertex = currentLane.getVertex(1);
        arrived = false;
        return true;
      }
    }
    return false;
  }


  /**
   * Perform a A* pathfinding algorithm
   * @param origin  Origin node
   * @param destination  Destination node
   * @return list of lanes that define the found path from origin to destination
   * The cost is considering the crowds of the actual agents in a lane
   */
  private ArrayList<Lane> aStar(Node origin, Node destination) {
    ArrayList<Lane> path = new ArrayList<Lane>();
    if (!origin.equals(destination)) {
      for (Node node : ROADMAP.getAll()) node.reset();
      ArrayList<Node> closed = new ArrayList<Node>();
      PriorityQueue<Node> open = new PriorityQueue();
      open.add(origin);
      
      while (open.size() > 0) {
        Node currNode = open.poll();
        closed.add(currNode);
        if (currNode.equals(destination)) break;
        for (Lane lane :  currNode.outboundLanes()) {
           Node neighbor = lane.getEnd();
          if (lane.closed) break;
          if (!lane.isOpen() || closed.contains(neighbor)) continue;
          boolean neighborOpen = open.contains(neighbor);
          float costToNeighbor = currNode.getG() + lane.getLength() + 15 * 30;
          if ( costToNeighbor < neighbor.getG() || !neighborOpen ) {
            neighbor.setParent(currNode); 
            neighbor.setG(costToNeighbor);
            neighbor.setF(destination);
            if (!neighborOpen) open.add(neighbor);
          }
        }
      }
      path = tracePath(destination);
    }
    return path;
  }


  /**
   * Look back all path to a node
   * @param destination  Destination node
   * @return list of lanes that define a path to destination node
   */
  private ArrayList<Lane> tracePath(Node destination) {
    ArrayList<Lane> path = new ArrayList<Lane>();
    Node pathNode = destination;
    while (pathNode.getParent() != null) {
      path.add(pathNode.getParent().shortestLaneTo(pathNode));
      pathNode = pathNode.getParent();
    }
    Collections.reverse(path);
    return path;
  }


  /**
   * Return the list of lanes that form the path
   * @return path description
   */
  @Override
    public String toString() {
    String str = lanes.size() + " LANES: ";
    for (Lane lane : lanes) {
      str += lane.toString() + ", ";
    }
    return str;
  }
}
