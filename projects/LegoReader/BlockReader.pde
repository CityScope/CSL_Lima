/**
 * @copyright: Copyright (C) 2018
 * @legal:
 * This file is part of LegoReader.
 
 * LegoReader is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * LegoReader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 ^ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with LegoReader.  If not, see <http://www.gnu.org/licenses/>.
 **/


/**
 * BlockReader - Extends PApplet. Shows a Mesh object
 * @see:       Mesh
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class BlockReader extends PApplet {
  private PGraphics CANVAS;
  private int WIDTH;
  private int HEIGHT;
  private Mesh MESH;


  /**
   * Creates a BlockReader object with values retrieved from a JSONObject and a Mesh object
   * @param: calibrationParameters  JSONObject with the size values for the PApplet
   * @param: mesh                   Mesh object to be shown
   */
  public BlockReader(JSONObject calibrationParameters, Mesh mesh) {
    HEIGHT = WIDTH = calibrationParameters.getInt("Canvas size");
    MESH = mesh;
  }


  /**
   * Sets the size of the PApplet. P3D enables the use of vertices
   */
  public void settings() {
    size(WIDTH, HEIGHT);
  }



  /**
   * Creates a PGraphics object where the Mesh instance will be drawn and sets colorMode to HSB
   */
  public void setup() {
    CANVAS = createGraphics(WIDTH, HEIGHT);
    colorMode(HSB, 360, 100, 100);
  }


  /**
   * Calls the Mesh object checkPattern and draw methods to display it in a PGraphics object
   */
  public void draw() {
    CANVAS.beginDraw();
    CANVAS.background(255);
    CANVAS.strokeWeight(1);
    MESH.checkPattern();
    MESH.drawPatterns(CANVAS);
    CANVAS.endDraw();
    image(CANVAS, 0, 0);
  }


  /**
   * Prints the HSB and RGB values of the color selected with the mouse
   */
  public void mouseClicked() {
    color selected = CANVAS.get(mouseX, mouseY);
    println(hue(selected), saturation(selected), brightness(selected));
    println(red(selected), green(selected), blue(selected));
  }


  /**
   * Performs certain actions when a key is pressed
   * @case: 's'  Hides the PApplet
   */
  public void keyPressed() {
    switch(key) {
    case 's':
      this.getSurface().setVisible(false);
      break;
    }
  }


  /**
   * Shows the PApplet
   */
  public void show() {
    this.getSurface().setVisible(true);
  }
}
