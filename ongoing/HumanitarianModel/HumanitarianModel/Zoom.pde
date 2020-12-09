/**
 * @copyright: Copyright (C) 2018
 * @legal:
 * This file is part of HumanitarianModel.
 
 * HumanitarianModel is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * HumanitarianModel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with HumanitarianModel.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * Zoom - Extends PApplet. Class which represents a zoomed portion of a main sketch
 * @see:       Grapho
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1 
 */
public class Zoom{
//public class Zoom extends PApplet {
  private GraphNode START;
  private GraphNode END;
  //private boolean ADDS;
  //private boolean DELETES;
  private boolean SELECTED;
  private int WIDTH;
  private int HEIGHT;
  private String PARENT = null;
  private String PATH;
  private PVector SIDE1;
  private PVector SIDE2;
  private Grapho GRAPHO;


  /**
   * Creates Zoom object as an extension of a principal sketch
   * @param: parent  PApplet object
   * @param: width   Width of this PApplet
   * @param: height  Height of this PApplet
   */
  public Zoom(PApplet parent, Grapho grapho, int w, int h) {
    WIDTH = w;
    HEIGHT = h;
    PARENT = parent.sketchPath();
    PATH = PARENT + "/data/calibration.json";
    GRAPHO = grapho;
    loadJSON(PATH);
  }


  /**
   * Loads the two guiding points from a JSON file
   * @param: path  Path to the JSON file
   */
  private void loadJSON(String path) {
    JSONObject rectParameter = loadJSONObject(path);
    SIDE1 = new PVector(rectParameter.getJSONArray("Side1").getFloat(0), rectParameter.getJSONArray("Side1").getFloat(1));
    SIDE2 = new PVector(rectParameter.getJSONArray("Side2").getFloat(0), rectParameter.getJSONArray("Side2").getFloat(1));
  }


  /**
   * P3D needs to be passed as an argument to enable the use of vertices
   */
  //public void settings() {
  //  size(WIDTH, HEIGHT, P3D);
  //}


  //public void setup() {
  //  
  //  CANVASZOOM = createGraphics(WIDTH, HEIGHT, P3D);
  //  KS = new Keystone(this);
  //  SURFACE = KS.createCornerPinSurface(WIDTH, HEIGHT, 20);
  //}


  public void draw(PGraphics CANVASZOOM) {
    strokeWeight(5);
    rect(970,420,height/2,height/2);
    CANVASZOOM.beginDraw();
    CANVASZOOM.background(255);
    CANVASZOOM.scale(CANVASZOOM.width/(SIDE2.x - SIDE1.x));
    CANVASZOOM.translate(-SIDE1.x, -SIDE1.y);
    CANVASZOOM.strokeWeight(0.15);
    GRAPHO.draw(CANVASZOOM, true);
    CANVASZOOM.endDraw();
    image(CANVASZOOM,970,420);
  }


  public void pressedZoom() {
    PVector mouseXY = toXYAntiZoom(new PVector(mouseX-970, mouseY-420));
    START = GRAPHO.getGraph().getNodeAt(mouseXY.x, mouseXY.y, 0, 0.25f);
  }

  public void addNode() {
    if(END != null && START != null){
      boolean ge = GRAPHO.addLane(START.id(), END.id());
      println(ge); 
    }else{
      print("Please select a compatible START and END node");
    }
  }
  
  public void deleteNode(){
    PVector mouseXY = toXYAntiZoom(new PVector(mouseX-970, mouseY-420));
    END = GRAPHO.getGraph().getNodeAt(mouseXY.x, mouseXY.y, 0, 0.25f);
    if(END != null && START != null){
      boolean ge = GRAPHO.deleteLane(START.id(), END.id());
      println(ge);
    }else{
      print("Please select a compatible START and END node");
    }    
  }
  
  
  //public void mouseReleased() {
  //  if (DELETES) {
  //    PVector mouseXY = toXYAntiZoom(new PVector(mouseX, mouseY));
  //    END = GRAPHO.getGraph().getNodeAt(mouseXY.x, mouseXY.y, 0, 0.25f);
  //    if(END != null && START != null){
  //      boolean ge = GRAPHO.deleteLane(START.id(), END.id());
  //      println(ge);
  //    }else{
  //      print("Please select a compatible START and END node");
  //    }
  //  }
  //  if (ADDS) {
  //    boolean ge = GRAPHO.addLane(START.id(), END.id());
  //    println(ge);
  //  }
  //}


  public void clickZoom() {
    PVector mouseXY = toXYAntiZoom(new PVector(mouseX-970, mouseY-420));
    POI p = GRAPHO.getPOIAt(mouseXY.x, mouseXY.y, 0.25f);
    if (!DELETES) {
      GRAPHO.linkPoi(p);
      SELECTED = !SELECTED;
      if (SELECTED) {
        GRAPHO.toggleShow();
        SELECTED = !SELECTED;
      }
    }
  }


  ///**
  // * Performs certain actions when a key is pressed
  // * @case: 'a' - Add point mode
  // * @case: 'd' - Delete point mode 
  // * @case: 'g' - Load square properties
  // * @case: 'k' - Calibrate keystone canvas
  // * @case: 'l' - Load keystone canvas
  // * @case: 's' - Save keystone canvas
  // */
  //public void keyPressed() {
  //  switch(key) { 
  //  case 'a':
  //    ADDS = !ADDS;
  //    DELETES = false;
  //    println("add = ", ADDS, " delete = ", DELETES);
  //    break;

  //  case 'd':
  //    DELETES = !DELETES;
  //    ADDS = false;
  //    println("add = ", ADDS, " delete = ", DELETES);
  //    break;

  //  case 'g':
  //    saveJSON();
  //    break;

  //  case 'k':
  //    KS.toggleCalibration();
  //    break;

  //  case 'l':
  //    if (PARENT != null) {
  //      KS.load(PARENT + "/data/keystone.xml");
  //    } else {
  //      KS.load(sketchPath() +"/data/keystone.xml");
  //    }
  //    break;

  //  case 's':
  //    if (PARENT != null) {
  //      KS.save(PARENT + "/data/keystone.xml");
  //    } else {
  //      KS.save( sketchPath() +"/data/keystone.xml");
  //    }  
  //    break;
  //  }
  //}


  /**
   * Maps mouse to principal sketch coordinates
   * @param: xy  Mouse coordinates
   */
  public PVector toXYAntiZoom(PVector xy) {
    return new PVector(
      map(xy.x, 0, WIDTH, int(SIDE1.x), int(SIDE2.x)),
      map(xy.y, 0, HEIGHT, int(SIDE1.y), int(SIDE2.y))
      );
  }


  /**
   * Draws the selected area of the principal sketch
   * @param: canvas  PGraphics object to draw on
   */
  public void drawVisor(PGraphics canvas) {
    canvas.rectMode(CORNER);
    canvas.noFill();
    canvas.stroke(255, 0, 0); 
    canvas.strokeWeight(3);   
    canvas.rect(SIDE1.x, SIDE1.y, SIDE2.x - SIDE1.x, SIDE2.y - SIDE1.y);
  }


  /**
   * Gets the value of the SIDE1 attribute
   * @returns: PVector  Value of SIDE1
   */
  public PVector getSide1() {
    return SIDE1;
  }


  /**
   * Sets the value of the SIDE1 attribute
   * @param: x  New x value of SIDE1
   * @param: y  New y value of SIDE1
   */
  public void setSide1(int x, int y) {
    SIDE1.x = x;
    SIDE1.y = y;
  }


  /**
   * Reduces the (x, y) coordinates of SIDE1 by 1
   */
  public void reduceSide1() {
    SIDE1.x--;
    SIDE1.y--;
  }


  /**
   * Increases the (x, y) coordinates of SIDE1 by 1
   */
  public void increaseSide1() {
    SIDE1.x++;
    SIDE1.y++;
  }


  /**
   * Gets the value of the SIDE2 attribute
   * @returns: PVector  Value of SIDE2
   */
  public PVector getSide2() {
    return SIDE2;
  }


  /**
   * Sets the value of the SIDE2 attribute
   * @param: x  New x value of SIDE2
   * @param: y  New y value of SIDE2
   */
  public void setSide2(int x, int y) {
    SIDE2.x = x;
    SIDE2.y = y;
  }


  /**
   * Reduces the (x, y) coordinates of SIDE2 by 1
   */
  public void reduceSide2() {
    SIDE2.x--;
    SIDE2.y--;
  }


  /**
   * Increase the (x, y) coordinates of SIDE2 by 1
   */
  public void increaseSide2() {
    SIDE2.x++;
    SIDE2.y++;
  }


  /**
   * Saves the current values of the guiding points to a JSON file 
   */
  private void saveJSON() {
    JSONArray Side1 = new JSONArray();
    Side1.setFloat(0, SIDE1.x);
    Side1.setFloat(1, SIDE1.y);

    JSONArray Side2 = new JSONArray();
    Side2.setFloat(0, SIDE2.x);
    Side2.setFloat(1, SIDE2.y);

    JSONObject points = new JSONObject();
    points.setJSONArray("Side1", Side1);
    points.setJSONArray("Side2", Side2);

    saveJSONObject(points, PATH, "compact");
    println("Calibration parameters saved.");
  }
} 
