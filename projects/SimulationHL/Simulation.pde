import org.apache.commons.math3.optim.PointValuePair;
import org.apache.commons.math3.optim.linear.LinearConstraint;
import org.apache.commons.math3.optim.linear.LinearConstraintSet;
import org.apache.commons.math3.optim.linear.LinearObjectiveFunction;
import org.apache.commons.math3.optim.linear.Relationship;
import org.apache.commons.math3.optim.linear.SimplexSolver;
import org.apache.commons.math3.optim.nonlinear.scalar.GoalType;

import java.util.Collections;
import java.util.*;
import org.gicentre.utils.stat.*;

import java.lang.Integer;
import java.lang.Double;


PGraphics simulationCanvas;
boolean addPossibleWarehouse = false;
boolean addAffectedArea = false;
boolean removePOI = false;
final String roadsPath = "mirafloresRoad.geojson";
final String poiPath = "muestreoPOI.csv";

Roads roads;
POIs pois;


/**
 * Simulation - Class to control the Simulation
 * @author        Javier Zárate
 * @version       1.0
 */
public class Simulation extends PApplet {
  int w;
  int h;
  boolean result = false;


  public Simulation( int w, int h) {
    this.w = w;
    this.h = h;
  }


  public void settings() {
    size(this.w, this.h);
  }


  public void setup() {
    simulationCanvas = createGraphics(this.w, this.h);
    roads = new Roads(roadsPath, simulationCanvas);
    pois = new POIs();
    pois.loadCSV(poiPath, roads);
  }


  /**
   * Create the manual control to change colors limits while running
   */
  public void draw() {
    simulationCanvas.beginDraw();
    simulationCanvas.background(255);
    roads.draw(simulationCanvas, 1);
    roads.readMesh(mesh.cells, canvas);
    simulationCanvas.pushStyle();
    simulationCanvas.fill(0, 0, 0);
    simulationCanvas.textSize(25);
    simulationCanvas.textAlign(LEFT);     
    simulationCanvas.text("Objective function result:", 100, 650);
    if (!result) simulationCanvas.text("No solution found!", 100, 680);
    else simulationCanvas.text(String.valueOf(pois.MINIMUM), 100, 680);    
    simulationCanvas.popStyle();
    simulationCanvas.endDraw();
    image(simulationCanvas, 0, 0);
  }


  void keyPressed() {
    switch(key) {
    case 'd':
      result = pois.wrappedOptimization();
      break;

    case 's':
      pois.resetLanes();
      break;
    }
  }
}
