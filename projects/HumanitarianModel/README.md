# **HumanitarianModel**
This model is based on fuzzy logic inference. It consists in assigning a vulnerability index to each hospital, based on population density and traffic congestion. This index is the input for an optimization system, where a distance matrix assigns one hospital per each school. This script allows to visualize Lima's network with hospitals and schools, and shows a path by clicking each hospital or school.

## **Contact Info**
**Vanesa Alcántara**: v.alcantarapanta@alum.up.edu.pe | https://github.com/vaap1997 .
**Jesús García**: je.garciar@up.edu.pe | https://github.com/JesusGarcia98

## **Legal Description**
This code uses GNU Affero General Public License v3.0. For more information: https://www.gnu.org/licenses/gpl-3.0.en.html

## **Grapho (Class)**
1. Constructor
```java
new Grapho(String roadPath, String poiPath)
```
2. Methods
    - *`usePathFinder(IGraphSearch pf)`*: Finds the route between the nodes.
    - *`makePathFinder(Graph gs, int pathFinder)`*: Creates a pathFinder object with a certain pathFinder algorithm (BFS, DIJKSTRA, ASHCROWFLIGHT, ASHMANHATTAN).
    - *`draw(PGraphics canvas, boolean zoom, int mousex, int mousey)`*: Draws roads, hospitals and schools.
    - *`getPOIAt(float x, float y, double maxDistance)`*: Get the POI at the mouse location.
    - *`linkPoi(POI poi)`*: Find the POI to which the selected POI is linked, according to the data.
    - *`drawNodes(PGraphics canvas, float nodeSize)`*: Draws the hospitals and schools with a different color each.
    - *`drawEdges(PGraphics canvas, ArrayList<Lane> lanes, int lineCol, float sWeight, boolean arrow, float nodeSize)`*: Draws the roads of the network.
    - *`drawRoute(PGraphics canvas, GraphNode[] r, int lineCol, float sWeight)`*: Draws the route between the selected POI and the POI its linked with.
    - *`drawArrow(PGraphics canvas, GraphNode fromNode, GraphNode toNode, float nodeRad, float arrowSize)`*: Draw a line between a node selected and the mouse.
    - *`loadRoadsToGraph(Graph g, String geojson )`*:Reads the JSON file with the roads of the network.
    - *`scalarProjection(PVector point, PVector l1, PVector l2)`*: Check if it the point is inside the line.
    - *`getNearestPointOnLine(PVector c, PVector a, PVector b)`*: Connects a POI to the nearest road.
    - *`placePoi(Graph g, POI poi)`*: Connect the poi to the road network.
    - *`evaluateWay(String type)`*: Return true if it is one way and false if it is both ways.
    - *`assignDistrict(String type)`*: Unify districts names with the ones inside the roads.
    - *`evaluateAccess(String type)`*: Unify districts names with the ones inside the roads.
    - *`toXY(float lat, float lon)`*: Map the lat lon to a UTM coordinates,Map the UTM to the canvas size.
    - *`distanciaCoord(float lng1, float lat1, float lng2, float lat2)`*: Shows distance between two coordinates given.
    - *`findBound(JSONArray lanes)`*: Look at every point in an JSON and get the min and max Latitutes y Longitudes.
    - *`deleteLane(int initNode, int endNode)`*: Deletes a road from the network.
    - *`addLane(int initNode, int endNode)`*: Add a road from the network.

## **Lane (Class)**
1. Constructor
```java
new Lane(String name, String access, String district, Graph g, Node initNode, Node finalNode, double  distance )
```
2. Methods
    - *`getFrom()`*: Get the initial node of a PVector.
    - *`getTo()`*: Get the final node of a PVector.

## **Node (Class)**
1. Constructor
```java
new Node( Graph g, int nodeID, float pointX, float pointY)
```
2. Methods
    - *`setDistrict(String district)`*: Assign a district to a node.
    - *`ssetType(String type)`*: Assign a street type to a node (hospital and school). Street by default.
    - *`connect(Graph g, int prevNodeID, double costOut)`*: Create an edge(LINK) between the current node and the prevNode given.
    - *`connectBoth(Graph g, int prevNodeID, double costOut)`*: Create two edges(LINKS) one from the actual node and the prevNode given, and viceversa.
    - *`draw(PGraphics canvas, float nodeSize)`*: Draws schools(green) and hospitals(blue).

## **POI (Class)**
1. Constructor
```java
new POI(int ID, Graph g, int nodeID, float pointX, float pointY, int capacity, String access, String district)
```
2. Methods
    - *`setLink(int link)`*: Assign the id of the origin or destiny respectively.
    - *`setLinkJSON(int linkJSON)`*: Assign the id from the JSON import.

## **Projection (Class)**
This class is imported from (ABM repository)[https://github.com/markusand/ABM] from Mark Vilella

## **Zoom (Class)**
1. Constructor
Initialize with these if it is the first time or if you are not using keystone kernel.
```java
new Zoom(int w, int h, PGraphics canvas)
```
Initialize with these if keystone kernel data is available.
```java
Zoom(PApplet parent, int w, int h, PGraphics canvas)
```
2. Methods
    - *`toXYAntiZoom(PVector xy)`*: Map mouse to principal sketch coordinates to create a general POI.
    - *`drawVisor(PGraphics canvas)`*: Show the selected area on the principal sketch.
    - *`loadJSON(String path)`*: Load the two guide points > left and up / right and down.
    - *`saveJSON()`*: Update the two guide points > left and up / right and down.
    - *`mousePressed()`*: Select startNode.
    - *`mouseReleased()`*: Select endNode.
    - *`mouseClicked()`*: Finds paths from startNode to endNode.
