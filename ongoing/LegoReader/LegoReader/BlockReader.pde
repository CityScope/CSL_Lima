/**
** @copyright: Copyright (C) 2018
** @authors:   Javier Zárate & Vanesa Alcántara
** @version:   1.0
** @legal:
    This file is part of LegoReader.
    LegoReader is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    LegoReader is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.
    
    You should have received a copy of the GNU Affero General Public License
    along with LegoReader.  If not, see <http://www.gnu.org/licenses/>.
**/

public class BlockReader extends PApplet {
<<<<<<< HEAD:projects/LegoReader/BlockReader.pde
  int w;
  int h;
  color actualColor;

  public BlockReader(int w, int h) {
    this.w = w;
    this.h = h;
    actualColor = color(0, 0, 0);
=======
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
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/BlockReader.pde
  }

  public void settings() {
<<<<<<< HEAD:projects/LegoReader/BlockReader.pde
    size(this.w, this.h,P3D);
  }

  public void setup() {
    canvasColor = createGraphics(this.w, this.h,P3D);
=======
    size(WIDTH, HEIGHT, P2D);
  }



  /**
   * Creates a PGraphics object where the Mesh instance will be drawn and sets colorMode to HSB
   */
  public void setup() {
    CANVAS = createGraphics(WIDTH, HEIGHT);
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/BlockReader.pde
    colorMode(HSB, 360, 100, 100);
  }

  public void draw() {
<<<<<<< HEAD:projects/LegoReader/BlockReader.pde
    canvasColor.beginDraw();
    canvasColor.background(255);
    canvasColor.strokeWeight(1);
    mesh.checkPattern();
    mesh.draw(canvasColor);
    canvasColor.endDraw();
    image(canvasColor, 0, 0);
=======
    CANVAS.beginDraw();
    CANVAS.background(255);
    CANVAS.strokeWeight(1);
    MESH.checkPattern();
    MESH.drawPatterns(CANVAS);
    CANVAS.endDraw();
    image(CANVAS, 0, 0);
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/BlockReader.pde
  }

  void mouseClicked() {
    color selected = canvasColor.get(mouseX, mouseY);
    println(hue(selected), saturation(selected), brightness(selected));
    println(red(selected), green(selected), blue(selected));
  }
<<<<<<< HEAD:projects/LegoReader/BlockReader.pde
=======


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
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/BlockReader.pde
}
