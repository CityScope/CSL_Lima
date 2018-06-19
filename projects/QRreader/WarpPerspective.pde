/**
 ** @copyright: Copyright (C) 2018
 ** @authors:   Vanesa Alcántara & Jesús García
 ** @version:   1.0 
 ** @legal :
 This file is part of QRreader.
 
 QRreader is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 QRreader is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License
 along with QReader.  If not, see <http://www.gnu.org/licenses/>.
 **/

/*
* Import ZXING library created by  Rolf van Gelder 
 * Available for processing:(http://cagewebdev.com/zxing4processing-processing-library/)
 */

//Creates the points that will allow you to select the portion of the video you want to use
public class WarpPerspective {
  ArrayList<PVector> contour = new ArrayList();
  int w, h;
  PVector pointSelected;
  boolean selected;

  public WarpPerspective(ArrayList<PVector> contour, int w, int h) {
    this.contour = contour;
    this.selected = false;
    this.w = w; 
    this.h = h;
  }

  /*
  *Will help check if the mouse is pressed within the boundaries of a point
   */
  public void selected(int x, int y, int threshold) {
    /* */
    for (PVector i : contour) {
      float distance = dist(i.x, i.y, x, y);
      if (distance < threshold) {
        selected = true;
        this.pointSelected = i;
        break;
      }
    }
  }

  /*
  *Updates the points
   */
  public void changeContours(ArrayList<PVector> calibrationPoints) {
    contour.clear();
    for (int i=0; i<calibrationPoints.size(); i++) {
      contour.add(calibrationPoints.get(i));
    }
  }

  public void move(int x, int y) {
    for (PVector i : contour) {
      if (i == pointSelected) {
        i.x = x;
        i.y = y;
        break;
      }
    }
  }

  public void unSelect() {
    selected = false;
    pointSelected = null;
  }

  /*
  *Flip screen
 */
  public void flip(PGraphics canvas, Capture cam, boolean flip) {
    if (flip) {
      canvas.pushMatrix();
      canvas.scale(-1, 1);
      canvas.image(cam, -video.width, 0);
      canvas.popMatrix();
    } else {
      canvas.image(cam, 0, 0);
    }
  }

  /*
  *Draws the four points to the screen
   */
  public void draw(PGraphics canvas) {
    for (PVector i : contour) {
      canvas.fill(255);
      if (i == pointSelected) {
        canvas.fill(0);
      }
      canvas.ellipse(i.x, i.y, 8, 8);
    }
  }

  /*
  *The following was adapted from an OpenCV example
   */
  Mat getPerspectiveTransformation(ArrayList<PVector> inputPoints, int w, int h) {
    Point[] canonicalPoints = new Point[4];
    canonicalPoints[0] = new Point(w, 0) ;
    canonicalPoints[1] =new Point(0, 0);
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

  Mat warpPerspective( int w, int h, OpenCV opencv) {
    ArrayList<PVector> inputPoints = new ArrayList();
    for (PVector pv : this.contour) {
      float tempX = map(pv.x, 0, video.width,video.width,0);
      inputPoints.add(new PVector(tempX,pv.y));
    }
    Mat transform = getPerspectiveTransformation(inputPoints, w, h);
    Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
    Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
    return unWarpedMarker;
  }
}