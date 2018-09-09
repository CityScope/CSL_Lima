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

public class Lane {
  private String name;
  private String access;   
  private String district;
  private Node initNode;
  private Node finalNode;
  private boolean erase = false;
  GraphEdge edge;

  /**
   *Constructor for Lane
   **/
  public Lane(String name, String access, String district, Graph g, Node initNode, Node finalNode, double  distance ) {
    this.name = name;
    this.access = access;
    this.initNode = initNode;
    this.finalNode = finalNode;
    this.district = district;
    g.addEdge(initNode.id, finalNode.id, distance);
    this.edge = g.getEdge(initNode.id, finalNode.id);
  }

  /**
   *Get the initial node of a PVector
   **/
  public PVector getFrom() {
    return new PVector(edge.from().xf(), edge.from().yf());
  }

  /**
   *Get the final node of a PVector
   **/
  public PVector getTo() {
    return new PVector(edge.to().xf(), edge.to().yf());
  }
}