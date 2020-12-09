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
 * Lane - Class which represents a road
 * @see:       Node, POI, Grapho
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1
 */
public class Lane {
  private String NAME;
  private String ACCESS;   
  private String DISTRICT;
  private Node START;
  private Node END;
  private boolean ERASE;
  private double COST;
  private GraphEdge EDGE;


  /**
   * Creates a Lane object with parameters that define itself
   * @param: name        Name of the road
   * @param: access      Access type of the road
   * @param: district    District where the road is
   * @param: initNode    Starting point of the road
   * @param: finalNode   End point of the road
   * @param: costOut     Distance between its starting an end point
   * @param: graph       Graph object to place in
   */
  public Lane(String name, String access, String district, Node initNode, Node finalNode, double costOut, Graph graph) {
    NAME = name;
    ACCESS = access;
    DISTRICT = district;
    START = initNode;
    END = finalNode;
    COST = costOut;
    toEdge(graph);
  }


  /**
   * "Transforms" the object into a GraphEdge instance to place it in a Graph object
   * @param: graph  Graph object where the Lane will be placed
   */
  private void toEdge(Graph graph) {
    graph.addEdge(START.getID(), END.getID(), COST);
    EDGE = graph.getEdge(START.getID(), END.getID());
  }


  /**
   * Gets the value of the ACCESS attribute
   * @returns: String Value of ACCESS
   */
  public String getAccess() {
    return ACCESS;
  }


  /**
   * Gets the value of the NAME attribute
   * @returns: String Value of NAME
   */
  public String getLaneName() {
    return NAME;
  }


  /**
   * Gets the value of the EDGE attribute
   * @returns: GraphEdge  Value of EDGE
   */
  public GraphEdge getEdge() {
    return EDGE;
  }


  /**
   * Gets the value of the COST attribute
   * @returns: double  Value of COST
   */
  public double getCost() {
    return COST;
  }


  /**
   * Gets the value of the DISTRICT attribute
   * @returns: String  Value of DISTRICT
   */
  public String getDistrict() {
    return DISTRICT;
  }


  /**
   * Gets the value of the START attribute
   */
  public Node getStart() {
    return START;
  }


  /**
   * Gets the value of the START attribute
   */
  public Node getEnd() {
    return END;
  }


  /**
   * Sets the value of the ERASE attribute
   * @param: erase  New value of ERASE
   */
  public void setErase(boolean erase) {
    ERASE = erase;
  }


  /**
   *Get the initial node of a PVector
   **/
  public PVector getFrom() {
    return new PVector(EDGE.from().xf(), EDGE.from().yf());
  }


  /**
   *Get the final node of a PVector
   **/
  public PVector getTo() {
    return new PVector(EDGE.to().xf(), EDGE.to().yf());
  }


  /**
   * Draws a line with different color depending on the ACCESS attribute
   * @param: canvas      PGraphics object to draw on
   * @param: nodeRad     Radius of the ellipses
   * @param: arrowSize   Size of the arrows
   * @param: arrow       Wether to draw arrows or not
   */
  public void draw(PGraphics canvas, float nodeRad, float arrowSize, boolean arrow) {
    if (arrow) {
      drawArrow(canvas, nodeRad, arrowSize);
    } else {
      if (ACCESS.equals("WALK")) canvas.stroke(150);
      else if (ACCESS.equals("DRIVE")) canvas.stroke(255, 255, 0);
      canvas.line(EDGE.from().xf(), EDGE.from().yf(), EDGE.to().xf(), EDGE.to().yf());
    }
  }



  /**
   * Draws the object as and arrow
   * @param: canvas      PGraphics object to draw on
   * @param: nodeRad     Radius of the ellipses
   * @param: arrowSize   Size of the arrows
   */
  private void drawArrow(PGraphics canvas, float nodeRad, float arrowSize) {
    float fx, fy, tx, ty;
    float ax, ay, sx, sy, ex, ey;
    float awidthx, awidthy;

    fx = START.getGraphNode().xf();
    fy = START.getGraphNode().yf();
    tx = END.getGraphNode().xf();
    ty = END.getGraphNode().yf();

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
}
