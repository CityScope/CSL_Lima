/**
 * WarpedPerspective - Class to distort images according to control points
 * @author        Javier Zárate
 * @version       1.0
 */

public class WrappedPerspective {
  ArrayList<PVector> contour = new ArrayList();
  PVector pointSelected;
  boolean selected;

  public WrappedPerspective(ArrayList<PVector> contour) {
    this.contour = contour;
    this.selected = false;
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
}
