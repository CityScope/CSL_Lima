/**
 * @copyright: Copyright (C) 2019
 * @legal:
 * This file is part of CityMatrix.
 
 * CityMatrix is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * CityMatrix is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with CityMatrix.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * City3D - Extends PApplet. Shows a grid of buildings
 * @author:   Jesús García
 * @version:  0.1
 */
public class City3D extends PApplet {
  private int NBUILDINGS;
  private int BASE;
  private PVector[][] PLAN;
  private PGraphics FLOOR;
  private float angleX = radians(30);
  private float angleZ = radians(30);
  private Mesh MESH;
  private JSONArray BTYPES;


  /**
   * Creates a City3D object with values retrieved from a Mesh object
   * @param: mesh  Mesh object
   */
  public City3D(Mesh mesh, JSONObject calibrationParameters) {
    MESH = mesh;
    BTYPES = calibrationParameters.getJSONArray("Buildings");
  }


  /**
   * Updates the number of buildings in the city and their dimensions
   */
  private void build() {
    NBUILDINGS = MESH.getBlocks();
    BASE = MESH.getBlockSize();
    PLAN = new PVector[NBUILDINGS][NBUILDINGS];
    FLOOR.translate(-(PLAN.length - 1) * BASE/2, -(PLAN.length - 1) * BASE/2);
    design();
  }


  /**
   * Creates and stores Building3D objects for the city
   */
  private void design() {   
    MESH.checkPattern();
    ArrayList<PatternCells> heights = MESH.getPatterns();

    int counter = 0;
    for (int h = 0; h < PLAN.length; h++) {
      for (int w = 0; w < PLAN.length; w++) {
        float x = w * BASE;
        float y = h * BASE;
        place(x, y, BASE, heights.get(counter).getIndex());
        counter++;
      }
    }
  }


  private void place(float x, float y, float w, int idx) {
    color col = 0;
    int hgt = 0;
    for (int i = 0; i < BTYPES.size(); i++) {
      JSONObject b = BTYPES.getJSONObject(i);
      float type = b.getFloat("type");
      if (idx == type) {
        col = unhex(b.getString("col"));
        hgt = b.getInt("h");
        break;
      }
    }
    FLOOR.pushMatrix();
    FLOOR.translate(x, y, hgt/2);
    FLOOR.stroke(#B9BBBD);
    FLOOR.fill(col);
    FLOOR.box(w, w, hgt);
    FLOOR.popMatrix();
  }
  

  /**
   * Shows the PApplet
   */
  public void show() {
    this.getSurface().setVisible(true);
  }


  /**
   * Sets the size of the PApplet. P3D enables drawing 3D shapes
   */
  public void settings() {
    size(800, 800, P3D);
  }


  /**
   * Creates a PGraphics object where the city will be drawn
   */
  public void setup() {
    FLOOR = createGraphics(800, 800, P3D);
  }


  /**
   * Draws the city
   */
  public void draw() {
    FLOOR.beginDraw();
    FLOOR.background(0);
    FLOOR.translate(400, 400);
    FLOOR.rotateX(angleX);
    FLOOR.rotateZ(angleZ);
    build();
    FLOOR.endDraw();

    image(FLOOR, 0, 0);
  }


  /**
   * Performs certain actions when a key is pressed
   * @param: e     KeyEvent
   * @case: UP     Rotates upwards
   * @case: DOWN   Rotates downwards
   * @case: RIGHT  Rotates clockwise
   * @case: LEFT   Rotates anti clockwise
   */
  public void keyPressed(KeyEvent e) {
    switch(e.getKeyCode()) {
    case UP:
      angleX += 0.5;
      break;

    case DOWN:
      angleX -= 0.5;
      break;

    case RIGHT:
      angleZ += 0.5;
      break;

    case LEFT:
      angleZ -= 0.5;
      break;
    }

    switch(key) {
    case 'm':
      toggle();
      break;

    case 's':
      this.getSurface().setVisible(false);
      break;
    }
  }
  
  
  public JSONArray saveConfiguration() {
    return BTYPES;
  }
}
