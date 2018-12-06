/**
 * @copyright: Copyright (C) 2018
 * @legal:
 * This file is part of HumanitarianModel.
 
 * HumanitarianModel is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * HumanitarianModel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with HumanitarianModel.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * Grapho - Class which represents a roadnetwork 
 * @see:       Node, Lane, POI
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1 
 */
public class Grapho {
  private ArrayList<Node> NODES = new ArrayList<Node>();
  private ArrayList<Lane> LANES = new ArrayList<Lane>();
  private ArrayList<POI> POIS = new ArrayList<POI>();
  private IntDict NCOORDS = new IntDict();
  private PVector[] BOUNDS;
  private HashMap<String, ArrayList<Lane>> LANESMAP = new HashMap<String, ArrayList<Lane>>();
  private Graph GRAPH = new Graph();
  private int IDSTART;
  private int IDEND;
  private int ALGORITHM = 3;
  private GraphNode[] ROUTE;
  private IGraphSearch FINDER;
  private boolean SHOW;
  private double PROPORTION;


  /**
   * Creates a Grapho object from two files
   * @param: roadPath  Path to the geoJSON file with the roads
   * @param: poiPath   Path to the geoJSON file with the schools and hospitals 
   */
  public Grapho(String roadPath, String poiPath) {
    loadNodesLanes(roadPath);
    loadPOIS(poiPath);
    IDSTART = POIS.get(0).getID();
    IDEND = POIS.get(POIS.get(0).getLink()).getID();
    makePathFinder();
    usePathFinder();
    PROPORTION = getGeoProportion();
  }


  /**
   * Retrieves the data from the geoJSON file with the roads
   * @param: roadPath  Path to the geoJSON file with the roads
   */
  private void loadNodesLanes(String roadPath) {
    print("Loading nodes and lanes...");

    JSONObject roadNetwork = loadJSONObject(roadPath);
    JSONArray lanes = roadNetwork.getJSONArray("features");

    BOUNDS = findBounds(lanes);

    int nodeID = 0;
    for (int i = 0; i < lanes.size(); i++) {
      JSONObject lane = lanes.getJSONObject(i);     
      JSONObject props = lane.getJSONObject("properties");

      String access = props.isNull("CATEG_TXT") ? "ALL" : evaluateAccess( props.getString("CATEG_TXT") );
      String name = props.isNull("NOMBRE_VIA") ? "null" : props.getString("NOMBRE_VIA");
      String district = props.isNull("DISTRITO") ? "null" : props.getString("DISTRITO");
      boolean oneWay = props.isNull("CATEG_TXT")? false : evaluateWay(props.getString("CATEG_TXT"));

      JSONArray points = lane.getJSONObject("geometry").getJSONArray("coordinates").getJSONArray(0);

      Node prevNode = null;     
      for (int j = 0; j < points.size(); j++) {
        String LATLON = str(points.getJSONArray(j).getFloat(1)) + "/" +  str(points.getJSONArray(j).getFloat(0));
        PVector point = toXY(points.getJSONArray(j).getFloat(1), points.getJSONArray(j).getFloat(0));

        Node currNode;        
        if (!NCOORDS.hasKey(LATLON)) {
          NCOORDS.set(LATLON, nodeID);
          Node n = new Node(nodeID, district, point.x, point.y, GRAPH);
          NODES.add(n);
          nodeID++;
        }
        currNode = NODES.get(NCOORDS.get(LATLON));

        if (prevNode != null) {
          double costOut = findDistance(points.getJSONArray(j-1).getFloat(0), 
            points.getJSONArray(j-1).getFloat(1), 
            points.getJSONArray(j).getFloat(0), 
            points.getJSONArray(j).getFloat(1));

          Lane ln = new Lane(name, access, district, prevNode, currNode, costOut, GRAPH);
          LANES.add(ln);

          if (LANESMAP.containsKey(ln.getDistrict())) {
            LANESMAP.get(ln.getDistrict()).add(ln);
          } else {
            ArrayList<Lane> lns = new ArrayList<Lane>();
            lns.add(ln);
            LANESMAP.put(ln.getDistrict(), lns);
          }

          if (!oneWay) LANES.add(new Lane(name, access, district, currNode, prevNode, costOut, GRAPH));
        }
        prevNode = currNode;
      }
    } 

    println("Nodes and lanes loaded!");
  }


  /**
   * Retrieves the data from the geoJSON file with the schools and hospitals
   * @param: poiPath  Path to the geoJSON file with the schools and hospitals
   */
  private void loadPOIS(String poiPath) {
    print("Loading POIs...");

    JSONObject roadNetwork = loadJSONObject(poiPath);
    JSONArray pois = roadNetwork.getJSONArray("features"); 

    for (int i = 0; i < pois.size(); i++) {
      int id = NODES.size();
      JSONObject poi = pois.getJSONObject(i);
      JSONObject properties = poi.getJSONObject("properties");

      int poiID = properties.isNull("field_1") ? -1 : properties.getInt("field_1");
      String district = properties.isNull("NOMBDIST") ? "null" : assignDistrict(properties.getString("NOMBDIST"));
      String type = properties.isNull("Type") ? "street" : properties.getString("Type");
      int link = properties.isNull("Link") ? -1 : properties.getInt("Link");
      String latLon = str(properties.getFloat("C_LAT")) + "/" +  str(properties.getFloat("C_LONG"));
      PVector point = toXY(properties.getFloat("C_LAT"), properties.getFloat("C_LONG"));

      NCOORDS.set(latLon, id);   /*CHECK WHAT HAPPENS IF THERE IS A POI IN THE SAME PLACE*/

      POI p = new POI(id, poiID, district, point.x, point.y, GRAPH);
      p.setType(type);
      p.setLink(link);

      NODES.add(p);
      POIS.add(p);

      placePoi(p);

      poiID++;
    }

    println("POIs loaded!");
  }


  /**
   * Assigns "WALK", "DRIVE" or "ALL" depending on a road's type
   * @param: type  Type to standardize
   * @returns: String  Standardized type
   */
  private String evaluateAccess(String type) {
    switch(type) {
    case "CA": 
    case "AV":
    case "av": 
    case "PJE":
    case "JR":
    case "PQ":
    case "OV":
    case "PZ":
    case "ENT":
    case "SAL":
    case "CARR":
      return "ALL";

    case "pedestrian": 
    case "living_street": 
    case "footway": 
    case "steps": 
    case "cycleway": 
    case "ALA":
    case "MAL":
      return "WALK";

    case "tunnel": 
      return "DRIVE";

    case "hotel": 
    case "restaurant": 
    case "bar": 
    case "museum": 
      return "WALK";

    case "parking": 
      return "DRIVE";

    case "School": 
    case "Hospital": 
      return "ALL";
    }
    return "ALL";
  }


  /**
   * Assigs one-way or two-way depending on a road's type
   * @param: way  Type to evaluate
   * @returns: boolean  True - one-way / False - two-way
   */
  private boolean evaluateWay(String way) {
    switch(way) {
    case "CA": 
    case "AV":
    case "av":
    case "OV":
    case "ALA":
    case "MAL":
    case "CARR":
      return false;

    case "ENT":
    case "SAL":
    case "PZ":  
    case "PJE": 
    case "JR":
    case "PQ":  
      return true;
    }
    return false;
  }


  /**
   * Standardizes district name
   * @param: type  Name to standardize
   */
  private String assignDistrict(String type) {
    switch(type) {
    case "VENTANILLA": 
    case "LA PERLA":
    case "CARMEN DE LA LEGUA REYNOSO":
    case "BELLAVISTA":
      return "CALLAO";
    case "BREÑA":
      return "BRENA";
    case "MAGDALENA VIEJA":
      return "PUEBLO LIBRE";
    case "SURCO":
      return "SANTIAGO DE SURCO";
    case "MATUCANA": 
    case "RICARDO PALMA":
    case "PQ":  
      return "HUAROCHIRI";
    }
    return type;
  }


  /**
   * Maps (lat, lon) to UTM coordinates and maps the UTM to the canvas size
   * @returns: PVector  Mapped UTM coordinates
   */
  private PVector toXY(float lat, float lon) {
    PVector projPoint = Projection.toUTM(lat, lon, Projection.Datum.WGS84);
    return new PVector(
      map(projPoint.x, BOUNDS[0].x, BOUNDS[1].x, 0, width), 
      map(projPoint.y, BOUNDS[0].y, BOUNDS[1].y, height, 0)
      );
  }


  /**
   * Finds the minimum and maximum latitutudes and longitudes of a JSONArray
   * @param: lanes  JSONArray to look in
   * @returns: PVector[]  Minimum and maximum latitutudes and longitudes
   */
  private PVector[] findBounds(JSONArray lanes) {
    float minLat = Float.MAX_VALUE;
    float maxLat = -(Float.MAX_VALUE);
    float minLon = Float.MAX_VALUE;
    float maxLon = -(Float.MAX_VALUE);

    for (int i = 0; i< lanes.size(); i++) {
      JSONObject lane =lanes.getJSONObject(i);
      JSONArray points = lane.getJSONObject("geometry").getJSONArray("coordinates").getJSONArray(0);

      for (int j = 0; j < points.size(); j++) {
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


  private double getGeoProportion() {
    double costOut = findDistance(-12.074512, -77.051677, -12.074176, -77.050593);
    PVector point1 = toXY(-12.074512, -77.051677);
    PVector point2 = toXY( -12.074176, -77.050593);

    return costOut * dist(point1.x, point1.y, point2.x, point2.y);
  }


  /**
   * Finds the geographical distance between two points
   * @param: lng1  Longitude of the first point
   * @param: lat1  Latitude of the first point
   * @param: lng2  Longitude of the second point
   * @param: lat2  Latitude of the second point
   */
  private double findDistance(float lng1, float lat1, float lng2, float lat2) {
    double earthRadius = 6371; 

    double dLat = Math.toRadians(lat2 - lat1);  
    double dLng = Math.toRadians(lng2 - lng1); 

    double sindLat = Math.sin(dLat / 2);  
    double sindLng = Math.sin(dLng / 2);  

    double va1 = Math.pow(sindLat, 2) + Math.pow(sindLng, 2) * Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2));  
    double va2 = 2 * Math.atan2(Math.sqrt(va1), Math.sqrt(1 - va1));  

    double distance = earthRadius * va2;  

    return distance;
  }


  /**
   * Creates an IGraphSearch object using a determined algorithm
   * @returns: IGraphSearch  A path finding object
   */
  private void makePathFinder() {
    FINDER = null;
    float f = 1.0f;
    switch(ALGORITHM) {
    case 0:
      FINDER = new GraphSearch_DFS(GRAPH);
      break;
    case 1:
      FINDER = new GraphSearch_BFS(GRAPH);
      break;
    case 2:
      FINDER = new GraphSearch_Dijkstra(GRAPH);
      break;
    case 3:
      FINDER = new GraphSearch_Astar(GRAPH, new AshCrowFlight(f));
      break;
    case 4:
      FINDER = new GraphSearch_Astar(GRAPH, new AshManhattan(f));
      break;
    }
  } 


  /**
   * Finds the route between two nodes
   */
  private void usePathFinder() {
    FINDER.search(IDSTART, IDEND, true);
    ROUTE = FINDER.getRoute();
  }


  /**
   * Gets the value of the GRAPH attribute
   * @returns: Graph  Value of GRAPH
   */
  public Graph getGraph() {
    return GRAPH;
  }


  /**
   * Toggles the values of SHOW
   */
  public void toggleShow() {
    SHOW = !SHOW;
  }


  /**
   * Calls its drawLanes and drawNodes methods
   * @param: canvas  PGraphics object to draw on
   * @param: zoom    Wether it is zoomed or not
   * @param: mousex  X coordinate of the mouse
   * @param: mousey  Y coordinate of the mouse
   */
  public void draw(PGraphics canvas, boolean zoom) {
    canvas.background(255);
    canvas.pushMatrix();

    drawLanes(canvas, 5, 6, false);

    if (zoom) drawNodes(canvas, 0.5);
    else drawNodes(canvas, 5);

    if (SHOW) {
      drawRoute(canvas, color(200, 0, 0));
    }

    canvas.popMatrix();
  }


  /**
   * Deletes a road from the network
   * @param: initNode  Start node of the Lane object
   * @param: endNode   End node of the Lane object
   */
  public boolean deleteLane(int initNode, int endNode) {
    for (Lane lane : LANES) {
      if ((lane.getStart().getID() == initNode) && (lane.getEnd().getID() == endNode)) {
        GRAPH.removeEdge(initNode, endNode);
        lane.setErase(true);
        return true;
      }
    }
    return false;
  }


  /**
   * Adds a road back to the network
   * @param: initNode  Start node of the Lane object
   * @param: endNode   End node of the Lane object
   */
  public boolean addLane(int initNode, int endNode) {
    for (Lane lane : LANES) {
      if ((lane.getStart().getID() == initNode) && (lane.getEnd().getID() == endNode)) {
        GRAPH.addEdge(initNode, endNode, PROPORTION * dist(lane.getStart().getX(), lane.getStart().getY(), lane.getEnd().getX(), lane.getEnd().getY()));
        lane.setErase(false);
        return true;
      }
    }
    return false;
  }


  /**
   * Gets a POI instance at a given (X, Y) location, within a certain distance
   * @param: x            X coordinate
   * @param: y            Y coordinate
   * @param: maxDistance  Maximum distance to look for a POI
   */
  public POI getPOIAt(float x, float y, double maxDistance) {
    for (POI poi : POIS) {
      if (dist(x, y, poi.getX(), poi.getY()) < maxDistance) return poi;
    }  
    return null;
  }


  /**
   * Finds the route to the POI to which the selected POI is linked, according to the data
   * @param: poi  POI object to link
   */
  public void linkPoi(POI poi) {
    try {
      IDSTART = poi.getGraphNode().id();
      IDEND = POIS.get(poi.getLink()).getGraphNode().id();
      usePathFinder();
    } 
    catch (Exception e) {
      println("Not a valid POI.");
    }
  }


  /**
   * Calls the draw method of each stored POI object
   * @param: canvas    PGraphics object to draw on
   * @param: nodeSize  Size of the POIs
   */
  public void drawNodes(PGraphics canvas, float nodeSize) {
    canvas.pushStyle();
    canvas.noStroke();
    canvas.fill(0);

    for (POI poi : POIS) {
      poi.draw(canvas, nodeSize);
    }

    canvas.popStyle();
  }


  /**
   * Calls the draw method for each stored Lane object
   * @param: canvas      PGraphics object to draw on
   * @param: nodeSize    Size of the ellipses
   * @param: arrowSize   Size of the arrows
   * @param: arrow       Wether to draw arrows or not
   * @param: lineCol     Color of the line
   */
  public void drawLanes(PGraphics canvas, float nodeSize, float arrowSize, boolean arrow) {
    canvas.pushStyle();
    canvas.noFill();
    canvas.stroke(color(#E0E3E5));

    for (Lane lane : LANES) {
      lane.draw(canvas, nodeSize / 2.0f, arrowSize, arrow);
    }
    canvas.popStyle();
  }


  /**
   * Draws the route between the START and END GraphNode instances
   * @param: canvas   PGraphics object to draw on
   * @param: lineCol  Color of the line that represents the route
   */
  public void drawRoute(PGraphics canvas, int lineCol) {
    if (ROUTE.length >= 2) {
      canvas.pushStyle();
      canvas.stroke(lineCol);
      canvas.noFill();

      for (int i = 1; i < ROUTE.length; i++) {
        canvas.line(ROUTE[i-1].xf(), ROUTE[i-1].yf(), ROUTE[i].xf(), ROUTE[i].yf());
      }
    }
    canvas.fill(0);
  }


  /**
   *
   */
  private  PVector scalarProjection(PVector point, PVector l1, PVector l2) {
    PVector l1p = PVector.sub(point, l1);
    PVector line = PVector.sub(l2, l1);
    float lineLength = line.mag();
    line.normalize();
    float dotProd = l1p.dot(line);
    line.mult( dotProd );
    return line.mag() > lineLength ? l2 : dotProd < 0 ? l1 : PVector.add(l1, line);
  }


  /**
   * Places a POI in the roadnetwork
   * @param: poi  POI object to be placed
   */
  private void placePoi(POI poi) {
    int nodeID = NODES.size();
    Lane closestLane = null;
    PVector clstPointCoord = null;
    Float mindist = Float.NaN;
    PVector p = new PVector(poi.getX(), poi.getY());

    for (Lane lane : LANESMAP.get(poi.getDistrict())) {
      if (!(lane.getStart() instanceof POI) && !(lane.getEnd() instanceof POI)) {
        PVector coord1 = lane.getFrom();
        PVector coord2 = lane.getTo();
        PVector possible = scalarProjection(p, coord1, coord2);

        if (p.dist(possible) < mindist || mindist.isNaN()) {
          mindist = p.dist(possible);
          closestLane = lane;
          clstPointCoord = possible;
        }
      }
    }

    if (closestLane != null && clstPointCoord != null) {
      Node n = new Node(nodeID, closestLane.getDistrict(), clstPointCoord.x, clstPointCoord.y, GRAPH);
      NODES.add(n);

      LANES.add(new Lane(closestLane.getLaneName(), closestLane.getAccess(), closestLane.getDistrict(), closestLane.getStart(), n, 0.0497097, GRAPH));
      LANES.add(new Lane(closestLane.getLaneName(), closestLane.getAccess(), closestLane.getDistrict(), n, closestLane.getEnd(), 0.0497097, GRAPH));
      LANES.add(new Lane(closestLane.getLaneName(), closestLane.getAccess(), closestLane.getDistrict(), poi, n, 0.0497097, GRAPH));
      LANES.add(new Lane(closestLane.getLaneName(), closestLane.getAccess(), closestLane.getDistrict(), n, poi, 0.0497097, GRAPH));

      GRAPH.removeEdge(closestLane.getStart().getID(), closestLane.getEnd().getID());
      LANES.remove(closestLane);
    }
  }


  /**
   * Changes the values of ALGORITHM and FINDER
   * @param: algorithm  New value of ALGORITHM
   */
  public void changeAlgorithm(int algorithm) {
    ALGORITHM = algorithm;
    makePathFinder();
    usePathFinder();
  }
}
