/**
 * Generate a shape object that can be distorted using a bunch of control points to fit an irregular
 * 3D surface where a canvas is projected using a beamer
 * @author      Marc Vilella
 * @modified    Jesús García
 * @version     0.3
 */
public class WarpSurface extends Observable {
  private LatLon[][] ROIpoints;

  private PVector[][] controlPoints;
  private int cols, rows;
  private PVector controlPoint;

  private boolean calibrate;


  /**
   * Construct a warp surface containing a grid of control points. By default thw surface
   * is placed at the center of sketch
   * @param parent    the sketch PApplet
   * @param width     the surface width
   * @param height    the surface height
   * @param cols      the number of horizontal control points
   * @param rows      the number of vertical control points
   */
  public WarpSurface(PApplet parent, float width, float height, int cols, int rows, LatLon[] roi) {

    parent.registerMethod("mouseEvent", this);
    parent.registerMethod("keyEvent", this);

    this.cols = cols;
    this.rows = rows;

    float initX = parent.width / 2 - width / 2;
    float initY = parent.height / 2 - height / 2;
    float dX = width / (cols - 1);
    float dY = height / (rows - 1);

    controlPoints = new PVector[rows][cols];
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        controlPoints[y][x] = new PVector(initX + x * dX, initY + y * dY);
      }
    }

    if (roi != null) ROIpoints = getPointsROI(roi);
  }


  /**
   * Find all points inside a Region of Interest that match with rows and columns
   * @param roi    List of vertices of the region of interest (clockwise)
   * @return all points of the ROI
   */
  private LatLon[][] getPointsROI(LatLon[] roi) {
    LatLon[][] points = new LatLon[rows][cols];
    for (int c = 0; c < cols; c++) {
      LatLon upPoint = roi[0].lerp(roi[1], c/float(cols-1));
      LatLon dwPoint = roi[3].lerp(roi[2], c/float(cols-1));
      for (int r = 0; r < rows; r++) {
        points[r][c] = upPoint.lerp(dwPoint, r/float(rows-1));
      }
    }
    return points;
  }


  /**
   * Return coordinates of corners in Region Of Interest
   * @return coordinates of vertices
   */
  private LatLon[] getROI() {
    return new LatLon[] {
      ROIpoints[0][0], 
      ROIpoints[ROIpoints.length-1][0], 
      ROIpoints[ROIpoints.length-1][ROIpoints[0].length-1], 
      ROIpoints[0][ROIpoints[0].length-1]
    };
  }


  /**
   * Draw the canvas in surface, warping it as a texture. While in
   * calibration mode the control points can be moved with a mouse drag
   * @param canvas    the canvas 
   */
  public void draw(Canvas canvas) {

    float dX = canvas.width / (cols - 1);
    float dY = canvas.height / (rows - 1);

    for (int y = 0; y < rows - 1; y++) {
      beginShape(TRIANGLE_STRIP);
      texture(canvas);
      for (int x = 0; x < cols; x++) {

        if (calibrate) {
          stroke(#FF0000);
          strokeWeight(0.5);
        } else noStroke();

        vertex(controlPoints[y][x].x, controlPoints[y][x].y, x * dX, y * dY);
        vertex(controlPoints[y+1][x].x, controlPoints[y+1][x].y, x * dX, (y+1) * dY);
      }
      endShape();
    }
  }


  /**
   * Draw the canvas in surface, warping it as a texture. While in
   * calibration mode the control points can be moved with a mouse drag
   * @param canvas    PGraphics object to be distorted
   */
  public void draw(PGraphics canvas) {

    float dX = canvas.width / (cols - 1);
    float dY = canvas.height / (rows - 1);

    for (int y = 0; y < rows - 1; y++) {
      beginShape(TRIANGLE_STRIP);
      texture(canvas);
      for (int x = 0; x < cols; x++) {

        if (calibrate) {
          stroke(#FF0000);
          strokeWeight(0.5);
        } else noStroke();

        vertex(controlPoints[y][x].x, controlPoints[y][x].y, x * dX, y * dY);
        vertex(controlPoints[y+1][x].x, controlPoints[y+1][x].y, x * dX, (y+1) * dY);
      }
      endShape();
    }
  }


  /**
   * Toggle callibration mode of surface, allowing to drag and move control points
   */
  public void toggleCalibration() {
    calibrate = !calibrate;
  }


  /**
   * Return whether the surface is in calibration mode
   * @return    true if surface is in calibration mode, false otherwise
   */
  public boolean isCalibrating() {
    return calibrate;
  }


  /**
   * Loads the position of control points from an XML file
   * @param path  Path to the XML file
   */
  public void loadConfig(String path) {
    processing.data.XML settings = loadXML(sketchPath(path));
    processing.data.XML size = settings.getChild("size");
    rows = size.getInt("rows");
    cols = size.getInt("cols");
    processing.data.XML[] xmlPoints = settings.getChild("points").getChildren("point");
    controlPoints = new PVector[rows][cols];
    for (int i = 0; i < xmlPoints.length; i++) {
      int x = i % cols;
      int y = i / cols;
      controlPoints[y][x] = new PVector(xmlPoints[i].getFloat("x"), xmlPoints[i].getFloat("y"));
    }
  }


  /**
   * Loads the position of control points from an XML file with ROI points
   * @param configFilePath  Path to the XML file
   */
  public void loadMainConfig(String configFilePath) {
    File configFile = new File(sketchPath(configFilePath));

    if (configFile.exists()) {
      processing.data.XML surface = loadXML(sketchPath(configFilePath));
      processing.data.XML size = surface.getChild("size");
      rows = size.getInt("rows");
      cols = size.getInt("cols");
      processing.data.XML roi[] = surface.getChild("roi").getChildren("location");
      LatLon[] ROI = new LatLon[roi.length];

      for (int i = 0; i < roi.length; i++) ROI[i] = new LatLon(roi[i].getFloat("lat"), roi[i].getFloat("lon"));
      ROIpoints = getPointsROI(ROI);
      processing.data.XML[] points = surface.getChild("points").getChildren("point");
      controlPoints = new PVector[rows][cols];

      for (int i = 0; i < points.length; i++) {
        int c = i % cols;
        int r = i / cols;
        controlPoints[r][c] = new PVector(points[i].getFloat("x"), points[i].getFloat("y"));
      }
      println("WarpSurface calibration loaded");
    } else println("WarpSurface calibration file doesn't exist");
  }


  /**
   * Saves the position of control points into an XML file
   * @param path  Name to save the XML file
   */
  public void saveConfig(String path) {
    processing.data.XML settings = new processing.data.XML("settings");
    processing.data.XML size = settings.addChild("size");
    size.setInt("cols", cols);
    size.setInt("rows", rows);
    processing.data.XML xmlPoints = settings.addChild("points");
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        processing.data.XML point = xmlPoints.addChild("point");
        point.setFloat("x", controlPoints[y][x].x);
        point.setFloat("y", controlPoints[y][x].y);
      }
    }
    saveXML(settings, path);
  }


  /**
   * Saves the position of control points and the ROIpoints into an XML file
   * @param configFilePath  Name to save the XML file
   */
  public void saveMainConfig(String configFilePath) {
    if (calibrate) {
      processing.data.XML surface = new processing.data.XML("surface");
      processing.data.XML roi = surface.addChild("roi");

      for (LatLon r : getROI()) {
        processing.data.XML location = roi.addChild("location");
        location.setFloat("lat", r.getLat());
        location.setFloat("lon", r.getLon());
      }

      processing.data.XML size = surface.addChild("size");
      size.setInt("cols", cols);
      size.setInt("rows", rows);
      processing.data.XML xmlPoints = surface.addChild("points");

      for (int y = 0; y < rows; y++) {
        for (int x = 0; x < cols; x++) {
          processing.data.XML point = xmlPoints.addChild("point");
          point.setFloat("x", controlPoints[y][x].x);
          point.setFloat("y", controlPoints[y][x].y);
        }
      }
      saveXML(surface, configFilePath);
      println("WarpSurface calibration saved");
    }
  }


  /**
   * Mouse event handler to perform control point dragging
   * @param e    the mouse event
   */
  public void mouseEvent(MouseEvent e) {
    switch(e.getAction()) {
    case MouseEvent.PRESS:
      if (calibrate) {
        controlPoint = getControlPoint(e.getX(), e.getY());
      } else {
        LatLon location = unmapPoint(e.getX(), e.getY());
        if (location != null) {
          setChanged();
          notifyObservers(location);
        }
      }
      break;

    case MouseEvent.DRAG:
      if (calibrate && controlPoint != null) {
        controlPoint.x = e.getX();
        controlPoint.y = e.getY();
      }
      break;

    case MouseEvent.RELEASE:
      controlPoint = null;
      break;
    }
  }


  /**
   * Key event handler to perform calibration movement of the surface
   * @param e    the key event
   */
  public void keyEvent(KeyEvent e) {
    if (calibrate) {
      switch(e.getAction()) {
      case KeyEvent.PRESS:
        switch(e.getKeyCode()) {
        case UP:
          this.move(0, -5);
          break;
        case DOWN:
          this.move(0, 5);
          break;
        case LEFT:
          this.move(-5, 0);
          break;
        case RIGHT:
          this.move(5, 0);
          break;
        }
        break;
      }
    }
  }


  /**
   * Get the control point close enough (if any) to a position
   * @param x    Horizontal position
   * @param y    Vertical position
   * @return the selected control point
   */
  private PVector getControlPoint(int x, int y) {
    PVector mousePos = new PVector(x, y);
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (mousePos.dist(controlPoints[r][c]) < 10) return controlPoints[r][c];
      }
    }
    return null;
  }


  /**
   * Move surface
   * @param dX    Horizontal displacement
   * @param dY    Vertical displacement
   */
  private void move(int dX, int dY) {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        controlPoints[r][c].x += dX;
        controlPoints[r][c].y += dY;
      }
    }
  }


  /**
   * Unmap point position in the surface to get the corresponding location in latitude and longitude coordinates
   * @param x    Horizontal position
   * @param y    Vertical position
   * @return the latitude and longitude of the point
   */
  public LatLon unmapPoint(int x, int y) {
    PVector point = new PVector(x, y);
    for (int r = 1; r < rows; r++) {
      for (int c = 1; c < cols; c++) {
        LatLon tp = triangleLocation(point, c, r, c, r-1);    // Upper triangle
        if (tp != null) return tp;
        tp = triangleLocation(point, c, r, c-1, r);    // Lower triangle
        if (tp != null) return tp;
      }
    }
    return null;
  }


  /**
   * Get the location (latitude, longitude) of a point in a surface triangle
   * @param point    Position of the point
   * @param c        Column of the most right vertex in triangle
   * @param r        Row of the lowest vertex in triangle
   * @param i        Column of the unshared vertex in triangle (used to determine if upper or lower triangle)
   * @param j        Row of the unshared vertex in triangle (used to determine if upper or lower triangle)
   * @return the selected control point
   */
  private LatLon triangleLocation(PVector point, int c, int r, int i, int j) {
    if (Geometry.inTriangle(point, controlPoints[r][c], controlPoints[r-1][c-1], controlPoints[j][i])) {
      PVector projPoint = Geometry.linesIntersection(controlPoints[r-1][c-1], point, controlPoints[j][i], controlPoints[r][c]);
      float r1 = PVector.sub(projPoint, controlPoints[j][i]).mag() / PVector.sub(controlPoints[j][i], controlPoints[r][c]).mag();
      float r2 = PVector.sub(point, controlPoints[r-1][c-1]).mag() / PVector.sub(projPoint, controlPoints[r-1][c-1]).mag();
      LatLon decProjPoint = ROIpoints[j][i].lerp(ROIpoints[r][c], r1);
      return ROIpoints[r-1][c-1].lerp(decProjPoint, r2);
    } else return null;
  }
}
