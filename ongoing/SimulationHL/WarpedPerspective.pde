/**
 * WarpedPerspective - Class to distort images according to control points
 * @author        Jesús García
 * @version       1.1
 */
public class WarpedPerspective {
  ArrayList<PVector> contour = new ArrayList<PVector>();
  PVector pointSelected;
  boolean selected;

  public WarpedPerspective(ArrayList<PVector> contour) {
    this.contour = contour;
    selected = false;
  }


  /**
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
    img.vertex(0, 0, contour.get(0).x, contour.get(0).y);
    img.vertex(img.width, 0, contour.get(1).x, contour.get(1).y);
    img.vertex(img.width, img.height, contour.get(2).x, contour.get(2).y);
    img.vertex(0, img.height, contour.get(3).x, contour.get(3).y);
    img.endShape();
    img.popMatrix();    
    img.endDraw();

    return img.get();
  }


  /**
   * Changes the status of a contour point to selected if the mouse clicks within a certain distance from it
   * @param: x          X coordinate of the mouse
   * @param: y          Y coordinate of the mouse
   * @param: threshold  Distance from the mouse to the control point to change its status
   */
  public void select(int x, int y, int threshold) {
    for (PVector i : contour) {
      float distance = dist(i.x, i.y, x, y);
      if (distance < threshold) {
        selected = true;
        pointSelected = i;
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
    for (PVector i : contour) {
      if (i == pointSelected) {
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
    selected = false;
    pointSelected = null;
  }


  /**
   * Draw the contour points
   * @param: canvas  PGraphics object where te points will be drawn
   */
  public void drawWarp(PGraphics canvas) {
    for (PVector i : contour) {
      canvas.strokeWeight(2);
      canvas.stroke(255);
      canvas.fill(0);
      if (i == pointSelected) {
        canvas.stroke(0);
        canvas.fill(255);
      }
      canvas.ellipse(i.x, i.y, 5, 5);
    }
  }
}
