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

public class POI extends Node {
  protected final int ID;
  public int capacity;
  public String access;
  public int link = -1;
  public int linkJSON = -1;

  /**
   *Constructor for POI
   **/
  public POI(int ID, Graph g, int nodeID, float pointX, float pointY, int capacity, String access, String district) {
    super(g, nodeID, pointX, pointY);
    this.ID = ID;
    this.capacity = capacity;
    this.access = access;
    setDistrict(district);
  }

  /**
   *Assign the id of the origin or destiny respectively
   **/
  public void setLink(int link) {
    this.link = link;
  }

  /**
   *Assign the id from the JSON import
   **/
  public void setLinkJSON(int linkJSON) {
    this.linkJSON = linkJSON;
  }
}