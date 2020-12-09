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
 * Node - Class which represents an intersection of roads
 * @see:       Lane, Grapho
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1 
 */
public class Node {
  protected int nodeID;
  protected float X;
  protected float Y;
  protected String DISTRICT;
  protected String TYPE = "street";
  protected GraphNode GNODE;


  /**
   * Creates a Node object with parameters that define itself
   * @param: nodeID    ID of the object
   * @param: district  District where the object belongs
   * @param: pointX    X coordinate
   * @param: pointY    Y coordinate
   * @param: graph     Graph object to place in
   */
  public Node(int id, String district, float pointX, float pointY, Graph graph) { 
    nodeID = id;
    DISTRICT = district;
    X = pointX;
    Y = pointY;
    toGraphNode(graph);
  }


  /**
   * "Transforms" the object into a GraphNode instance to place it in a Graph object
   * @param: graph     Graph object to place in
   */
  protected void toGraphNode(Graph graph) {
    GNODE = new GraphNode(nodeID, X, Y);
    graph.addNode(GNODE);
  }


  /**
   * Gets the value of the GNODE attribute
   * @returns: GraphNode  Value of GNODE
   */
  protected GraphNode getGraphNode() {
    return GNODE;
  }


  /**
   * Gets the value of the ID attribute
   * @returns: int  Value of ID
   */
  protected int getID() {
    return nodeID;
  }


  /**
   * Gets the value of the X attribute
   * @returns: float  Value of X
   */
  protected float getX() {
    return X;
  }


  /**
   * Gets the value of the Y attribute
   * @returns: float  Value of Y
   */
  protected float getY() {
    return Y;
  }


  /**
   * Gets the value of the DISTRICT attribute
   * @returns: district  Value of DISTRICT
   */
  protected String getDistrict() {
    return DISTRICT;
  }


  /**
   * Sets the value of the DISTRICT attribute
   * @param: district  New value of DISTRICT
   */
  protected void setDistrict(String district) {
    DISTRICT = district;
  }


  /**
   * Gets the value of the TYPE attribute
   * @returns: String  Value of TYPE
   */
  protected String getType() {
    return TYPE;
  }


  /**
   * Sets the value of the TYPE attribute
   * @param: type  New value of TYPE
   */
  protected void setType(String type) {
    TYPE = type;
  }


  /**
   * Creates a one-way link between this object and another one
   * @param: otherNodeID  ID of the Node object to link with
   * @param: costOut      Cost of linking the two Node objects
   */
  protected void connect(Graph g, int otherNodeID, double costOut) {
    g.addEdge(otherNodeID, nodeID, costOut);
  }


  /**
   * Creates a two-way link between this object and another one
   * @param: otherNodeID  ID of the Node object to link with
   * @param: costOut      Cost of linking the two Node objects
   */
  protected void connectBoth(Graph g, int otherNodeID, double costOut) {
    g.addEdge(otherNodeID, nodeID, costOut);
  }
}


/**
 * POI - Class which represents an school or hospital in a roadnetwork. Extends Node
 * @see:       Node
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1 
 */
public class POI extends Node {
  private int ID;
  private int LINK = -1;


  /**
   * Creates a POI object with parameters that define itself
   * @param: nodeID  ID of the Node object
   * @param: district  District where the object will be placed
   * @param: pointX  X coordinate
   * @param: pointY  Y coordinate
   */
  public POI(int nodeID, int id, String district, float pointX, float pointY, Graph graph) {
    super(nodeID, district, pointX, pointY, graph);
    ID = id;
  }


  /**
   * Sets the value of the LINK attribute
   * @param: link  New value of LINK
   */
  public void setLink(int link) {
    LINK = link;
  }


  /**
   * Gets the value of the LINK attribute
   * @returns: int  Value of LINK
   */
  public int getLink() {
    return LINK;
  }


  /**
   * Draws an ellipse and fills it depending on the TYPE attribute
   * @param: canvas    PGraphics object to draw on
   * @param: nodeSize  Size of the ellipse
   */
  public void draw(PGraphics canvas, float nodeSize) {
    canvas.fill(255, 0, 0);

    if (TYPE.equals("School")) canvas.fill(0, 255, 0);
    else if (TYPE.equals("Hospital")) canvas.fill(0, 0, 255);

    canvas.ellipse(GNODE.xf(), GNODE.yf(), nodeSize, nodeSize);
  }
}
