/**
 * POIs - Facade to simplify manipulation of Points of Interest in simulation
 * @author        Marc Vilella & Javier Zarate
 * @version       1.1
 * @see           Facade
 */
public class POIs extends Facade<POI> {
  public double MINIMUM;

  /**
   * Initiate points of interest facade and agents' Factory
   * @param roads  Roadmap where agents will be placed and move
   */
  public POIs() {
    factory = new POIFactory();
  }


  public void loadCSV(String path, Roads roadmap) {
    File file = new File( dataPath(path) );
    if ( !file.exists() ) println("ERROR! CSV file does not exist");
    else items.addAll( ((POIFactory)factory).loadCSV(path, roadmap) );
  }


  public void deletePOI(PVector position, float threshold) {
    for (POI poi : pois.getAll()) {
      boolean nearSelection = dist(position.x, position.y, poi.position.x, poi.position.y) <= threshold;
      if (nearSelection) {
        for (Lane lane : poi.outboundLanes()) {

          if (poi.paths.size() > 0) {
            int index = 0;
            for (Path path : poi.paths) {
              for (Lane l : path.lanes) {
                Double quantity = new Double((Double)poi.quantity.get(index));
                l.load -= quantity.intValue();
              }
              index++;
            }
            for (POI p : poi.poisToGo) {
              p.chosen --;
            }
          }

          roads.delete(lane.initNode);
          roads.delete(lane.finalNode);
        }
        pois.delete(poi);
        break;
      }
    }
  }


  public double[][] getDistance() {
    ArrayList<POI> warehouses = pois.filter(Filters.isType("ZONA_SEGURA"));
    ArrayList<POI> affectedZone = pois.filter(Filters.isType("affectedArea"));
    double[][] weights = new double[affectedZone.size()][warehouses.size()];
    for (int i = 0; i < affectedZone.size(); i++) {
      for (int j = 0; j < warehouses.size(); j++) {
        Path tempPath = new Path(affectedZone.get(i), roads);
        tempPath.findPath(affectedZone.get(i), warehouses.get(j));          
        float distWarehouse = tempPath.calcLength() + warehouses.get(j).price ;
        weights[i][j] = distWarehouse;
      }
    }
    return weights;
  }


  public ArrayList noNegativeConstraints(int rows, int columns, ArrayList<LinearConstraint> constraints) {
    int n = rows * columns;
    int indexNN = 0;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        double[] eqgX = new double[n];
        eqgX[indexNN] = 1;
        indexNN++;
        constraints.add(new LinearConstraint(eqgX, Relationship.GEQ, 0));  //No negative restrictions         
        print (i, " ");
        for (double ct : eqgX) {
          print(ct, " ");
        }
        print(" >0");
        println();
      }
    }
    return constraints;
  }


  public double[] objectiveFunction(int rows, int columns, double[][] dists) {
    int n = rows * columns;
    double[] singleDists = new double[n];
    int indexW = 0;
    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < columns; j++) {
        singleDists[indexW] = dists[i][j];
        indexW++;
      }
    }
    for (double ja : singleDists) {
      print(ja, " ");
    }
    println();
    return singleDists;
  }


  public ArrayList capacityConstraint(int rows, int columns, ArrayList<LinearConstraint> constraints, ArrayList<POI> supplies) {
    int n = rows * columns;
    for (int i= 0; i < columns; i++) {
      int maxCapacity = supplies.get(i).CAPACITY;
      print(i, "| ");
      double[] maxCapacityBound = new double[n];
      int inc = 0;
      for (int j = 0; j < rows; j++) {
        print((i+inc), " ");
        maxCapacityBound[i+inc] = 1;
        inc += columns;
      }
      constraints.add(new LinearConstraint(maxCapacityBound, Relationship.LEQ, maxCapacity));
      println();
      for (double ja : maxCapacityBound) {
        print(ja, " ");
      }
      println(" < capacity| ", maxCapacity);
    }
    return constraints;
  }


  public ArrayList demandConstraint(int rows, int columns, ArrayList<LinearConstraint> constraints, ArrayList<POI> demands) {
    int n = rows * columns;
    int index = 0;
    for (int i= 0; i < rows; i++) {
      print(i, "| ");
      double[] qBound = new double[n];
      for (int j = 0; j < columns; j++) {
        print(index, " ");
        qBound[index] = 1;
        index ++;
      }
      constraints.add(new LinearConstraint(qBound, Relationship.EQ, demands.get(i).CAPACITY));
      println();
      for (double ja : qBound) {
        print(ja, " ");
      }
      println(" = demand| ", demands.get(i).CAPACITY);
    }
    return constraints;
  }


  public boolean simplexMethod(double[] weights, ArrayList<LinearConstraint> constraints, int rows, int columns, ArrayList<POI> supplies, ArrayList<POI> demands) {
    LinearObjectiveFunction funct = new LinearObjectiveFunction(weights, 0);
    PointValuePair solution = null;
    try {
      solution = new SimplexSolver().optimize(funct, new LinearConstraintSet(constraints), GoalType.MINIMIZE);
      this.initializePOIStoGo();
      if (solution != null) {
        //get solution
        MINIMUM = solution.getValue();
        println("Opt: " + MINIMUM);
        int indexSelect = 0;
        int indexSelect1 = 0;
        //print decision variables
        int n = rows * columns;
        for (int i = 0; i < n; i++) {
          POI temporalPOI = demands.get(indexSelect);
          if (solution.getPoint()[i]!=0) {
            supplies.get(indexSelect1).chosen ++;
            temporalPOI.poisToGo.add(supplies.get(indexSelect1));
            temporalPOI.quantity.add(solution.getPoint()[i]);
          }
          demands.get(indexSelect).affectedPeople -= solution.getPoint()[i] ;
          supplies.get(indexSelect1).CAPACITY -=solution.getPoint()[i];
          indexSelect1++;
          print(solution.getPoint()[i] + "\t");
          if ((i+1)%(columns)==0) { 
            println(); 
            indexSelect++; 
            indexSelect1=0;
          }
        }
        return true;
      }
      return false;
    } 
    catch (Exception e) {
      println("An error occurred!");
      return false;
    }
  }


  public void resetLanes() {
    ArrayList<POI> affectedZone = pois.filter(Filters.isType("affectedArea"));
    for (POI poi : affectedZone) {
      for (Path path : poi.paths) {
        for (Lane lane : path.lanes) {
          lane.load = 0;
        }
      }
    }
  }


  public boolean simplexOptimization(double[][] dists) {
    ArrayList<POI> warehouses = pois.filter(Filters.isType("ZONA_SEGURA"));
    ArrayList<POI> affectedZone = pois.filter(Filters.isType("affectedArea"));
    double[] weigths;
    int rows; //demands
    int columns; //supplies
    int n;
    rows = dists.length;
    columns = dists[0].length;
    n = rows * columns;
    println(rows, columns);

    Collection<LinearConstraint> constraints = new ArrayList<LinearConstraint>();
    weigths = new double[n];

    weigths = this.objectiveFunction(rows, columns, dists);
    constraints = this.noNegativeConstraints(rows, columns, (ArrayList<LinearConstraint>) constraints);
    constraints = this.capacityConstraint(rows, columns, (ArrayList<LinearConstraint>) constraints, warehouses);
    constraints = this.demandConstraint(rows, columns, (ArrayList<LinearConstraint>) constraints, affectedZone);
    return simplexMethod(weigths, (ArrayList<LinearConstraint>) constraints, rows, columns, warehouses, affectedZone);
  }


  public boolean wrappedOptimization() {
    double[][] dists = this.getDistance();
    resetLanes();
    boolean result = simplexOptimization(dists);
    getPaths();
    quantities();
    return result;
  }


  public void getPaths() {
    ArrayList<POI> affectedZone = pois.filter(Filters.isType("affectedArea"));
    for (POI poi : affectedZone) {
      poi.getPathPOIS();
    }
  }


  public void initializePOIStoGo() {
    ArrayList<POI> affectedZone = pois.filter(Filters.isType("affectedArea"));
    for (POI poi : affectedZone) {
      poi.resetPOIs();
    }
  }


  public void quantities() {
    ArrayList<POI> affectedZone = pois.filter(Filters.isType("affectedArea"));
    for (POI poi : affectedZone) {
      int index = 0;
      for (Path path : poi.paths) {
        Double quantity = new Double((Double)poi.quantity.get(index));
        for (Lane lane : path.lanes) {
          lane.load += quantity.intValue();
        }
        index++;
      }
    }
  }
}


/**
 * POIFactory - Factory to generate diferent Points of Interest from diferent sources 
 * @author        Marc Vilella
 * @version       1.0
 * @see           Factory
 */
private class POIFactory extends Factory {

  /**
   * Not used
   */
  public ArrayList<POI> loadJSON(File JSONFile, Roads roads) {
    print("Loading POIs... ");
    ArrayList<POI> pois = new ArrayList<POI>();
    int count = count();
    JSONArray JSONPois = loadJSONObject(JSONFile).getJSONArray("features");
    for (int i = 0; i < JSONPois.size(); i++) {
      JSONObject poi = JSONPois.getJSONObject(i);

      JSONObject props = poi.getJSONObject("properties");

      String name    = props.isNull("name") ? "null" : props.getString("name");
      String type    = props.isNull("type") ? "null" : props.getString("type");
      int capacity   = props.isNull("CAPACITY") ? 10 : props.getInt("CAPACITY");
      float precio   = props.isNull("precio") ? 10 : props.getInt("CAPACITY");

      JSONArray coords = poi.getJSONObject("geometry").getJSONArray("coordinates");
      PVector location = roads.toXY( coords.getFloat(1), coords.getFloat(0) );
      if ( location.x > 0 && location.x < width && location.y > 0 && location.y < height ) {
        pois.add( new POI(roads, str(count), name, type, location, capacity, precio) );
        counter.increment(type);
        count++;
      }
    }
    println("LOADED");
    return pois;
  }


  public ArrayList<POI> loadCSV(String path, Roads roads) {
    print("Loading POIs... ");
    ArrayList<POI> pois = new ArrayList();
    int count = count();

    Table table = loadTable(path, "header");
    for (TableRow row : table.rows()) {
      String name = row.getString("NOMBRE");
      PVector location = roads.toXY(row.getFloat("GEO_Y"), row.getFloat("GEO_X"));
      Float capacity = row.getFloat("CAPACIDAD");
      if (Float.isNaN(capacity)) { 
        capacity = 30.0;
      }
      String type = row.getString("HOMOLOGACION");
      float price = row.getFloat("precio");
      pois.add( new POI(roads, str(count), name, type, location, int(capacity), price));
      counter.increment(type); 
      count++;
    }
    println("LOADED");
    return pois;
  }
}


/**
 * POI -  Abstract class describing a Point of Interest, that is a destination for agents in simulation
 * @author        Marc Vilella
 * @version       2.0
 */
public class POI extends Node {

  protected final String ID;
  protected final String NAME;
  protected int CAPACITY;

  protected float size = 2;
  public String TYPE;
  public float price;
  public ArrayList<POI> poisToGo = new ArrayList<POI>();
  public ArrayList quantity = new ArrayList();
  public ArrayList<Path> paths = new ArrayList<Path>();

  public int chosen = 0;
  public color ownColor;
  int affectedPeople;


  /**
   * Initiate POI with specific name and capacity, and places it in the roadmap
   * @param roads  Roadmap to place the POI
   * @param id  ID of the POI
   * @param position  Position of the POI
   * @param name  name of the POI
   * @param capacity  Customers capacity of the POI
   */
  public POI(Roads roads, String id, String name, String type, PVector position, int capacity, float price) {
    super(position);
    ID = id;
    NAME = name;
    CAPACITY = capacity;
    TYPE = type;
    this.price = price;
    place(roads);
  }


  public void resetPOIs() {
    this.poisToGo = new ArrayList<POI>();
    this.quantity = new ArrayList();
    this.paths = new ArrayList<Path>();
  }


  public void getPathPOIS() {
    for (POI poi : poisToGo) {
      Path tempPath = new Path(this, roads);
      tempPath.findPath(this, poi);
      paths.add(tempPath);
    }
  }


  /**
   * Create a node in the roadmap linked to the POI and connects it to the closest lane
   * @param roads  Roadmap to add the POI
   */
  public void place(Roads roads) {
    roads.connect(this);
  } 


  /**
   *Check the type of a POI
   */
  public boolean isType(String type) {
    if (TYPE.equals(type)) {
      return true;
    }
    return false;
  }


  /**
   * Get POI drawing size
   * @return POI size
   */
  public float getSize() {
    return size;
  }


  /**
   * Draw POI in screen, with different effects depending on its status
   */
  @Override
    public void draw(PGraphics canvas, int stroke) {
    color occColor = color(200, 150, 0);
    float fsize = this.size;
    canvas.rectMode(CENTER); 
    canvas.noFill(); 
    canvas.stroke(occColor); 
    canvas.strokeWeight(1);
    if (this.chosen > 0) { 
      occColor = color(120, 100, 50); 
      fsize *= 4; 
      canvas.stroke(occColor); 
      canvas.strokeWeight(1.5);
    }
    if (this.TYPE.equals("affectedArea")) canvas.stroke(200, 10, 0);
    canvas.rect(position.x, position.y, fsize, fsize);
    canvas.textAlign(CENTER, BOTTOM); 
    canvas.strokeWeight(2);
    canvas.fill(0);
    canvas.text(this.toString(), position.x, position.y - size / 2);
    if (selected) {
      canvas.fill(0); 
      canvas.textAlign(CENTER, BOTTOM);
      canvas.text(this.toString(), position.x, position.y - size / 2);
    }
  }


  /**
   * Select POI if mouse is hover
   * @param mouseX  Horizontal mouse position in screen
   * @param mouseY  Vertical mouse position in screen
   * @return true if POI is selected, false otherwise
   */
  public boolean select(int mouseX, int mouseY) {
    selected = dist(position.x, position.y, mouseX, mouseY) <= size;
    return selected;
  }


  /**
   * Return agent description (NAME, OCCUPANCY and CAPACITY)
   * @return POI description
   */
  public String toString() {
    return this.ID + " | " + str(this.CAPACITY);
  }
}


public class Warehouse extends POI {  
  public Warehouse(Roads roads, String id, String name, String type, PVector position, int capacity, int price) {
    super(roads, id, name, type, position, capacity, price);
    pois.add(this);
  }
}


public class AffectedArea extends POI {
  protected int explodeSize = 0;
  protected int[] dists;


  public AffectedArea(Roads roads, String id, String name, String type, PVector position, int capacity, int price) {
    super(roads, id, name, type, position, capacity, price);
    this.affectedPeople = capacity;
    pois.add(this);
  }


  @Override
    public void draw(PGraphics canvas, int stroke) {
    float factor = 0.01;
    color occColor = this.ownColor;
    canvas.fill(occColor, 50); 
    canvas.noStroke();
    explodeSize = (this.explodeSize + 1)  % 30;
    canvas.ellipse(position.x, position.y, CAPACITY*factor*explodeSize, CAPACITY*factor*explodeSize);
    canvas.textAlign(CENTER, BOTTOM); 
    canvas.strokeWeight(2);
    canvas.fill(0);
    canvas.text(toString(), position.x, position.y - size / 2);
  }


  @Override
    public String toString() {
    return "ID: "  + this.ID + " | " + str(this.affectedPeople);
  }
}
