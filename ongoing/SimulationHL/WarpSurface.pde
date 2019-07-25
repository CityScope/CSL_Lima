/**
 * Generate a shape object that can be distorted using a bunch of control points to fit an irregular
 * 3D surface where a canvas is projected using a beamer
 * @author      Marc Vilella
 * @modified    Jesús García
 * @version     0.3
 */
public class WarpSurface {
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
  public WarpSurface(PApplet parent, float width, float height, int cols, int rows) {

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
   * Mouse event handler to perform control point dragging
   * @param e    the mouse event
   */
  public void mouseEvent(MouseEvent e) {
    switch(e.getAction()) {
    case MouseEvent.PRESS:
      if (calibrate) {
        controlPoint = getControlPoint(e.getX(), e.getY());
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
}
