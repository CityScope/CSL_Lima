/**
 * WarpedPerspective - Class to distort images according to control points
 * @author        Javier Zárate
 * @version       1.0
 */
public class WarpedPerspective {
  ArrayList<PVector> contour = new ArrayList<PVector>();
  PVector pointSelected;
  boolean selected;

  public WarpedPerspective(ArrayList<PVector> contour) {
    this.contour = contour;
    selected = false;
  }

  Mat getPerspectiveTransformation(ArrayList<PVector> inputPoints, int w, int h) {
    Point[] canonicalPoints = new Point[4];
    canonicalPoints[0] = new Point(w, 0);
    canonicalPoints[1] = new Point(0, 0);
    canonicalPoints[2] = new Point(0, h);
    canonicalPoints[3] = new Point(w, h);

    MatOfPoint2f canonicalMarker = new MatOfPoint2f();
    canonicalMarker.fromArray(canonicalPoints);

    Point[] points = new Point[4];
    for (int i = 0; i < 4; i++) {
      points[i] = new Point(inputPoints.get(i).x, inputPoints.get(i).y);
    }
    MatOfPoint2f marker = new MatOfPoint2f(points);
    return Imgproc.getPerspectiveTransform(marker, canonicalMarker);
  }


  Mat warpPerspective( int w, int h) {
    Mat transform = getPerspectiveTransformation(this.contour, w, h);
    Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
    Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
    return unWarpedMarker;
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
