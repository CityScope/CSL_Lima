/**
 * Extend graphic and rendering context to draw, by adding a Region Of Interest that is drawn into an
 * irregular surface
 * @author    Marc Vilella
 * @version   1.0
 */
public class Canvas extends PGraphics2D {

  PVector origin;
  float rotation;

  /**
   * Construct a rendering context defining coordinates bounding box and its size.
   * Bounding box is used as a reference for the Region of Interest (ROI) that will be
   * displayed in the surface. All coordinates are in Lat/Lon format.
   * @param parent    the sketch PApplet
   * @param w         the bounding box width
   * @param h         the bounding box height
   * @param bounds    the bounding box coordinates. First coordinate is BOTTOM-LEFT and second TOP-RIGHT
   * @param roi       the Region of Interest. Clockwise starting by TOP-LEFT
   */
  public Canvas(PApplet parent, int w, int h, PVector[] bounds, PVector[] roi) {

    PVector[] roiPx = new PVector[roi.length];
    for (int i = 0; i < roi.length; i++) {
      roiPx[i] = new PVector(
        map(roi[i].y, bounds[0].y, bounds[1].y, 0, w), 
        map(roi[i].x, bounds[0].x, bounds[1].x, h, 0)
        );
    }
    origin = roiPx[0];

    int canvasWidth = (int)roiPx[0].dist(roiPx[1]);
    int canvasHeight = (int)roiPx[1].dist(roiPx[2]);

    rotation = PVector.angleBetween( PVector.sub(roiPx[1], roiPx[0]), new PVector(1, 0) );

    setParent(parent);
    setPrimary(false);
    setPath(parent.dataPath(""));
    setSize(canvasWidth, canvasHeight);
  }


  @Override
    public void beginDraw() {
    super.beginDraw();
    this.pushMatrix();
    this.rotate(rotation);
    this.translate(-origin.x, -origin.y);
  }

  @Override 
    void endDraw() {
    this.popMatrix();
    super.endDraw();
  }
}
