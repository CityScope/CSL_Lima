/**
 * Roads - Facade to simplify manipulation of the whole simulation
 * @author        Marc Vilella & Javier Zarate
 * @version       1.1
 * @see           Facade
 */

public PVector[] boundaries;
public ArrayList<PVector> PTS = new ArrayList<PVector>();

public class Roads extends Facade<Node> {
  PGraphics canvas;


  /**
   * Contructor that calls RoadFactory
   * @file is the file of the roads
   * @canvas is the PGraphics
   */
  public Roads(String file, PGraphics canvas) {
    this.canvas = canvas;
    factory = new RoadFactory();
    this.loadJSON(file, this);
  }


  public void readMesh(ArrayList<Cells> mesh, PGraphics canvasReader) {
    for (Cells cell : mesh) {
      color col = cell.ownColor;
      float newW = map(cell.center.x, 0, canvasReader.width, 0, this.canvas.width);
      float newH = map(cell.center.y, 0, canvasReader.height, 0, this.canvas.height);
      boolean condition1 = (cell.colorName.equals("red") || cell.colorName.equals("yellow") || cell.colorName.equals("green"));
      boolean condition2 = cell.poiCreated;
      boolean result = (condition1) && (!condition2);
      boolean delete = !condition1;

      if (result) {
        POI latent;
        int capacity = 0;
        this.canvas.fill(col);

        if (cell.colorName.equals("red")) capacity = 250;
        else if (cell.colorName.equals("yellow")) capacity = 200;
        else if (cell.colorName.equals("green")) capacity = 150;

        latent = new AffectedArea(roads, str(roads.count()), "affectedArea", "affectedArea", new PVector(newW, newH), capacity, 120);
        latent.ownColor = col;
        cell.poiCreated = true;
      }

      if (delete) {
        pois.deletePOI(new PVector(newW, newH), 2);
        cell.poiCreated = false;
      }
    }
  }


  /**
   * Add a node in the roads
   * Asign an ID that is equals to the length of the items
   */
  public void add(Node node) {
    if (node.getID() == -1) {
      node.setID(items.size());
      items.add(node);
    }
  }


  /**
   * Draw all the nodes
   * Call the draw functions of other classes
   */
  public void draw(PGraphics canvas, int stroke) {
    for (Node node : items) node.draw(canvas, stroke);
  }


  /**
   * Call node select function
   */
  public void select(int mouseX, int mouseY) {
    for (Node node : items) node.select(mouseX, mouseY);
  }

  public void selectCenterLane(int mouseX, int mouseY) {
    for (Node node : items) {
      for (Lane lane : node.outboundLanes()) {
        lane.select(mouseX, mouseY);
      }
    };
  }


  /**
   * Connect a POI to the road
   * add the POI to the item arrayList
   */
  private void connect(POI poi) { 
    Lane closestLane = findClosestLane(poi.getPosition());
    Lane closestLaneBack = closestLane.findContrariwise();
    PVector closestPoint = closestLane.findClosestPoint(poi.getPosition());

    Node connectionNode = new Node(closestPoint);
    connectionNode = closestLane.split(connectionNode);
    if (closestLaneBack != null) connectionNode = closestLaneBack.split(connectionNode);
    this.add(connectionNode);

    poi.connectBoth(connectionNode, null, "Access");
    add(poi);
  }


  /**
   * Find the closes lane realtive to the center position
   */
  public Lane findClosestLane(PVector position) {
    Float minDistance = Float.NaN;
    Lane closestLane = null;
    for (Node node : items) {
      for (Lane lane : node.outboundLanes()) {
        PVector linePoint = lane.findClosestPoint(position);
        float distance = position.dist(linePoint);
        if (minDistance.isNaN() || distance < minDistance) {
          minDistance = distance;
          closestLane = lane;
        }
      }
    }
    return closestLane;
  }


  /**
   * Map the lat lon to a UTM coordinates
   * Map the UTM to the canvas size
   * @return a mapped value
   */
  public PVector toXY(float lat, float lon) {
    PVector projPoint = Projection.toUTM(lat, lon, Projection.Datum.WGS84);
    return new PVector(
      map(projPoint.x, boundaries[0].x, boundaries[1].x, 0+100, this.canvas.width-100), 
      map(projPoint.y, boundaries[0].y, boundaries[1].y, this.canvas.height-100, 0+100)
      );
  }
}


/**
 * AgentFactory - Factory to generate the roads 
 * @author        Marc Vilella & Javier Zarate
 * @version       1.1
 * @see           Factory
 */
public class RoadFactory extends Factory<Node> {

  public ArrayList <Node> loadJSON(File file, Roads roads) {
    print("Loading Roads... ");
    JSONObject roadNetwork = loadJSONObject(file);
    JSONArray lanes = roadNetwork.getJSONArray("features");
    boundaries = findBound(lanes);
    for (int i = 0; i < lanes.size(); i++) {
      JSONObject lane = lanes.getJSONObject(i);
      JSONObject props = lane.getJSONObject("properties");
      String name = props.isNull("name") ? "null" : props.getString("name");
      boolean oneWay = props.isNull("oneway")? false:props.getInt("oneway")==1? true:false;
      String direction = props.isNull("direction")? null: props.getString("direction");
      JSONArray points = lane.getJSONObject("geometry").getJSONArray("coordinates");

      Node prevNode = null;
      ArrayList vertices = new ArrayList();

      for (int j = 0; j < points.size(); j++) {
        PVector point = roads.toXY(points.getJSONArray(j).getFloat(1), points.getJSONArray(j).getFloat(0));
        PTS.add(point);
        vertices.add(point);

        Node currNode = getNodeIfVertex(roads, point);
        if (currNode != null) {
          if (prevNode != null && j < points.size()-1) {
            if (oneWay) prevNode.connect(currNode, vertices, name);
            else prevNode.connectBoth(currNode, vertices, name);
            vertices = new ArrayList();
            vertices.add(point);
            prevNode = currNode;
          }
        } else currNode = new Node(point);

        if (prevNode == null) {
          prevNode = currNode;
          currNode.place(roads);
        } else if (j == points.size()-1) {
          if (oneWay) prevNode.connect(currNode, vertices, name);
          else prevNode.connectBoth(currNode, vertices, name);
          currNode.place(roads);
          if (direction != null) currNode.setDirection(direction);
        }
      }
    }
    println("LOADED");
    return new ArrayList<Node>();
  }


  /**
   * Evaluate if a node exists in the current road.
   * return a new node if it is not in the roads, null otherwise
   */
  private Node getNodeIfVertex(Roads roads, PVector position) {
    for (Node node : roads.getAll()) {
      if ( position.equals(node.getPosition()) ) return node;
      for (Lane lane : node.outboundLanes()) {
        if ( position.equals(lane.getEnd().getPosition()) ) return lane.getEnd();
        else if ( lane.contains(position) ) {
          Lane laneBack = lane.findContrariwise();
          Node newNode = new Node(position);
          if (lane.divide(newNode)) {
            if (laneBack != null) laneBack.divide(newNode);
            newNode.place(roads);
            return newNode;
          }
        }
      }
    }
    return null;
  }


  /**
   * Get the bound of the roads
   * @return the bounding box in UTM coordinates
   */

  public PVector[] findBound(JSONArray lanes) {
    float minLat = Float.MAX_VALUE;
    float maxLat = -(Float.MAX_VALUE);
    float minLon = Float.MAX_VALUE;
    float maxLon = -(Float.MAX_VALUE);
    for (int i  =0; i < lanes.size(); i++) {
      JSONObject lane =lanes.getJSONObject(i);
      JSONArray points=lane.getJSONObject("geometry").getJSONArray("coordinates");
      for (int j=0; j<points.size(); j++) {
        float lat = points.getJSONArray(j).getFloat(1);
        float lon = points.getJSONArray(j).getFloat(0);
        minLat = min(minLat, lat);
        maxLat = max(maxLat, lat);
        minLon = min(minLon, lon);
        maxLon = max(maxLon, lon);
      }
    }
    return new PVector[] {
      Projection.toUTM(minLat, minLon, Projection.Datum.WGS84), 
      Projection.toUTM(maxLat, maxLon, Projection.Datum.WGS84)
    };
  }
}
