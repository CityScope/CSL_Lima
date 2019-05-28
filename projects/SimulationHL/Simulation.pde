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
 * Cells - Class which represents colored cells
 * @author        Javier Zárate
 * @version       1.0
 */
public class Simulation extends PApplet {
  int w;
  int h;


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
   *Create the manual control to change colors limits while running
   **/
  public void draw() {
    simulationCanvas.beginDraw();
    simulationCanvas.background(255);
    roads.draw(simulationCanvas, 1, #E0E3E5);
    roads.readMesh(mesh.celdas, canvas);
    simulationCanvas.endDraw();
    image(simulationCanvas, 0, 0);
  }

  public void mouseClicked() {
    println(red(simulationCanvas.get(mouseX, mouseY)), green(simulationCanvas.get(mouseX, mouseY)), blue(simulationCanvas.get(mouseX, mouseY)), alpha(simulationCanvas.get(mouseX, mouseY)) );
    //println(pois.count());
  }
  void keyPressed() {
    switch(key) {
    case 'd':
      pois.wrappedOptimization();
      break;
    case 's':
      pois.resetLanes();
      break;
    }
  }
}
