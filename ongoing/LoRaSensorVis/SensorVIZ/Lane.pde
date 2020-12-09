/**
 * Kind of a facade to create and manage all the lanes in the roadnetwork
 * @author    Marc Vilella
 * @modified  Guillem Francisco
 * @version   0.1
 */
public class Lanes {

  private final int W, H;
  private final PVector[] BOUNDS;

  private final ArrayList<Lane> LANES = new ArrayList();  


  /**
   * Initiate lane with the required varaibles
   * @param id  ID of the lane
   * @param name  Name of the lane
   * @param vertices  Vertices that compose the lane
   */
  public Lanes(String file, int x, int y, PVector[] bounds) {
    W = x;
    H = y;
    BOUNDS = bounds;

    load(file);
  }


  /**
   * Transform from polar coordinates to (X, Y) of the canvas
   * @param lat
   * @param lon 
   */
  public PVector toXY(float lat, float lon) {
    return new PVector(
      map(lon, BOUNDS[0].y, BOUNDS[1].y, 0, W), 
      map(lat, BOUNDS[0].x, BOUNDS[1].x, H, 0)
      );
  }


  /**
   * Create all the roadnetwork from a geoJSON file
   * @param file  geoJSOn file with the roadnetwork
   */
  public void load(String file) {

    processing.data.JSONObject roadNetwork = loadJSONObject(file);
    processing.data.JSONArray lanes = roadNetwork.getJSONArray("features");

    for (int i = 0; i < lanes.size(); i++) {
      processing.data.JSONObject lane = lanes.getJSONObject(i);

      processing.data.JSONObject props = lane.getJSONObject("properties");
      int id = props.isNull("FID") ? -1: props.getInt("FID");
      String name = props.isNull("name") ? "null" : props.getString("name");

      processing.data.JSONArray points = lane.getJSONObject("geometry").getJSONArray("coordinates");
      ArrayList vertices = new ArrayList();

      for (int j = 0; j < points.size(); j++) {
        PVector point = toXY(points.getJSONArray(j).getFloat(1), points.getJSONArray(j).getFloat(0));
        vertices.add(point);
      }

      LANES.add(new Lane(id, name, vertices));
    }
  }


  /**
   * Find point in lane closest to specified position
   * @param position  Position to find closest point in formar lat,lon
   * @returns         closest point position in lane 
   */
  public PVector findClosestPoint(PVector position) {
    Float minDistance = Float.NaN;
    PVector closestPoint = null;

    for (Lane lane : LANES) {
      ArrayList<PVector> vertices = lane.getVertices();

      for (int i = 1; i < vertices.size(); i++) {
        PVector projectedPoint = Geometry.scalarProjection(position, vertices.get(i-1), vertices.get(i));
        float distance = PVector.dist(position, projectedPoint);

        if (minDistance.isNaN() || distance < minDistance) {
          minDistance = distance;
          closestPoint = projectedPoint;
        }
      }
    }

    return closestPoint;
  }


  /**
   * Draw all the lanes into the canvas
   * @param canvas  PGraphics to draw lanes
   * @param stroke  Stroke weight of the lanes
   * @param c       Color of the lanes
   */
  public void draw(PGraphics canvas, int stroke, color c) {
    for (Lane lane : LANES) {
      lane.draw(canvas, stroke, c);
    }
  }
}


/**
 * Simple class that represents a road in the roadnetwork
 * @author    Marc Vilella
 * @modified  Guillem Francisco
 * @version   0.1
 */
protected class Lane {

  private final int ID;
  private final String NAME;
  private final ArrayList<PVector> VERTICES;  


  /**
   * Initiate lane with the required varaibles
   * @param id        ID of the lane
   * @param name      Name of the lane
   * @param vertices  Vertices that compose the lane
   */
  public Lane(int id, String name, ArrayList<PVector> vertices) {
    ID = id;
    NAME = name;
    VERTICES = vertices;
  }

  /**
   * Return vertices of the lane
   * @returns ArrayList with the vertices that compose the lane
   */
  public ArrayList<PVector> getVertices() {
    return VERTICES;
  }

  /**
   * Draw lane into PGraphics
   * @param canvas  Canvas to draw lane
   * @param stroke  Lane width in pixels
   * @param c       Lane color
   */
  public void draw(PGraphics canvas, int stroke, color c) {
    canvas.strokeWeight(stroke);
    canvas.stroke(c);

    for (int i = 1; i < VERTICES.size(); i++) {
      PVector anteriorVertex = VERTICES.get(i-1);
      PVector currentVertex = VERTICES.get(i);
      canvas.line(anteriorVertex.x, anteriorVertex.y, currentVertex.x, currentVertex.y);
    }
  }
}
