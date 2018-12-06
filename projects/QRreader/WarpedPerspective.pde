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
 * WarpedPerspective - Generates a shape object from an image portion to distort and display it
 * @author:    Jesús García
 * @modified:  Vanesa Alcántara
 * @version:   1.1
 */
public class WarpedPerspective {
  private ArrayList<PVector> CONTOUR = new ArrayList<PVector>();
  private PVector POI;
  private boolean SELECTED;


  /**
   * Creates the object with an array of contour points
   * @param: calibrationPoints  JSONObject with the contour points
   */
  public WarpedPerspective(JSONObject calibrationParameters) {
    load(calibrationParameters);
  }


  /**
   * Retrieves the contour points from a JSONObject
   * @param: calibrationPoints  JSONObject with the control points
   */
  private void load(JSONObject calibrationParameters) {
    JSONObject calibrationPoints = calibrationParameters.getJSONObject("Calibration Points");

    for (int i = 0; i < calibrationPoints.size(); i++) {
      JSONArray point = calibrationPoints.getJSONArray(str(i));
      CONTOUR.add(new PVector(point.getInt(0), point.getInt(1)));
    }
  }


  /**
   * Places the control points on an image to create a shape object from a part of it
   * @param:   img     PGraphics object to be distorted
   * @returns: PImage  Distorted portion of the PGraphics
   */
  public PImage applyPerspective(PGraphics img) {
    PGraphics canvas = createGraphics(img.width, img.height, P3D);
    canvas.beginDraw();
    canvas.background(155);
    canvas.pushMatrix();
    canvas.noStroke();
    canvas.beginShape();
    canvas.texture(img);
    canvas.vertex(0, 0, 0, CONTOUR.get(0).x, CONTOUR.get(0).y);
    canvas.vertex(canvas.width, 0, 0, CONTOUR.get(1).x, CONTOUR.get(1).y);
    canvas.vertex(canvas.width, canvas.height, 0, CONTOUR.get(2).x, CONTOUR.get(2).y);
    canvas.vertex(0, canvas.height, 0, CONTOUR.get(3).x, CONTOUR.get(3).y);
    canvas.endShape();
    canvas.popMatrix();    
    canvas.endDraw();

    return canvas.get();
  }


  /**
   * Changes the status of a contour point to selected if the mouse clicks within a certain distance from it
   * @param: x          X coordinate of the mouse
   * @param: y          Y coordinate of the mouse
   * @param: threshold  Distance from the mouse to the control point to change its status
   */
  public void select(int x, int y, int threshold) {
    for (PVector i : CONTOUR) {
      float distance = dist(i.x, i.y, x, y);
      if (distance < threshold) {
        SELECTED = true;
        POI = i;
        break;
      }
    }
  }


  /**
   * If selected, the contour point will move following the mouse. This will distort the image
   * @param: x  X coordinate of the mouse
   * @param: y  Y coordinate of the mouse
   */
  public void move(int x, int y) {
    for (PVector i : CONTOUR) {
      if (i == POI) {
        i.x = x;
        i.y = y;
        break;
      }
    }
  }


  /**
   * Resets a contour point's status to unselected
   */
  public void unselect() {
    SELECTED = false;
    POI = null;
  }


  /**
   * Draw the contour points
   * @param: canvas  PGraphics object where te points will be drawn
   */
  public void draw(PGraphics canvas) {
    for (PVector i : CONTOUR) {
      canvas.fill(255);
      if (i == POI) {
        canvas.fill(0);
      }
      canvas.ellipse(i.x, i.y, 10, 10);
    }
  }


  /**
   * Saves the current values of the CONTOUR attribute
   * @returns: JSONObject  A JSONObject with all the CONTOUR values
   */
  public JSONObject saveConfiguration() {
    JSONObject calibrationPoints = new JSONObject();

    for (int i = 0; i < CONTOUR.size(); i++) {
      JSONArray point = new JSONArray();
      point.setFloat(0, CONTOUR.get(i).x);
      point.setFloat(1, CONTOUR.get(i).y);
      calibrationPoints.setJSONArray(str(i), point);
    }

    return calibrationPoints;
  }
}
