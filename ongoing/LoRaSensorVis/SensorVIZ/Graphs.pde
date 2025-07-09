/**
 * DynamicGraph - Abstract class for showing the recently collected data
 * @author    Jesús García
 * @version   0.1
 */
public abstract class DynamicGraph {
  protected PGraphics SLATE;
  protected int LIMIT;
  protected ArrayList<Object> DATALIST = new ArrayList<Object>();


  /**
   * Creates a DynamicGraph object
   * @param w      Width of the graph's slate
   * @param h      Height of the graph's slate
   * @param limit  Number of values to be shown
   */
  public DynamicGraph(int w, int h, int limit) {
    SLATE = createGraphics(w, h);
    LIMIT = limit;
  }


  /**
   * Adds data to the graph
   * @param dataPoint  New data to be added
   */
  protected abstract void addDataPoint(Object dataPoint);


  /**
   * Draw the graph on its slate
   * @param font  Font to be used when drawing
   * @returns The slate as a PGraphics
   */
  protected abstract PGraphics drawGraph(PFont font);
}


/**
 * DynamicLineGraph - Extends DynamicGraph. A class to display the data as a line graph
 * @author    Jesús García
 * @version   0.1
 */
public class DynamicLineGraph extends DynamicGraph {
  private Integer[] colorList;
  private String[] labels;
  private int min, max;


  /**
   * Creates a DynamicLineGraph object
   * @param w        Width of the graph's slate
   * @param h        Height of the graph's slate
   * @param limit    Number of values to be shown
   * @param low      Lowest value of the Y-axis
   * @param high     Highest value of the Y-axis
   * @param colors   Colors for the graph
   * @param axes     Labels for the axes
   */
  public DynamicLineGraph(int w, int h, int limit, int low, int high, Integer[] colors, String[] axes) {
    super(w, h, limit);
    min = low;
    max = high;
    colorList = colors;
    labels = axes;
  }


  /**
   * Adds data to the graph
   * @param dataPoint  New data to be added
   */
  @Override
    public void addDataPoint(Object dataPoint) {
    float point = (float) dataPoint;

    if (DATALIST.size() < LIMIT) DATALIST.add(point);
    else {
      DATALIST.remove(DATALIST.get(0));
      DATALIST.add(point);
    }
  }


  /**
   * Draw the graph on its slate
   * @param font  Font to be used when drawing
   * @returns The slate as a PGraphics
   */
  @Override
    public PGraphics drawGraph(PFont font) {
    float lineWidth = (float) 0.8 * SLATE.width/(DATALIST.size() - 1);
    SLATE.beginDraw();
    SLATE.textFont(font);

    SLATE.stroke(colorList[0]);
    SLATE.strokeWeight(6);
    SLATE.fill(0);
    SLATE.rect(0, 0, SLATE.width, SLATE.height);

    SLATE.stroke(colorList[1]);
    SLATE.strokeWeight(6);
    SLATE.line(SLATE.width/10, 0.8 * SLATE.height, 0.9 * SLATE.width, 0.8 * SLATE.height);
    SLATE.line(SLATE.width/10, SLATE.height/8, SLATE.width/10, 0.8 * SLATE.height);

    SLATE.stroke(colorList[2]);
    SLATE.strokeWeight(4);
    SLATE.textSize(0.13 * SLATE.height);
    for (int i = 0; i < DATALIST.size() - 1; i++) {
      SLATE.pushMatrix();
      SLATE.scale(1, -1);
      SLATE.translate(0, -SLATE.height);
      SLATE.ellipse(i * lineWidth + SLATE.width/10, map((Float) DATALIST.get(i), min, max, SLATE.height/8, 0.8 * SLATE.height), 0.05 * SLATE.width, 0.05 * SLATE.width);
      SLATE.line(i * lineWidth + SLATE.width/10 + 0.05 * SLATE.width/2, map((Float) DATALIST.get(i), min, max, SLATE.height/8, 0.8 * SLATE.height), (i+1) * lineWidth + SLATE.width/10, 
        map((Float) DATALIST.get(i+1), min, max, SLATE.height/8, 0.8 * SLATE.height));
      SLATE.pushStyle();
      SLATE.fill(0);
      SLATE.ellipse((i+1) * lineWidth + SLATE.width/10, map((Float) DATALIST.get(i+1), min, max, SLATE.height/8, 0.8 * SLATE.height), 0.05 * SLATE.width, 0.05 * SLATE.width);
      SLATE.scale(1, -1);
      SLATE.fill(255);
      SLATE.text(str((Float) DATALIST.get(i)), (i) * lineWidth + SLATE.width/10, -(map((Float) DATALIST.get(i), min, max, SLATE.height/8, 0.8 * SLATE.height) + 0.1 * SLATE.height));
      SLATE.text(str((Float) DATALIST.get(i+1)), (i+1) * lineWidth + SLATE.width/10, -(map((Float) DATALIST.get(i+1), min, max, SLATE.height/8, 0.8 * SLATE.height) + 0.1 * SLATE.height));
      SLATE.popStyle();
      SLATE.popMatrix();
    }

    SLATE.textSize(0.15 * SLATE.height);
    SLATE.fill(255);

    SLATE.pushStyle();
    SLATE.textAlign(CENTER, TOP);
    SLATE.text(labels[1], SLATE.width/2, 0.8 * SLATE.height);
    SLATE.popStyle();

    SLATE.pushStyle();
    SLATE.textAlign(CENTER);
    SLATE.rotate(-HALF_PI);
    SLATE.text(labels[0], -SLATE.width/5.5, SLATE.height/6);
    SLATE.popStyle();
    SLATE.endDraw();

    return SLATE;
  }
}


/**
 * DynamicBanner - Extends DynamicGraph. A class to display coordinates as addresses
 * @author    Jesús García
 * @version   0.1
 */
public class DynamicBanner extends DynamicGraph {
  private String label;

  public DynamicBanner(int w, int h, int limit, String lbl) {
    super(w, h, limit);
    label = lbl;
  }


  /**
   * Adds data to the graph
   * @param dataPoint  New data to be added
   */
  @Override
    public void addDataPoint(Object dataPoint) {
    String sentence = (String) dataPoint;

    if (DATALIST.size() < LIMIT) DATALIST.add(sentence);
    else {
      DATALIST.remove(DATALIST.get(0));
      DATALIST.add(sentence);
    }
  }


  /**
   * Draw the graph on its slate
   * @param font  Font to be used when drawing
   * @returns The slate as a PGraphics
   */
  @Override
    public PGraphics drawGraph(PFont font) {
    SLATE.beginDraw();
    SLATE.textFont(font);

    SLATE.stroke(#555256);
    SLATE.strokeWeight(6);
    SLATE.fill(0);
    SLATE.rect(0, 0, SLATE.width, SLATE.height);

    SLATE.fill(255);
    SLATE.textSize(0.09 * SLATE.height);
    for (int i = 1; i < DATALIST.size() + 1; i++) {
      SLATE.textAlign(CENTER);
      SLATE.text((String) DATALIST.get(i-1), SLATE.width/2, 0.25 * SLATE.height * i + 0.08 * SLATE.height);
    }

    SLATE.pushStyle();
    SLATE.textAlign(CENTER, TOP);
    SLATE.textSize(0.15 * SLATE.height);
    SLATE.text(label, SLATE.width/2, 0);
    SLATE.popStyle();
    SLATE.endDraw();

    return SLATE;
  }
}


//public class CalendarGrid {
//  private PGraphics slate;
//  private int cols, rows;
//  private int scale = 25;
//  private int low, high, gradW, gradH;
//  private Table points = new Table();
//  private ArrayList<Timestamp> timeRange = new ArrayList<Timestamp>();
//  private ArrayList<String> columnLabels = new ArrayList<String>();
//  private ArrayList<String> rowLabels = new ArrayList<String>();
//  private String[] colors;
//  private Timestamp start, end;
//  private Calendar calendar = Calendar.getInstance();


//  public CalendarGrid(int w, int h) {
//    slate = createGraphics(w, h);
//    cols = w/scale;
//    rows = h/scale;
//    gradW = scale;
//    gradH = slate.height - scale;
//  }


//  public void setData (Table data, String[] colorColumn, SimpleDateFormat format, int max, int min) {
//    points = data;
//    low = min;
//    high = max;
//    colors = colorColumn;
//    setColumnLabels(format);
//    setRowLabels();
//    setPositions(format);
//  }


//  private void setColumnLabels(SimpleDateFormat format) {
//    TableRow first = points.getRow(0);
//    String t1 = first.getString("timestamp");
//    columnLabels.add(t1);

//    start = stringToTimestamp(t1, format);
//    timeRange.add(start);

//    TableRow last = points.getRow(points.getRowCount() - 1);
//    String t2 = last.getString("timestamp");
//    end = stringToTimestamp(t2, format);

//    long difference = end.getTime() - start.getTime();
//    int step = (int) difference/cols;

//    calendar.setTimeInMillis(start.getTime());
//    for (int i = 0; i < cols; i++) {
//      calendar.add(Calendar.MILLISECOND, step);
//      Timestamp timestamp = new Timestamp(calendar.getTime().getTime());
//      timeRange.add(timestamp);
//      columnLabels.add(timestampToString(timestamp, format));
//    }
//  }


//  private void setRowLabels() {
//    int step = (high - low)/rows;
//    for (int i = 0; i < rows + 1; i++) {
//      rowLabels.add(str(low + i * step));
//    }
//  }


//  private void setPositions(SimpleDateFormat format) {
//    for (TableRow row : points.rows()) {
//      String timeString = row.getString("timestamp");
//      Timestamp timestamp = stringToTimestamp(timeString, format);

//      for (int i = 0; i < timeRange.size() - 1; i++) {
//        if ((timestamp.after(timeRange.get(i)) || timestamp.equals(timeRange.get(i))) && timestamp.before(timeRange.get(i + 1))) {
//          row.setFloat("lon", ((i + i + 1) * scale) + scale/2);
//        } else if (timestamp.after(timeRange.get(i)) && (timestamp.equals(timeRange.get(i + 1)))) {
//          row.setFloat("lon", ((i + i - 1) * scale) + scale/2);
//        } else {
//          println("Missing point!");
//        }
//      }

//      float temp = map(row.getFloat("temp"), low, high, gradH - scale/3, scale/3);
//      row.setFloat("lat", temp);
//    }
//  }


//  private Timestamp stringToTimestamp(String time, SimpleDateFormat format) {
//    try {
//      Timestamp timestamp = new Timestamp(format.parse(time).getTime());
//      return timestamp;
//    } 
//    catch (Exception e) {
//      println(e);
//      return null;
//    }
//  }


//  private String timestampToString(Timestamp time, SimpleDateFormat format) {
//    String timeString = format.format(time);
//    return timeString;
//  }


//  public PGraphics draw(color min, color max, PFont font) {
//    slate.beginDraw();
//    slate.background(0);
//    drawGrid();
//    drawGradient(min, max);
//    drawLabels(font);
//    drawPoints();
//    slate.endDraw();

//    return slate;
//  }


//  private void drawGrid() {
//    slate.fill(255);
//    slate.stroke(0, 50);

//    for (int c = 1; c < cols; c++) {
//      for (int r = 0; r < rows - 1; r++) {
//        int x = c * scale;
//        int y = r * scale;        
//        slate.rect(x, y, scale, scale);
//      }
//    }
//  }


//  private void drawGradient(color min, color max) {
//    slate.noFill();
//    for (int i = 0; i <= gradH; i++) {
//      float inter = map(i, 0, gradH, 0, 1);
//      color c = lerpColor(min, max, inter);
//      slate.stroke(c);
//      slate.line(0, i, gradW, i);
//    }
//  }


//  private void drawLabels(PFont font) {
//    slate.textFont(font);
//    slate.textSize(7);
//    for (int c = 1; c < cols; c++) {
//      slate.text(columnLabels.get(c - 1).split(" ")[0], c * scale, (rows - 1) * scale + 10.5);
//      slate.text(columnLabels.get(c - 1).split(" ")[1], c * scale, (rows - 1) * scale + 21);
//    }

//    slate.fill(0);
//    for (int r = 1; r < rows; r++) {
//      slate.text(rowLabels.get(r - 1), scale - 12, slate.height - r * scale);
//    }
//  }


//  private void drawPoints() {
//    slate.strokeWeight(1.5);
//    slate.stroke(0);
//    for (int i = 0; i < points.getRowCount(); i++) {
//      TableRow row = points.getRow(i);
//      slate.fill(Integer.parseInt(colors[i]));
//      slate.ellipse(row.getFloat("lon"), row.getFloat("lat"), scale/3, scale/3);
//    }
//  }
//}
