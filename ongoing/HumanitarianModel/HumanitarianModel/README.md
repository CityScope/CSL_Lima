# **HumanitarianModel**
This model is based on fuzzy logic inference. It consists in assigning a vulnerability index to each hospital, based on population density and traffic congestion. This index is the input for an optimization system, where a distance matrix assigns one hospital per each school. This script allows to visualize Lima's roadnetwork along with hospitals and schools, and shows a path by clicking each hospital or school.


## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .
**Jesús García**: je.garciar@alum.up.edu.pe | https://github.com/JesusGarcia98


## **Legal Description**
This code uses GNU Affero General Public License v3.0. For more information: https://www.gnu.org/licenses/gpl-3.0.en.html


## **Configuration (Class)**
1. Constructor
```java
new Configuration(String roadPath, String poiPath, PApplet parent, int w, int h)
```
2. Methods
    - *`runSketch(String[] zoomName)`*: Runs the Zoom PApplet with a name.
    - *`drawGrapho(PGraphics canvas, boolean zoom)`*: Calls the **_draw(PGraphics canvas, boolean zoom)_** method of Grapho.
    - *`drawVisor(PGraphics canvas)`*: Calls the **_drawVisor(PGraphics canvas)_** method of Zoom.
    - *`changeAlgorithm(int algorithm)`*: Calls the **_changeAlgorithm(int algorithm))_** method of Graph.
    - *`getSide1()`*: Calls the **_getSide1()_** method of Zoom.
    - *`setSide1(int x, int y)`*: Calls the **_setSide1(int x, int y)_** method of Zoom.
    - *`reduceSide1()`*: Calls the reduceSide1 method of Zoom.
    - *`increaseSide1()`*: Calls the increaseSide1 method of Zoom.
    - *`getSide2()`*: Calls the **_getSide2()_** method of Zoom.
    - *`setSide2(int x, int y)`*: Calls the **_setSide2(int x, int y)_** method of Zoom.
    - *`reduceSide2()`*: Calls the reduceSide2 method of Zoom.
    - *`increaseSide2()`*: Calls the increaseSide2 method of Zoom.


## **Grapho (Class)**
1. Constructor
```java
new Grapho(String roadPath, String poiPath)
```
2. Methods
    - *`loadNodeslanes(String roadPath)`*: Retrieves the data from the geoJSON file with the roads.
    - *`loadPOIS(String poiPath)`*: Retrieves the data from the geoJSON file with the schools and hospitals.
    - *`evaluateAccess(String type)`*: Assigns "WALK", "DRIVE" or "ALL" depending on a road type.
    - *`evaluateWay(String type)`*: Assigs one-way or two-way depending on a road type.
    - *`assignDistrict(String type)`*: Standardizes district name.
    - *`toXY(float lat, float lon)`*: Maps (lat, lon) to UTM coordinates and maps the UTM to the canvas size.
    - *`findBounds(JSONArray lanes)`*: Finds the minimum and maximum latitutudes and longitudes of a JSONArray.
    - *`getGeoProportion()`*:
    - *`findDistance(float lng1, float lat1, float lng2, float lat2)`*: Finds the geographical distance between two points.
    - *`makePathFinder()`*: Creates an IGraphSearch object using a determined algorithm (BFS, DIJKSTRA, ASHCROWFLIGHT, ASHMANHATTAN).
    - *`usePathFinder()`*: Finds the route between two nodes.
    - *`getGraph()`*: Gets the value of the **_GRAPH_** attribute.
    - *`toggleShow()`*: Toggles the values of **_SHOW_**.
    - *`draw(PGraphics canvas, boolean zoom)`*: Calls its drawLanes and drawNodes methods.
    - *`deleteLane(int initNode, int endNode)`*: Deletes a road from the network.
    - *`addLane(int initNode, int endNode)`*: Adds a road back to the network.
    - *`getPOIAt(float x, float y, double maxDistance)`*: Gets a POI instance at a given (X, Y) location, within a certain distance.
    - *`linkPoi(POI poi)`*: Finds the route to the POI to which the selected POI is linked, according to the data.
    - *`drawNodes(PGraphics canvas, float nodeSize)`*: Calls the **_draw(PGraphics canvas, float nodeSize)_ method of each stored POI object.
    - *`drawLanes(PGraphics canvas, float nodeSize, float arrowSize, boolean arrow)`*: Calls the **_draw(PGraphics canvas, float nodeRad, float arrowSize, boolean arrow)_** method for each stored Lane object.
    - *`drawRoute(PGraphics canvas, int lineCol)`*: Draws the route between the **_START_** and **_END_** GraphNode instances.
    - *`scalarProjection(PVector point, PVector l1, PVector l2)`*: Check if it the point is inside the line.
    - *`placePoi(POI poi)`*: Places a POI in the roadnetwork.
    - *`changeAlgorithm(int algorithm)`*: Changes the values of **_ALGORITHM_** and **_FINDER_**.


## **Lane (Class)**
1. Constructor
```java
new Lane(String name, String access, String district, Node initNode, Node finalNode, double costOut, Graph graph)
```
2. Methods
    - *`toEdge(Graph graph)`*: "Transforms" the object into a GraphEdge instance to place it in a Graph object.
    - *`getAccess()`*: Gets the value of the **_ACCESS_** attribute.
    - *`getLaneName()`*: Gets the value of the **_NAME_** attribute.
    - *`getEdge()`*: Gets the value of the **_EDGE_** attribute.
    - *`getCost()`*: Gets the value of the **_COST_** attribute.
    - *`getDistrict()`*: Gets the value of the **_DISTRICT_** attribute.
    - *`getStart()`*: Gets the value of the **_START_** attribute.
    - *`getEnd()`*: Gets the value of the **_START_** attribute.
    - *`setErase(boolean erase)`*: Sets the value of the **_ERASE_** attribute.
    - *`getFrom()`*: Get the initial node of a PVector.
    - *`getTo()`*: Get the final node of a PVector.
    - *`draw(PGraphics canvas, float nodeRad, float arrowSize, boolean arrow)`*: Draws a line with different color depending on the **_ACCESS_** attribute.
    - *`drawArrow(PGraphics canvas, float nodeRad, float arrowSize)`*: Draws the object as and arrow.


## **Node (Class)**
1. Constructor
```java
new Node(int id, String district, float pointX, float pointY, Graph graph)
```
2. Methods
    - *`toGraphNode(Graph graph)`*: "Transforms" the object into a GraphNode instance to place it in a Graph object.
    - *`getGraphNode()`*: Gets the value of the **_GNODE_** attribute.
    - *`getID()`*: Gets the value of the **_ID_** attribute.
    - *`getX()`*: Gets the value of the **_X_** attribute.
    - *`getY()`*: Gets the value of the **_Y_** attribute.
    - *`getDistrict()`*: Gets the value of the **_DISTRICT_** attribute.
    - *`setDistrict(String district)`*: Sets the value of the **_DISTRICT_** attribute.
    - *`getType()`*: Gets the value of the **_TYPE_** attribute.
    - *`setType(String type)`*:  Sets the value of the **_TYPE_** attribute.
    - *`connect(Graph g, int otherNodeID, double costOut)`*: Creates a one-way link between this object and another one.
    - *`connectBoth(Graph g, int otherNodeID, double costOut)`*: Creates a two-way link between this object and another one.


## **POI (Class extends Node)**
1. Constructor
```java
new POI(int nodeID, int id, String district, float pointX, float pointY, Graph graph)
```
2. Methods
    - *`setLink(int link)`*: Sets the value of the **_LINK_** attribute.
    - *`getLink()`*: Gets the value of the **_LINK_** attribute.
    - *`draw(PGraphics canvas, float nodeSize)`*: Draws an ellipse and fills it depending on the **_TYPE_** attribute.


## **Zoom (Class)**
1. Constructor
```java
new Zoom(PApplet parent, Grapho grapho, int w, int h)
```
2. Methods
    - *`toXYAntiZoom(PVector xy)`*: Maps mouse to principal sketch coordinates.
    - *`drawVisor(PGraphics canvas)`*: Draws the selected area of the principal sketch.
    - *`loadJSON(String path)`*: Loads the two guiding points from a JSON file
    - *`saveJSON()`*: Saves the current values of the guiding points to a JSON file.
    - *`mousePressed()`*: Selects start node.
    - *`mouseReleased()`*: Selects end node.
    - *`mouseClicked()`*: Finds path from start node to end node.
    - *`getSide1()`*: Gets the value of the SIDE1 attribute.
    - *`setSide1(int x, int y)`*: Sets the value of the SIDE1 attribute.
    - *`reduceSide1()`*: Reduces the (x, y) coordinates of SIDE1 by 1.
    - *`increaseSide1()`*: Increases the (x, y) coordinates of SIDE1 by 1.
    - *`getSide2()`*: Gets the value of the SIDE2 attribute.
    - *`setSide2(int x, int y)`*: Sets the value of the SIDE2 attribute.
    - *`reduceSide2()`*: Reduces the (x, y) coordinates of SIDE2 by 1.
    - *`increaseSide2()`*: Increases the (x, y) coordinates of SIDE1 by 1.


## **Projection (Class)**
This class is imported from (ABM repository)[https://github.com/markusand/ABM] from Mark Vilella.
