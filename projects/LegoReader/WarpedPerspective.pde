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
  ArrayList<PVector> contour = new ArrayList();
  PVector pointSelected;
  boolean selected;

  public WarpedPerspective(ArrayList<PVector> contour) {
    this.contour = contour;
    this.selected = false;
  }
  
  /**
    *Create vertices on the canvas to select a certain part of it  
  **/
  public PImage applyPerspective(PGraphics img){
    PGraphics canvas = createGraphics(img.width, img.height, P3D);
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
   *Draw the contour points in the canvas
  **/
  public void draw(PGraphics canvas) {
    for (PVector i : contour) {
      canvas.fill(0);
      if (i == pointSelected) {
        canvas.fill(255);
      }
      canvas.ellipse(i.x, i.y, 5, 5);
    }
  }
}