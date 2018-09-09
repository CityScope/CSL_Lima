/**
 ** @copyright: Copyright (C) 2018
 ** @authors:   Vanesa Alcántara & Jesús García
 ** @version:   1.0 
 ** @legal :
 This file is part of HumanitarianModel.
 
 HumanitarianModel is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 HumanitarianModel is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License
 along with HumanitarianModel.  If not, see <http://www.gnu.org/licenses/>.
 **/

/**
 *Import Path_Finder library created by Peter Lager 
 *Available for processing:(http://www.lagers.org.uk/pfind/download.html)
 **/

import pathfinder.*;
import java.util.Map;

public class Grapho {
  public IntDict nodesCoords = new IntDict();
  public PVector[] boundaries;
  public ArrayList<Node> nodes = new ArrayList();
  public ArrayList<Lane> lanes = new ArrayList();
  public ArrayList<POI> pois = new ArrayList();
  public HashMap<String, ArrayList<Lane>> hml = new HashMap<String, ArrayList<Lane>>();
  Set<String> districts = new HashSet<String>();

  Graph gs;
  int start;
  int end;
  int algorithm;
  GraphNode[] rNodes;
  IGraphSearch pathFinder;
  GraphNode startNode, endNode;
  boolean selectMode = false, show = true, zoom; 
  long time; 
  double proportion;

  /**
   *Constructor for Grapho
   **/
  public Grapho(String roadPath, String poiPath) {  
    gs = new Graph();
    loadRoadsToGraph1(gs, roadPath);
    loadPoisToGraph1(gs, poiPath );
    //loadRoadsToGraph(gs, roadPath);
    //loadPoisToGraph(gs, poiPath );
    start = pois.get(0).id;
    end = pois.get(pois.get(0).link).id;
    algorithm = 3;
    pathFinder = makePathFinder(gs, algorithm);
    usePathFinder(pathFinder);
    proportion = getGeoProportion();
  }

  public double getGeoProportion() {
    double costOut = distanciaCoord(-12.074512, -77.051677, -12.074176, -77.050593);
    PVector point1 = toXY(-12.074512, -77.051677);
    PVector point2 = toXY( -12.074176, -77.050593);
    return costOut * dist(point1.x, point1.y, point2.x, point2.y);
  }

  /**
   *Finds the route between the nodes
   **/
  void usePathFinder(IGraphSearch pf) {
    time = System.nanoTime();
    pf.search(start, end, true);
    time = System.nanoTime() - time;
    rNodes = pf.getRoute();
  }

  /**
   *Creates a pathFinder object with a certain path finder algorithm
   **/
  IGraphSearch makePathFinder(Graph gs, int pathFinder) {
    IGraphSearch pf = null;
    float f = 1.0f;
    switch(pathFinder) {
    case 0:
      pf = new GraphSearch_DFS(gs);
      break;
    case 1:
      pf = new GraphSearch_BFS(gs);
      break;
    case 2:
      pf = new GraphSearch_Dijkstra(gs);
      break;
    case 3:
      pf = new GraphSearch_Astar(gs, new AshCrowFlight(f));
      break;
    case 4:
      pf = new GraphSearch_Astar(gs, new AshManhattan(f));
      break;
    }
    return pf;
  } 

  /**
   *Draws roads, hospitals and schools
   **/
  void draw(PGraphics canvas, boolean zoom, int mousex, int mousey) {
    canvas.background(255);
    canvas.pushMatrix();

    drawLanes(canvas, lanes, color(#E0E3E5), 1, false, 5);
    if (zoom) drawNodes(canvas, 0.5);
    else drawNodes(canvas, 5);

    if (show) {
      drawRoute(canvas, rNodes, color(200, 0, 0), 1);
    }
    if (selectMode) { 
      canvas.stroke(0);
      if (endNode != null)
        canvas.line(startNode.xf(), startNode.yf(), endNode.xf(), endNode.yf());
      else
        canvas.line(startNode.xf(), startNode.yf(), mousex, mousey);
    }
    canvas.popMatrix();
  }

  /**
   *Deletes a road from the network
   **/
  public boolean deleteLane(int initNode, int endNode) {
    for (Lane l : lanes) {
      if ((l.initNode.id == initNode) && (l.finalNode.id == endNode)) {
        gs.removeEdge(initNode, endNode);
        l.erase = true;
        return true;
      }
    }
    return false;
  }

  /**
   *Add a road from the network
   **/
  public boolean addLane(int initNode, int endNode) {
    for (Lane l : lanes) {
      if ((l.initNode.id == initNode) && (l.finalNode.id == endNode)) {
        //
        gs.addEdge(initNode, endNode, proportion*dist(l.initNode.x,l.initNode.y,l.finalNode.y,l.finalNode.y));
        l.erase = false;
        return true;
      }
    }
    return false;
  }

  /**
   *Get the POI at the mouse location
   **/
  public POI getPOIAt(float x, float y, double maxDistance) {
    for (POI poi : pois) {
      if (dist(x, y, poi.x, poi.y)< maxDistance) return poi;
    }  
    return null;
  }


  /**
   *Find the POI to which the selected POI is linked, according to the data
   **/
  public void linkPoi(POI poi) {
    try {
      start = poi.n.id();
      end = pois.get(poi.link).n.id();
      usePathFinder(pathFinder); 
      startNode = endNode = null;
    } 
    catch (Exception e) {
      println("Not a valid POI.");
    }
  }

  public void refresh() {
  }

  /**
   *Draws the hospitals and schools with a different color each
   **/
  public void drawNodes(PGraphics canvas, float nodeSize) {
    canvas.pushStyle();
    canvas.noStroke();
    canvas.fill(0);
    for (Node node : nodes) {
      if (node instanceof POI) {
        if (node.type.equals("School")) canvas.fill(0, 255, 0);
        else if (node.type.equals("Hospital")) canvas.fill(0, 0, 255);
        canvas.ellipse(node.n.xf(), node.n.yf(), nodeSize, nodeSize);
      }
    }
    canvas.popStyle();
  }

  /**
   *Draws the roads of the network
   **/
  public void drawLanes(PGraphics canvas, ArrayList<Lane> lanes, int lineCol, float sWeight, boolean arrow, float nodeSize) {
    if (lanes != null) {
      canvas.pushStyle();
      canvas.noFill();
      canvas.stroke(lineCol);
      for (Lane l : lanes) {
        if (arrow) {
          drawArrow(canvas, l.edge.from(), l.edge.to(), nodeSize / 2.0f, 6);
        } else {
            if (l.access.equals("WALK")) canvas.stroke(150);
            else if (l.access.equals("DRIVE")) canvas.stroke(255, 255, 0);
            //canvas.stroke(150, 80);
            canvas.line(l.edge.from().xf(), l.edge.from().yf(), l.edge.to().xf(), l.edge.to().yf());
          
        }
      }
      canvas.popStyle();
    }
  }

  /**
   *Draws the route between the selected POI and the POI its linked with
   **/
  public void drawRoute(PGraphics canvas, GraphNode[] r, int lineCol, float sWeight) {
    if (r.length >= 2) {
      canvas.pushStyle();
      canvas.stroke(lineCol);
      canvas.noFill();
      for (int i = 1; i < r.length; i++)
        canvas.line(r[i-1].xf(), r[i-1].yf(), r[i].xf(), r[i].yf());
    }
    canvas.fill(0);
  }

  /**
   *Draw a line between a node selected and the mouse
   **/
  public void drawArrow(PGraphics canvas, GraphNode fromNode, GraphNode toNode, float nodeRad, float arrowSize) {
    float fx, fy, tx, ty;
    float ax, ay, sx, sy, ex, ey;
    float awidthx, awidthy;

    fx = fromNode.xf();
    fy = fromNode.yf();
    tx = toNode.xf();
    ty = toNode.yf();

    float deltaX = tx - fx;
    float deltaY = (ty - fy);
    float d = sqrt(deltaX * deltaX + deltaY * deltaY);

    sx = fx + (nodeRad * deltaX / d);
    sy = fy + (nodeRad * deltaY / d);
    ex = tx - (nodeRad * deltaX / d);
    ey = ty - (nodeRad * deltaY / d);
    ax = tx - (nodeRad + arrowSize) * deltaX / d;
    ay = ty - (nodeRad + arrowSize) * deltaY / d;

    awidthx = - (ey - ay);
    awidthy = ex - ax;

    canvas.noFill();
    canvas.stroke(160, 128);
    canvas.line(sx, sy, ax, ay);

    canvas.noStroke();
    canvas.fill(48, 128);
    canvas.beginShape(TRIANGLES);
    canvas.vertex(ex, ey);
    canvas.vertex(ax - awidthx, ay - awidthy);
    canvas.vertex(ax + awidthx, ay + awidthy);
    canvas.endShape();
  } 

  /**
   *Reads the JSON file with the roads of the network
   **/
  public void loadRoadsToGraph(Graph g, String geojson ) {
    JSONObject roadNetwork=loadJSONObject(geojson);
    JSONArray lnes =roadNetwork.getJSONArray("features");
    boundaries = findBound(lnes);
    int nodeID = 0;
    for (int i = 0; i<lnes.size(); i++) {
      JSONObject lane =lnes.getJSONObject(i);
      JSONObject props= lane.getJSONObject("properties");
      String access = props.isNull("type") ? "ALL" : evaluateAccess( props.getString("type") );
      String name = props.isNull("name") ? "null" : props.getString("name");
      String district = props.isNull("UBIGEO") ? "null" : props.getString("UBIGEO");
      boolean oneWay=props.isNull("oneway")? false:props.getInt("oneway")==1? true:false;
      String direction=props.isNull("direction")? null: props.getString("direction");
      JSONArray points=lane.getJSONObject("geometry").getJSONArray("coordinates");              
      Node prevNode = null;
      for (int j=0; j<points.size(); j++) {
        String LATLON = str(points.getJSONArray(j).getFloat(1)) + "/" +  str(points.getJSONArray(j).getFloat(0));
        PVector point=toXY(points.getJSONArray(j).getFloat(1), points.getJSONArray(j).getFloat(0));
        Node currNode;
        if (! nodesCoords.hasKey(LATLON)) {
          nodesCoords.set(LATLON, nodeID);
          /*z=0*/
          Node n = new Node(g, nodeID, point.x, point.y);
          n.setDistrict(district);
          nodes.add(n);
          nodeID++;
        }
        currNode = nodes.get(nodesCoords.get(LATLON));
        if (prevNode != null) {
          double costOut = distanciaCoord(points.getJSONArray(j-1).getFloat(0), 
            points.getJSONArray(j-1).getFloat(1), 
            points.getJSONArray(j).getFloat(0), 
            points.getJSONArray(j).getFloat(1));
          lanes.add(new Lane(name, access, district, g, prevNode, currNode, costOut));
          if (! oneWay) lanes.add(new Lane(name, access, district, g, currNode, prevNode, costOut));
        }
        prevNode = currNode;
      }
    }
    for (Lane l : lanes) {
      ArrayList<Node> ln = new ArrayList<Node>();
      ln.add(l.initNode);
      ln.add(l.finalNode);
    }
  }

  /**
   *Reads the JSON file with the roads of the network
   **/
  public void loadRoadsToGraph1(Graph g, String geojson ) {
    print("Loading roads...");
    JSONObject roadNetwork=loadJSONObject(geojson);
    JSONArray lnes =roadNetwork.getJSONArray("features");
    boundaries = findBound(lnes);
    int nodeID = 0;
    for (int i = 0; i<lnes.size(); i++) {
      JSONObject lane =lnes.getJSONObject(i);
      JSONObject props= lane.getJSONObject("properties");
      String access = props.isNull("CATEG_TXT") ? "ALL" : evaluateAccess( props.getString("CATEG_TXT") );
      String name = props.isNull("NOMBRE_VIA") ? "null" : props.getString("NOMBRE_VIA");
      String district = props.isNull("DISTRITO") ? "null" : props.getString("DISTRITO");
      boolean oneWay=props.isNull("CATEG_TXT")? false:evaluateWay(props.getString("CATEG_TXT"));
      String direction=props.isNull("direction")? null: props.getString("direction");
      JSONArray points=lane.getJSONObject("geometry").getJSONArray("coordinates").getJSONArray(0);              
      Node prevNode = null;
      for (int j=0; j<points.size(); j++) {
        String LATLON = str(points.getJSONArray(j).getFloat(1)) + "/" +  str(points.getJSONArray(j).getFloat(0));
        PVector point=toXY(points.getJSONArray(j).getFloat(1), points.getJSONArray(j).getFloat(0));
        Node currNode;
        if (! nodesCoords.hasKey(LATLON)) {
          nodesCoords.set(LATLON, nodeID);
          /*z=0*/
          Node n = new Node(g, nodeID, point.x, point.y);
          n.setDistrict(district);
          nodes.add(n);
          nodeID++;
        }
        currNode = nodes.get(nodesCoords.get(LATLON));
        if (prevNode != null) {
          double costOut = distanciaCoord(points.getJSONArray(j-1).getFloat(0), 
            points.getJSONArray(j-1).getFloat(1), 
            points.getJSONArray(j).getFloat(0), 
            points.getJSONArray(j).getFloat(1));
          Lane ln = new Lane(name, access, district, g, prevNode, currNode, costOut);
          lanes.add(ln);
          if (hml.containsKey(ln.district)) {
            hml.get(ln.district).add(ln);
          } else {
            ArrayList<Lane> lns = new ArrayList<Lane>();
            lns.add(ln);
            hml.put(ln.district, lns);
          }         
          if (! oneWay) lanes.add(new Lane(name, access, district, g, currNode, prevNode, costOut));
          //districts.add(district);
        }
        prevNode = currNode;
      }
    } 

    println("loaded");
  }

  /**
   *Reads the JSON file with the schools and hospitals
   **/
  public void loadPoisToGraph1(Graph g, String geojson ) {  
    //ArrayList<POI> pois = new ArrayList();
    JSONObject roadNetwork=loadJSONObject(geojson);
    JSONArray lnes =roadNetwork.getJSONArray("features"); 
    for (int i = 0; i<lnes.size(); i++) {
      int nodeID = nodes.size();
      JSONObject lane =lnes.getJSONObject(i);
      JSONObject props= lane.getJSONObject("properties");
      int poiID = props.isNull("field_1") ? -1 : props.getInt("field_1");
      String district = props.isNull("NOMBDIST") ? "null" : assignDistrict(props.getString("NOMBDIST"));
      String type = props.isNull("Type") ? "street" : props.getString("Type");
      String access = props.isNull("Type") ? "ALL" : evaluateAccess( props.getString("Type") );
      int link = props.isNull("Link") ? -1 : props.getInt("Link");
      String LATLON = str(props.getFloat("C_LAT")) + "/" +  str(props.getFloat("C_LONG"));
      PVector point = toXY(props.getFloat("C_LAT"), props.getFloat("C_LONG"));
      nodesCoords.set(LATLON, nodeID);   /*REVISAR QUE PASARIA CON POI EN MISMO LUGAR O EN LAS CALLES*/
      POI p = new POI(poiID, g, nodeID, point.x, point.y, 30, access, district);
      p.setType(type);
      p.setLink(link);
      nodes.add(p);
      pois.add(p);
      placePoi(g, p);
      poiID ++;
    }
  }

  /**
   *Reads the JSON file with the schools and hospitals
   **/
  public void loadPoisToGraph(Graph g, String geojson ) {  
    IntDict linksBack =  new IntDict();
    JSONObject roadNetwork=loadJSONObject(geojson);
    JSONArray lnes =roadNetwork.getJSONArray("features"); 
    int poiID = 0;
    int linkID = 0;
    for (int i = 0; i<lnes.size(); i++) {
      int nodeID = nodes.size();
      JSONObject lane =lnes.getJSONObject(i);
      JSONObject props= lane.getJSONObject("properties");
      String district = props.isNull("NOMBDIST") ? "null" : props.getString("NOMBDIST");
      if (district.equals("MIRAFLORES") |district.equals("SAN ISIDRO")) {
        String type = props.isNull("Type") ? "street" : props.getString("Type");
        String access = props.isNull("Type") ? "ALL" : evaluateAccess( props.getString("Type") );
        int link = props.isNull("Link") ? -1 : props.getInt("Link");
        String LATLON = str(props.getFloat("C_LAT")) + "/" +  str(props.getFloat("C_LONG"));
        PVector point = toXY(props.getFloat("C_LAT"), props.getFloat("C_LONG"));
        nodesCoords.set(LATLON, nodeID);   /*REVISAR QUE PASARIA CON POI EN MISMO LUGAR O EN LAS CALLES*/
        POI p = new POI(poiID, g, nodeID, point.x, point.y, 30, access, district);
        p.setType(type);
        if (link != -1) {
          linksBack.set(str(pois.get(linkID).ID), poiID);
          p.setLink(pois.get(linkID).ID);
          p.setLinkJSON(link);
          linkID++;
        } 
        nodes.add(p);
        pois.add(p);
        placePoi(g, p);
        poiID ++;
      }
    } 
    for (POI poi : pois) {
      if (poi.link == -1 & linksBack.hasKey(str(poi.ID)) ) poi.setLink(linksBack.get(str(poi.ID)));
    }
  }

  public  PVector scalarProjection(PVector point, PVector l1, PVector l2) {
    PVector l1p = PVector.sub(point, l1);
    PVector line = PVector.sub(l2, l1);
    float lineLength = line.mag();
    line.normalize();
    float dotProd = l1p.dot(line);
    line.mult( dotProd );
    return line.mag() > lineLength ? l2 : dotProd < 0 ? l1 : PVector.add(l1, line);
  }

  /**
   *Connects a POI to the nearest road
   **/
  public PVector getNearestPointOnLine(PVector c, PVector a, PVector b) {
    Float ax, ay, bx, by, cx, cy;
    Float px, py, dAB;
    Float u, x, y;
    PVector d;
    ax = a.x; 
    ay = a.y; 
    bx = b.x; 
    by = b.y; 
    cx = c.x; 
    cy = c.y;
    px = bx-ax; 
    py = by-ay; 
    dAB = px*px+py*py;
    u = ((cx-ax)*px+(cy-ay)*py)/dAB;
    x = ax+u*px; 
    y = ay+u*py;
    d = new PVector(x, y);
    return d;
  }

  /* distance = cost = set on 1.8 */
  public void placePoi(Graph g, POI poi) {
    int nodeID = nodes.size();
    Lane closestLane = null;
    PVector clstPointCoord = null;
    Float mindist = Float.NaN;
    PVector p = new PVector(poi.x, poi.y);
    for (Lane lane : hml.get(poi.district)) {
      if ( ! (lane.initNode instanceof POI) && ! (lane.finalNode instanceof POI) ) {
        PVector coord1 = lane.getFrom() ;
        PVector coord2 = lane.getTo();
        PVector possible = scalarProjection(p, coord1, coord2);
        if (new PVector(poi.x, poi.y).dist(possible) < mindist || mindist.isNaN()) {
          mindist = new PVector(poi.x, poi.y).dist(possible);
          closestLane = lane;
          clstPointCoord = possible;
        }
      }
    }
    if (closestLane != null) {
      Node n = new Node(g, nodeID, clstPointCoord.x, clstPointCoord.y);
      n.setDistrict(poi.district);
      nodes.add(n);
      lanes.add(new Lane(closestLane.name, closestLane.access, closestLane.district, g, closestLane.initNode, n, 0.0497097));
      lanes.add(new Lane(closestLane.name, closestLane.access, closestLane.district, g, n, closestLane.finalNode, 0.0497097));
      lanes.add(new Lane(closestLane.name, closestLane.access, closestLane.district, g, poi, n, 0.0497097));
      lanes.add(new Lane(closestLane.name, closestLane.access, closestLane.district, g, n, poi, 0.0497097));
      g.removeEdge(closestLane.initNode.id, closestLane.finalNode.id);
      lanes.remove(closestLane);
    }
  }

  /**
   *Return true if it is one way and false if it is both ways
   **/
  public boolean evaluateWay(String type) {
    switch(type) {
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
   *Unify districts names with the ones inside the roads
   **/
  public String assignDistrict(String type) {
    switch(type) {
      // Road types
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
   *Assign an access "WALK", "DRIVE" and "ALL" depending on the road type
   **/
  public String evaluateAccess(String type) {
    switch(type) {
      // Road types
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
      // POI types
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
   *Map the lat lon to a UTM coordinates
   *Map the UTM to the canvas size
   *@return a mapped value
   */
  public PVector toXY(float lat, float lon) {
    PVector projPoint = Projection.toUTM(lat, lon, Projection.Datum.WGS84);
    return new PVector(
      map(projPoint.x, boundaries[0].x, boundaries[1].x, 0, width), 
      map(projPoint.y, boundaries[0].y, boundaries[1].y, height, 0)
      );
  } 

  /* MODEL --> -77.022299, -12.090955 = (LON-LAT)*/
  public double distanciaCoord(float lng1, float lat1, float lng2, float lat2) {
    //double radioTierra = 3958.75;//en millas  
    double radioTierra = 6371;//en kilómetros  
    double dLat = Math.toRadians(lat2 - lat1);  
    double dLng = Math.toRadians(lng2 - lng1);  
    double sindLat = Math.sin(dLat / 2);  
    double sindLng = Math.sin(dLng / 2);  
    double va1 = Math.pow(sindLat, 2) + Math.pow(sindLng, 2)  
      * Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2));  
    double va2 = 2 * Math.atan2(Math.sqrt(va1), Math.sqrt(1 - va1));  
    double distancia = radioTierra * va2;  

    return distancia;
  }   

  /**
   * Look at every point in an JSON and get the min and max Latitutes y Longitudes
   **/
  public PVector[] findBound(JSONArray lanes) {
    float minLat = Float.MAX_VALUE;
    float maxLat=-(Float.MAX_VALUE);
    float minLon=Float.MAX_VALUE;
    float maxLon= -(Float.MAX_VALUE);
    for (int i=0; i<lanes.size(); i++) {
      JSONObject lane =lanes.getJSONObject(i);
      JSONArray points=lane.getJSONObject("geometry").getJSONArray("coordinates").getJSONArray(0);
      //JSONArray points=lane.getJSONObject("geometry").getJSONArray("coordinates");
      for (int j=0; j<points.size(); j++) {
        float lat = points.getJSONArray(j).getFloat(1);
        float lon = points.getJSONArray(j).getFloat(0);
        minLat=min(minLat, lat);
        maxLat=max(maxLat, lat);
        minLon=min(minLon, lon);
        maxLon=max(maxLon, lon);
      }
    }
    return new PVector[] {
      Projection.toUTM(minLat, minLon, Projection.Datum.WGS84), 
      Projection.toUTM(maxLat, maxLon, Projection.Datum.WGS84)
    };
  }
}