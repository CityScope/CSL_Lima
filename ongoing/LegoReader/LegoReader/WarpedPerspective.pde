/**
** @copyright: Copyright (C) 2018
** @authors:   Javier Zárate & Vanesa Alcántara & Jesús García
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

public class WarpedPerspective {
  ArrayList<PVector> contour = new ArrayList<PVector>();
  PVector pointSelected;
  boolean selected;

  public WarpedPerspective(ArrayList<PVector> contour) {
    this.contour = contour;
    this.selected = false;
  }
  
  /**
<<<<<<< HEAD:projects/LegoReader/WarpedPerspective.pde
    *Create vertices on the canvas to select a certain part of it  
  **/
  public PImage applyPerspective(PGraphics img){
    PGraphics canvas = img;
    //PGraphics canvas = createGraphics(img.width, img.height, P3D);
    canvas.beginDraw();
    canvas.background(155);
    canvas.pushMatrix();
    canvas.noStroke();
    canvas.beginShape();
    canvas.texture(img);
    canvas.vertex(0, 0, 0, contour.get(0).x, contour.get(0).y);
    canvas.vertex(canvas.width, 0, 0, contour.get(1).x, contour.get(1).y);
    canvas.vertex(canvas.width, canvas.height, 0, contour.get(2).x, contour.get(2).y);
    canvas.vertex(0, canvas.height, 0, contour.get(3).x, contour.get(3).y);
    canvas.endShape();
    canvas.popMatrix();    
    canvas.endDraw();
    return canvas.get();
=======
   * Places the control points on an image to create a shape object from a part of it
   * @param:   img     PGraphics object to be distorted
   * @returns: PImage  Distorted portion of the PGraphics
   */
  public PImage applyPerspective(PGraphics img) {
    img.beginDraw();
    img.background(155);
    img.pushMatrix();
    img.noStroke();
    img.beginShape();
    img.texture(img);
    img.vertex(0, 0, CONTOUR.get(0).x, CONTOUR.get(0).y);
    img.vertex(img.width, 0, CONTOUR.get(1).x, CONTOUR.get(1).y);
    img.vertex(img.width, img.height, CONTOUR.get(2).x, CONTOUR.get(2).y);
    img.vertex(0, img.height, CONTOUR.get(3).x, CONTOUR.get(3).y);
    img.endShape();
    img.popMatrix();    
    img.endDraw();

    return img.get();
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/WarpedPerspective.pde
  }

  public void draw(PGraphics canvas, PImage img, boolean warp) {
    if (warp) {
      PImage imgPortion;
      imgPortion = img.get(int(contour.get(1).x), int(contour.get(1).y), int(abs(contour.get(1).x - contour.get(0).x)), int(abs(contour.get(1).y - contour.get(2).y)));
      canvas.background(155);
      canvas.pushMatrix();
      canvas.noStroke();
      canvas.beginShape();
      canvas.texture(imgPortion);
      canvas.vertex(0, 0, 0, 0, 0);
      canvas.vertex(canvas.width, 0, 0, imgPortion.width, 0);
      canvas.vertex(canvas.width, canvas.height, 0, imgPortion.width, imgPortion.height);
      canvas.vertex(0, canvas.height, 0, 0, imgPortion.height);
      canvas.endShape();
      canvas.popMatrix();
    } else {
      canvas.image(img.get(), 0, 0);
      for (PVector i : contour) {
        canvas.strokeWeight(1.5);
        canvas.stroke(0, 155, 0);
        canvas.fill(0);
        if (i == pointSelected) {
          canvas.fill(255);
        }
        canvas.ellipse(i.x, i.y, 5, 5);
      }
    }
  }

  /**
    *When a contour point is clicked on, it's status will changed to selected
  **/
  public void selected(int x, int y, int threshold) {
    for (PVector i : contour) {
      float distance = dist(i.x, i.y, x, y);
      if (distance < threshold) {
        selected = true;
        this.pointSelected = i;
        break;
      }
    }
  }

  /**
    *If selected, the contour point will move following the mouse
  **/
  public void move(int x, int y) {
    for (PVector i : contour) {
      if (i == pointSelected) {
        i.x = x;
        i.y = y;
        break;
      }
    }
  }

  /**
    *Resets a contour point status to unselected
  **/
  public void unselect() {
    selected = false;
    pointSelected = null;
  }

  /**
<<<<<<< HEAD:projects/LegoReader/WarpedPerspective.pde
   *Draw the contour points in the canvas
  **/
  public void draw(PGraphics canvas) {
    for (PVector i : contour) {
      canvas.fill(0);
      if (i == pointSelected) {
=======
   * Draw the contour points
   * @param: canvas  PGraphics object where te points will be drawn
   */
  public void drawWarp(PGraphics canvas) {
    for (PVector i : CONTOUR) {
      canvas.strokeWeight(2);
      canvas.stroke(255);
      canvas.fill(0);
      if (i == POI) {
        canvas.stroke(0);
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/WarpedPerspective.pde
        canvas.fill(255);
      }
      canvas.ellipse(i.x, i.y, 5, 5);
    }
  }
<<<<<<< HEAD:projects/LegoReader/WarpedPerspective.pde
=======


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
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/WarpedPerspective.pde
}
