/**
 * Artist - A class to manage the drawings of historicals and real time
 * @author    Jesús García
 * @version   0.1
 */
public class Artist {
  private ArrayList<Sensor> SENSORS = new ArrayList<Sensor>();
  private float MIN = 0, MAX = 0;
  private color LOW, HIGH; // #13BCE9, #F7F71B
  private boolean MYSQL = false;
  private boolean DECREASE;
  private Lanes ROADS;
  private MySQLClient MYSQLCLIENT;
  private DynamicLineGraph TGRAPH, HGRAPH;
  private DynamicBanner AGRAPH;
  private NominatimReverseGeocodingJAPI RGEO = new NominatimReverseGeocodingJAPI();


  /**
   * Creates an Artist object
   * @param sensors        list of Sensor objects to draw
   * @param low            color to represent low values
   * @param high           color to represenr high values
   * @param roadnetwork    Lanes object to place the sensors
   * @param mysqlClient    MySQLClient object for historical drawings
   */
  public Artist(ArrayList<Sensor> sensors, color low, color high, Lanes roadnetwork, MySQLClient mysqlClient) {
    SENSORS = sensors;
    LOW = low;
    HIGH = high;
    ROADS = roadnetwork;
    MYSQLCLIENT = mysqlClient;

    Integer[] tempColors = {#555256, #AC3E31, #EA6A47};
    String[] tempAxes = {"TEMP ºC", "Time"};
    TGRAPH = new DynamicLineGraph(420, 160, 3, -10, 30, tempColors, tempAxes);

    Integer[] humColors = {#555256, #1C4E80, #0091D5};
    String[] humAxes = {"HUM %", "Time"};
    HGRAPH = new DynamicLineGraph(420, 160, 3, 0, 100, humColors, humAxes);

    AGRAPH = new DynamicBanner(560, 160, 3, "ADDRESSES");
  }


  /**
   * Toggles between drawing historicals or real time 
   */
  public void toggleMode() {
    MYSQL = !MYSQL;
  }


  /**
   * Transforms a value into a color using a color range 
   * @param value  Value to turned into color
   * @param min    Low color
   * @param max    High color
   * @returns Scaled color
   */
  private color mapColor(float value, float min, float max) {
    if (value > 0) {
      float inter = map(value, min, max, 0, 1);
      return lerpColor(LOW, HIGH, inter);
    } else {
      float inter = map(value, max, min, 1, 0);
      return lerpColor(LOW, HIGH, inter);
    }
  }


  /**
   * Transforms a value into a color using a dynamic range
   * @param value  Value to be turned into color
   * @see mapColor
   */
  private color scaleColor(float value) {
    if (MIN == 0 && MAX == 0) {
      MIN = value - 2;
      MAX = value + 2;
    } else if (value < MIN) {
      MIN = value;
    } else if (value > MAX) {
      MAX = value;
    } 
    return mapColor(value, MIN, MAX);
  }


  /**
   * Transforms (lat, lon) coordinates to (X, Y) positions in the sketch using the Lanes object
   * @param lat  Latitude coordinate
   * @param lon  Longitude coordinate
   * @returns PVector with the (X, Y) coordinates
   */
  private PVector toSketch(float lat, float lon) {
    PVector positionXY = ROADS.findClosestPoint(ROADS.toXY(lat, lon));
    return positionXY;
  }


  /**
   * Draws the real time Sensor instances using a color range
   * @param canvas  Canvas object to draw on
   * @param size    Size of the sensors
   * @param min     Minimum value of the range
   * @param max     Maximum value of the range
   */
  private void drawRealTime(Canvas canvas, int size, float min, float max) {
    canvas.strokeWeight(2);
    for (Sensor sensor : SENSORS) {
      if (!sensor.getType()) {
        Table values = sensor.getVariablesValues();
        PVector lastXY = toSketch(values.getRow(0).getFloat("plat"), values.getRow(0).getFloat("plon"));
        PVector currXY = toSketch(values.getRow(0).getFloat("lat"), values.getRow(0).getFloat("lon"));

        lastXY.x = lerp(lastXY.x, currXY.x, 0.01);
        lastXY.y = lerp(lastXY.y, currXY.y, 0.01);
        lastXY = roadnetwork.findClosestPoint(lastXY);

        if (sensor.getStatus()) canvas.stroke(#D32D41);
        else canvas.stroke(mapColor(values.getRow(0).getFloat("temp"), min, max));
        canvas.fill(mapColor(values.getRow(0).getFloat("temp"), min, max), 180);
        canvas.ellipse(lastXY.x, lastXY.y, size, size);

        if (DECREASE) size -= 0.1;
        if (!DECREASE) size += 0.1;
        if (size < 10) DECREASE = false;
        if (size > 20) DECREASE = true;
      }
    }
  }


  /**
   * Draws the historical Sensor instances
   * @param canvas  Canvas object to draw on
   * @param size    Size of the sensors
   */
  private void drawHistorical(Canvas canvas, int size) {
    if (MYSQLCLIENT.hasChanged()) MIN = MAX = 0;

    canvas.strokeWeight(2);
    for (Sensor sensor : SENSORS) {
      if (sensor.getType()) {
        Table values = sensor.getVariablesValues();
        for (int i = 0; i < values.getRowCount(); i++) {
          TableRow valuesRow = values.getRow(i);
          PVector posXY = toSketch(valuesRow.getFloat("lat"), valuesRow.getFloat("lon"));
          canvas.stroke(scaleColor(valuesRow.getFloat("temp")));
          canvas.fill(scaleColor(valuesRow.getFloat("temp")), 180);
          canvas.ellipse(posXY.x, posXY.y, size, size);
        }
      }
    }
  }


  /**
   * Updates the graphs with the values of the selected real time Sensor
   */
  private void setDashboard() {
    for (Sensor sensor : SENSORS) {
      if (sensor.getStatus()) {
        Table values = sensor.getVariablesValues();
        TableRow valuesRow = values.getRow(0);
        TGRAPH.addDataPoint(valuesRow.getFloat("temp"));
        HGRAPH.addDataPoint(valuesRow.getFloat("hum"));
        String address = RGEO.getAdress(valuesRow.getDouble("lat"), valuesRow.getDouble("lon")).getDisplayName();
        String postCode = RGEO.getAdress(valuesRow.getDouble("lat"), valuesRow.getDouble("lon")).getPostcode();
        AGRAPH.addDataPoint(address.substring(0, address.indexOf(", " + postCode)));
      }
    }
  }


  /**
   * Draws the graphs
   * @param dashboard  PGraphics object to draw on
   * @param font       PFont to be used
   */
  public void drawDashboard(PGraphics dashboard, PFont font) {
    if (!MYSQL) {
      setDashboard();
      dashboard.image(TGRAPH.drawGraph(font), 0, 0);
      dashboard.image(HGRAPH.drawGraph(font), dashboard.width * 0.3, 0);
      dashboard.image(AGRAPH.drawGraph(font), dashboard.width * 0.6, 0);
    }
  }


  /**
   * Draws the color gradient
   * @param canvas PGraphics object to draw on
   * @param title  Title of the gradient
   * @param min    Minimum value in the gradient
   * @param max    Maximum value in the gradient
   * @param w      Width of the gradient
   * @param h      Height of the gradient
   */
  public void drawGradient(PGraphics canvas, String title, String min, String max, float w, float h) {
    canvas.noFill();
    canvas.textFont(myFont);
    for (int i = 0; i <= w; i++) {
      float inter = map(i, 0, w, 0, 1);
      color c = lerpColor(LOW, HIGH, inter);
      canvas.stroke(c);
      canvas.line(i, 0, i, h);
    }

    // Legend
    canvas.pushMatrix();
    canvas.translate(0, 0);
    canvas.fill(0); 
    canvas.noStroke(); 
    canvas.textSize(10); 
    canvas.textAlign(CENTER, TOP);
    canvas.text(title, w/2, 0);
    canvas.textSize(9); 
    canvas.textAlign(LEFT, BOTTOM);
    if (!MYSQL) canvas.text(min, 0, h);
    else canvas.text(round(MIN), 0, h);
    canvas.textAlign(RIGHT, BOTTOM);
    if (!MYSQL) canvas.text(max, w, h);
    else canvas.text(round(MAX), w, h);
    canvas.popMatrix();
  }


  /**
   * Draws the sensors
   * @param canvas  Canvas object to draw on
   * @param size    Size of the sensors
   * @param min     Minimum value of the range
   * @param max     Maximum value of the range
   */
  public void draw(Canvas canvas, int size, float min, float max) {
    if (MYSQL) drawHistorical(canvas, size);
    else drawRealTime(canvas, size, min, max);
  }
}
