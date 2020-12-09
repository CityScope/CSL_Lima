/**
* Generate a shape object that can be distorted using a bunch of control points to fit an irregular
* 3D surface where a canvas is projected using a beamer
* @author    Marc Vilella
* @version   0.3
*/
public class WarpSurface {
    
    private PVector[][] points;
    private int cols, rows;
    private PVector controlPoint;
    
    private boolean calibrateMode;
    
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
        
        this.cols = cols;
        this.rows = rows;
        
        float initX = parent.width / 2 - width / 2;
        float initY = parent.height / 2 - height / 2;
        
        
        float dX = width / (cols - 1);
        float dY = height / (rows - 1);
        
        points = new PVector[rows][cols];
        for(int x = 0; x < cols; x++) {
            for(int y = 0; y < rows; y++) {
                points[y][x] = new PVector(initX + x * dX, initY + y * dY);
            }
        }
    }
    
    public WarpSurface() {
       loadConfig();
    }

    
    /**
    * Draw the canvas in surface, warping it as a texture. While in
    * calibration mode the control points can be moved with a mouse drag
    * @param canvas    the canvas 
    */
    public void draw(Canvas canvas) {
        
        float dX = canvas.width / (cols - 1);
        float dY = canvas.height / (rows - 1);
        
        for(int y = 0; y < rows -1; y++) {
            beginShape(TRIANGLE_STRIP);
            texture(canvas);
            for(int x = 0; x < cols; x++) {
                
                if(calibrateMode) {
                    stroke(#FF0000);
                    strokeWeight(0.5);
                } else noStroke();
                
                vertex(points[y][x].x, points[y][x].y, canvas.width - x * dX, canvas.height - y * dY);
                vertex(points[y+1][x].x, points[y+1][x].y, canvas.width - x * dX, canvas.height - (y+1) * dY);
            }
            endShape();
        }
        
    }
    
    
    /**
    * Toggle callibration mode of surface, allowing to drag and move control points
    */
    public void toggleCalibration() {
        calibrateMode = !calibrateMode;
    }
    
    
    /**
    * Return whether the surface is in calibration mode
    * @return    true if surface is in calibration mode, false otherwise
    */
    public boolean isCalibrating() {
        return calibrateMode;
    }
    
    
    /**
    * Load the position of control points from an XML file, by default "warp.xml"
    */
    public void loadConfig() {
        XML settings = loadXML(sketchPath("warp.xml"));
        //XML settings = loadXML(sketchPath("surface.xml"));
        XML size = settings.getChild("size");
        rows = size.getInt("rows");
        cols = size.getInt("cols");
        XML[] xmlPoints = settings.getChild("points").getChildren("point");
        points = new PVector[rows][cols];
        for(int i = 0; i < xmlPoints.length; i++) {
            int x = i % cols;
            int y = i / cols;
            points[y][x] = new PVector(xmlPoints[i].getFloat("x"), xmlPoints[i].getFloat("y"));
        }
    }
    
    
    /**
    * Save the position of control points into an XML file, by default "warp.xml"
    */
    public void saveConfig() {
        XML settings = new XML("settings");
        XML size = settings.addChild("size");
        size.setInt("cols", cols);
        size.setInt("rows", rows);
        XML xmlPoints = settings.addChild("points");
        for(int y = 0; y < rows; y++) {
            for(int x = 0; x < cols; x++) {
                XML point = xmlPoints.addChild("point");
                point.setFloat("x", points[y][x].x);
                point.setFloat("y", points[y][x].y);
            }
        }
        saveXML(settings, "warp.xml");
        //saveXML(settings, "surface.xml");
        println("Warp configuration saved");
    }
    
   
    /**
    * Mouse event handler to perform control point dragging
    * @param e    the mouse event
    */
    public void mouseEvent(MouseEvent e) {
        switch(e.getAction()) {
            
            case MouseEvent.PRESS:
                if(calibrateMode) {
                    controlPoint = null;
                    for(int y = 0; y < rows; y++) {
                        for(int x = 0; x < cols; x++) {
                            PVector mousePos = new PVector(mouseX, mouseY);
                            if(mousePos.dist(points[y][x]) < 10) {
                                controlPoint = points[y][x];
                                break;
                            }
                        }
                    }
                }
                break;
                
            case MouseEvent.DRAG:
                if(calibrateMode && controlPoint != null) {
                    controlPoint.x = mouseX;
                    controlPoint.y = mouseY;
                }
                break;
        }
    }
    
    protected void move(int dX, int dY) {
     
      
      for(int c = 0; c < cols; c++) {
            for(int r = 0; r < rows; r++) {
                points[r][c].x += dX;
                points[r][c].y += dY;
            }
        }
    }
}



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
        for(int i = 0; i < roi.length; i++) {
            roiPx[i] = new PVector(
                map(roi[i].y, bounds[0].y, bounds[1].y, 0, w),
                map(roi[i].x, bounds[0].x, bounds[1].x, h, 0)
            );
        }
        origin = roiPx[0];
        
        int canvasWidth = (int)roiPx[0].dist(roiPx[1]);
        int canvasHeight = (int)roiPx[1].dist(roiPx[2]);
        
        rotation = PVector.angleBetween( PVector.sub(roiPx[1], roiPx[0]), new PVector(1,0) );
        
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
    
    @Override void endDraw() {
        this.popMatrix();
        super.endDraw();
    }

}