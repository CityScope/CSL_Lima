/**
 * @copyright: Copyright (C) 2018
 * @legal:
 * This file is part of QRreader.
 
 * QRreader is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * QRreader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with QRreader. If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * QR - Class which decodes all the QR codes in a grid
 * @see:       Mesh
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1
 */
public class Qr {
  private ArrayList<PVector[]> MARKERS = new ArrayList<PVector[]>();
  private HashMap<Integer, String> CODES = new HashMap<Integer, String>();
  private String DECODED = "";
  private Mesh MESH;


  /**
   * Creates the object with an array of contour points
   * @param: calibrationPoints  JSONObject with the contour points
   */
  public Qr(Mesh mesh) {
    MESH = mesh;
  }


  /**
   * Calls the checkPattern method of MESH
   * @param: img  PImage object to look in
   */
  public void decode(PImage img) {
    if (!DECODED.equals("")) {
      DECODED = "";
    } else {
      try {  
        MESH.checkPattern(img);
        println("");
      } 
      catch (Exception e) {  
        println("Zxing4processing exception: " + e);
        DECODED = "";
      }
    }
  }
}
