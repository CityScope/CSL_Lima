/**
 * @copyright: Copyright (C) 2018
 * @legal:
 * This file is part of LegoReader.
 
 * LegoReader is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * LegoReader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with LegoReader.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * Configuration - Kind of a facade for the displayable classes
 * @see:       BlockReader, ColorRange, Mesh, Patterns, WarpedPerspective
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class Configuration {
  private IntList RESIZE = new IntList();
  private ColorRange COLORS;
  private WarpedPerspective WARP;
  private Patterns PATTERNS;
  private Mesh MESH;
  private BlockReader BLOCKR;

  //UDP
  private int PORT = 9877;
  private String HOST_IP = "localhost"; //IP Address of the PC in which this App is running
  private UDP udp; //Create UDP object for recieving
  private String previousMess = "";


  /**
   * Creates a Configuration object in order to initiate the displayable classes from the parameters passed to it
   * @param: path              Path to JSON file with all the calibration parameters
   * @param: whiteBackground   Image with the modification panel for color white
   * @param: blackBackground   Image with the modification panel for color black
   * @param: otherBackground   Image with the modification panel for the rest of the colors
   */
  public Configuration(String path, PImage whiteBackground, PImage blackBackground, PImage otherBackground) {
    load(path, whiteBackground, blackBackground, otherBackground);
    udp = new UDP(this);  
    udp.log(true);
    udp.listen(true);
  }


  /**
   * Creates instance of ColorRange, WarpedPerspective, Patterns, Mesh and BlockReader
   * @param: path              Path to JSON file with all the calibration parameters
   * @param: whiteBackground   Image with the modification panel for color white
   * @param: blackBackground   Image with the modification panel for color black
   * @param: otherBackground   Image with the modification panel for the rest of the colors
   */
  private void load(String path, PImage whiteBackground, PImage blackBackground, PImage otherBackground) {    
    JSONObject calibrationParameters = loadJSONObject(path);  

    WARP = new WarpedPerspective(calibrationParameters);
    COLORS = new ColorRange(whiteBackground, blackBackground, otherBackground, calibrationParameters);    
    PATTERNS = new Patterns(calibrationParameters, COLORS);
    MESH = new Mesh(calibrationParameters, PATTERNS.getPBlocks());
    BLOCKR = new BlockReader(calibrationParameters, MESH);

    JSONObject resize = calibrationParameters.getJSONObject("resizeCanvas");
    RESIZE.append(resize.getInt("rWa"));
    RESIZE.append(resize.getInt("rHa"));

    println("Calibration parameters loaded.");
  }


  /**
   * Updates the RESIZE attribute
   * @param: w  Value to resize width
   * @param: h  Value to resize height
   */
  public void updateSizeCanvas(int w, int h) {
    int newW = w % MESH.getBlocks();
    int newH = h % MESH.getBlocks();
    RESIZE.append(newW);
    RESIZE.append(newH);
  }


  /**
   * Mirrors the image shown by the camera
   * @param: canvas  PGraphics to show the mirrored image on
   * @param: cam     Capture object whose content will be mirrored
   * @param: flip    true - mirrors the image / false - does not mirror the image
   */
  public void flip(PGraphics canvas, Capture cam, boolean flip) {
    if (flip) {
      canvas.pushMatrix();
      canvas.scale(-1, 1);
      canvas.image(cam, -canvas.width, 0);
      canvas.popMatrix();
    } else {
      canvas.image(cam, 0, 0);
    }
  }


  /**
   * Runs the stored PApplets
   * @param: patterns  Name for the Patterns PApplet
   * @param: colors    Name for the ColorRange PApplet
   * @param: block     Name for the BlockReader PApplet
   */
  public void runSketches(String[] patterns, String[] colors, String[] block) {
    PApplet.runSketch(patterns, PATTERNS);
    PApplet.runSketch(colors, COLORS);
    PApplet.runSketch(block, BLOCKR);
  }


  /**
   * Calls the draw method of WARP
   * @param: canvas  PGraphics object to draw on
   */
  public void drawWarp(PGraphics canvas) {
    WARP.draw(canvas);
  }


  /**
   * Calls the applyPerspective method of WARP
   * @param:   img     PGraphics object to be distorted
   * @returns: PImage  Distorted portion of the PGraphics
   */
  public PImage applyPerspective(PGraphics canvas) {
    return WARP.applyPerspective(canvas);
  }


  /**
   * Calls the applyFilter method of MESH
   * @param: img  PImage object to be affected
   */
  public void applyFilter(PImage img) {
    MESH.applyFilter(img);
  }


  /**
   * Calls the drawGrid method of MESH
   * @param: canvas  PGraphics object to draw on
   */
  public void drawGrid(PGraphics canvas) {
    MESH.drawGrid(canvas);
  }


  /**
   * Calls the increaseSaturation method of MESH
   * @param: inc  Amount of the increase
   */
  public void increaseSaturation(float inc) {
    MESH.increaseSaturation(inc);
  }


  /**
   * Calls the decreaseSaturation method of MESH
   * @param: dec  Amount of the decrease
   */
  public void decreaseSaturation(float dec) {
    MESH.decreaseSaturation(dec);
  }


  /**
   * Calls the increaseBrightness method of MESH
   * @param: inc  Amount of the increase
   */
  public void increaseBrightness(float inc) {
    MESH.increaseBrightness(inc);
  }



  /**
   * Calls the decreaseBrightness method of MESH
   * @param: dec  Amount of the decrease
   */
  public void decreaseBrightness(float dec) {
    MESH.decreaseBrightness(dec);
  }


  /**
   * Calls the getBlocks method of MESH
   * @returns: int  Value of NBLOCKS in MESH
   */
  public int getBlocks() {
    return MESH.getBlocks();
  }


  /**
   * Calls the increaseBlocks method of MESH
   */
  public void increaseBlocks() {
    MESH.increaseBlocks();
  }


  /**
   * Calls the decreaseBlocks method of MESH
   */
  public void decreaseBlocks() {
    MESH.decreaseBlocks();
  }


  /**
   * Calls the select method of WARP
   * @param: x          X coordinate of the mouse
   * @param: y          Y coordinate of the mouse
   * @param: threshold  Distance from the mouse to the control point to change its status
   */
  public void select(int mousex, int mousey, int threshold) {
    WARP.select(mousex, mousey, threshold);
  }


  /**
   * Calls the move method of WARP
   * @param: x  X coordinate of the mouse
   * @param: y  Y coordinate of the mouse
   */
  public void move(int x, int y) {
    WARP.move(x, y);
  }


  /**
   * Calls the unselect method of WARP
   */
  public void unselect() {
    WARP.unselect();
  }


  /**
   * Calls the update method of MESH
   */
  public void update(int w) {
    MESH.update(w, PATTERNS.getPBlocks());
  }


  /**
   * Calls the setShow method of COLORS
   */
  public void toggleBlockReader() {
    BLOCKR.setShow();
  }


  /**
   * Calls the setShow method of COLORS
   */
  public void toggleColorRange() {
    COLORS.setShow();
  }


  /**
   * Calls the setShow method of COLORS
   */
  public void togglePatterns() {
    PATTERNS.setShow();
  }


  public void receive(byte[] data) {
    println("Processing received an unexpected message");
  }


  public void send(String message) {
    if (!message.equals(previousMess)) {
      udp.send(message, HOST_IP, PORT);
      previousMess = message;
    }
  }


  /**
   * Exports color patterns and id's in the mesh
   */
  public void exportGridUDP() {
    String message = "";
    for (int w = 0; w < MESH.getPatterns().size(); w++) {
      message = message + MESH.getPatterns().get(w).getIndex() + ";";
    }
    send(message);
  }


  /**
   * Exports a JSONfile with color patterns and id's in the mesh
   */
  public void exportGrid() {
    JSONObject mesh = new JSONObject();
    JSONObject metadata = new JSONObject();

    metadata.setString("id", "AOpifOF");
    metadata.setFloat("timestamp", millis());
    metadata.setString("apiv", "2.1.0");

    JSONObject header = new JSONObject();
    header.setString("name", "cityscope_lima");

    JSONObject spatial = new JSONObject();
    spatial.setInt("nrows", MESH.getBlocks());
    spatial.setInt("ncols", MESH.getBlocks());
    spatial.setFloat("physical_longitude", -77);
    spatial.setFloat("physical_latitude", 12);
    spatial.setInt("longitude", -77);
    spatial.setInt("latitude", 12);
    spatial.setInt("cellSize", PATTERNS.getBlockSize());
    spatial.setInt("rotation", 0);

    header.setJSONObject("spatial", spatial);

    JSONObject owner = new JSONObject();
    owner.setString("name", "Vanesa and Jesús");
    owner.setString("title", "Researcher");
    owner.setString("institute", "Pacific´s University");
    
    header.setJSONObject("owner", owner);

    JSONArray block = new JSONArray();
    block.setString(1, "type");
    block.setString(0, "rotation");

    header.setJSONArray("block", block);

    JSONObject type = new JSONObject();
    JSONObject mapping = new JSONObject();

    int j = 0;
    for (int i = 0; i < PATTERNS.getOptions().size(); i++) {
      type.setFloat(str(i), j);
      j++;
    }
    mapping.setJSONObject("type", type);

    header.setJSONObject("mapping", mapping);

    JSONArray grid = new JSONArray();
    for (int w = 0; w < MESH.getPatterns().size(); w++) {
      JSONArray arr = new JSONArray();
      arr.append(MESH.getPatterns().get(w).getIndex());
      arr.append(0);
      arr.append(0);
      grid.append(arr);      
    }
    
    header.setJSONArray("grid", grid);

    mesh.setJSONObject("meta", metadata);
    mesh.setJSONObject("header", header);

    saveJSONObject(mesh, "data/grid.json");
  }


  /**
   * Saves custom calibration parameters in a JSON file
   */
  public void saveConfiguration() { 
    JSONObject calibrationParameters = new JSONObject();

    JSONObject calibrationPoints = WARP.saveConfiguration();
    calibrationParameters.setJSONObject("Calibration Points", calibrationPoints);

    float brightness = MESH.getBrightness();
    calibrationParameters.setFloat("Brightness", brightness);

    JSONObject resize = new JSONObject();    
    for (int i=0; i < RESIZE.size(); i++) {
      resize.setInt("rWa", RESIZE.get(0));
      resize.setInt("rHa", RESIZE.get(1));
    }
    calibrationParameters.setJSONObject("resizeCanvas", resize);

    float saturation = MESH.getSaturation();
    calibrationParameters.setFloat("Saturation", saturation);

    int canvasSize = PATTERNS.getSize();
    calibrationParameters.setInt("Canvas size", canvasSize);

    int nBlocks = MESH.getBlocks();
    calibrationParameters.setInt("nblocks", nBlocks);

    JSONObject size = COLORS.getSize();
    calibrationParameters.setJSONObject("Color Range", size);

    JSONArray colorLimits = COLORS.saveConfiguration();
    calibrationParameters.setJSONArray("Color Limits", colorLimits);

    JSONObject patterns = PATTERNS.saveConfiguration();           
    calibrationParameters.setJSONObject("Patterns", patterns);

    saveJSONObject(calibrationParameters, "data/calibrationParameters.json", "compact");
    println("Calibration parameters saved.");
  }
}
