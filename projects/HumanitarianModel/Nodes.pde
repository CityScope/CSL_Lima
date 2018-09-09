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

public class Node {
  protected int id;
  public String district = "LIMA DEPARTAMENTO";
  public GraphNode n;
  private String type = "street";
  public float x ;
  public float y ;
  public float z ;

  /**
   *Constructor for Node
   **/
  public Node( Graph g, int nodeID, float pointX, float pointY) { 
    g.addNode(new GraphNode(nodeID, pointX, pointY, 0));
    this.n = g.getNode(nodeID);
    this.id = nodeID;
    this.x = n.xf();
    this.y = n.yf();
    this.z = n.zf();
  }

  /**
   *Assign a district to a node
   **/
  public void setDistrict(String district) {
    this.district = district;
  }

  /**
   *Assign a street type to a node (hospital and school). Street by default
   **/
  public void setType(String type) {
    this.type = type;
  }

  /**
   *Create an edge(LINK) between the current node and the prevNode given
   **/
  public void connect(Graph g, int prevNodeID, double costOut) {
    g.addEdge(prevNodeID, this.id, costOut);
  }

  /**
   *Create two edges(LINKS) one from the actual node and the prevNode given, and viceversa
   **/
  public void connectBoth(Graph g, int prevNodeID, double costOut) {
    g.addEdge(prevNodeID, this.id, costOut);
  }

  /**
   *Draws schools(green) and hospitals(blue)
   **/
  public void draw(PGraphics canvas, float nodeSize) {
    canvas.fill(255, 0, 0);
    if (this.id == 5712 | this.id == 6126) canvas.ellipse(this.n.xf(), this.n.yf(), nodeSize, nodeSize);
    if (this instanceof POI) {
      if (this.type.equals("School")) canvas.fill(0, 255, 0);
      else if (this.type.equals("Hospital")) canvas.fill(0, 0, 255);
      canvas.ellipse(this.n.xf(), this.n.yf(), nodeSize, nodeSize);
    }
  }
}