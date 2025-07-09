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

/**
* estadictic_graphics - templates for different kinds of graphics changing with time
* @author        Vanesa Alcantara & Javier Zarate
* @version       2.0
*/
public class WrappedPerspective{
  ArrayList<PVector> contour = new ArrayList();
  PVector pointSelected;
  boolean selected;
  
  public WrappedPerspective(ArrayList<PVector> contour){
    this.contour = contour;
    this.selected = false;
  }
  
  
  /**
  *select the contour point if the distance is less than a threshold
  **/
  public void selected(int x, int y, int threshold){
    for(PVector i : contour){
      float distance = dist(i.x, i.y, x, y);
      if(distance < threshold){
        selected = true;
        this.pointSelected = i;
        break;
      }
    }
  }
  
  public void changeContours(ArrayList<PVector> calibrationPoints){
    contour.clear();
    for(int i=0; i<calibrationPoints.size();i++){
      contour.add(calibrationPoints.get(i));
    }
  }
  
  
  /**
  *change the coordinates of a point in the contour array
  **/
  public void move(int x, int y){
    for(PVector i: contour){
      if(i == pointSelected){
        i.x = x;
        i.y = y;
        break;
      }
    }
  }
  
  
  /**
  *unselect any point
  **/
  public void unSelect(){
    selected = false;
    pointSelected = null;
  }
  
  
  /**
  *draw the contour points in the canvas
  **/
  public void draw(PGraphics canvas){
    for(PVector i: contour){
      canvas.fill(0);
      if(i == pointSelected){
        canvas.fill(255);
      }
      canvas.ellipse(i.x, i.y, 5,5);
    }
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
  
  
  Mat warpPerspective( int w, int h, OpenCV opencv) {
    Mat transform = getPerspectiveTransformation(this.contour, w, h);
    Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
    Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
    return unWarpedMarker;
  }
}