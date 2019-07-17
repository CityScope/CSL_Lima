/**
 * @copyright: Copyright (C) 2018
 * @legal:
 * This file is part of QRreader.
 
 * QRreader is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * QRreader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with QRreader. If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * Cells - Class which represents a square of a grid
 * @see:       Mesh
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1
 */
public class Cells {
  private int ID;
  private PVector START;
  private PVector CANVAS;
  private int SIZE;
  private String PATTERN = "No pattern" ;


  /**
   * Creates a Cells object with parameters that define itself
   * @param: id            ID of the object
   * @param: startPoint    Upper-left coordinate of the object
   * @param: canvasCoords  Coordinates of the canvas it is placed on
   * @param: size          Size of the object
   */
  public Cells(int id, PVector startPoint, PVector canvasCoords, int size) {
    ID = id;
    START = startPoint;
    CANVAS = canvasCoords;
    SIZE = size;
  }


  /**
   * Checks wether a coordinate is within the bounds of the object
   * @param:   coordinate  The coordinate to check
   * @returns: boolean  True - The coordinate is within the bounds / False - The coordinate is outside the bounds
   */
  public boolean check(PVector coordinate) {
    return ((coordinate.x > START.x) && (coordinate.x < (START.x + SIZE)) && (coordinate.y > START.y) && (coordinate.y < (START.y + SIZE)));
  }


  /**
   * Sets the value of the PATTERN attribute
   * @param: decoded  New value of PATTERN
   */
  public void setPattern(String decoded) {
    PATTERN = decoded;
  }


  /** 
   * Sets the pattern back to its default value
   */
  public void resetPattern() {
    PATTERN = "No pattern";
  }


  /**
   * Draws an square using the stored coordinates and size
   * @param: canvas  PGraphics object to draw on
   */
  public void draw(PGraphics canvas) {
    canvas.stroke(1);
    canvas.noFill();
    canvas.rect(START.x, START.y, SIZE, SIZE);
  }


  public JSONObject saveConfiguration() {
    JSONObject cell = new JSONObject();
    cell.setFloat("x", CANVAS.x);
    cell.setFloat("y", CANVAS.y);
    cell.setString("Pattern", PATTERN);

    return cell;
  }
}


/**
 * Mesh - Class which represents a grid made of Cells objects
 * @see:       Cells
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1
 */
public class Mesh {
  private int NBLOCKS;
  private int CANVASWIDTH;
  private int STEP;
  private int ZOOMSTEP;
  private int ZOOMSIZE;
  private int WIDTH;
  private PVector[][] GRID; 
  private ArrayList<Cells> CELLS = new ArrayList<Cells>();
  private ZXING4P zxing4p = new ZXING4P();


  /**
   * Creates a Mesh object with parameters that define itself
   * @param: nBlocks   Number of blocks in the grid
   * @param: w         Width of the grid
   * @param: zoomSize  Amount of zoom to be applied to the grid
   */
  public Mesh(JSONObject data, int size) {
    NBLOCKS = data.getInt("nblocks");
    CANVASWIDTH = size;
    ZOOMSIZE = data.getInt("zoom");
    zxing4p.version();
    update();
  }


  /**
   * Gets the value of the NBLOCKS attribute
   * @returns: Value of NBLOCKS
   */
  public int getNBlocks() {
    return NBLOCKS;
  }


  /**
   * Gets the value of the CANVASWIDTH attribute
   * @returns: Value of CANVASWIDTH
   */
  public int getWidth() {
    return CANVASWIDTH;
  }


  /**
   * Gets the value of the ZOOMSIZE attribute
   * @returns: Value of ZOOMSIZE
   */
  public int getZoomSize() {
    return ZOOMSIZE;
  }


  /**
   * Adds one block
   */
  public void addBlock() {
    if (STEP > NBLOCKS) {
      NBLOCKS++;
      update();
    }
  }


  /**
   * Deletes one block
   */
  public void deleteBlock() {
    if (NBLOCKS > 1) {
      NBLOCKS--;
      update();
    }
  }


  /**
   * Updates values of the object
   */
  public void update() {
    GRID = new PVector[NBLOCKS + 1][NBLOCKS + 1];
    STEP = floor(CANVASWIDTH/NBLOCKS);
    ZOOMSTEP = floor(CANVASWIDTH * ZOOMSIZE/NBLOCKS);
    WIDTH = NBLOCKS * STEP;  
    CELLS = new ArrayList<Cells>();
    create();
  }


  /**
   * Creates grid and Cells objects
   */
  public void create() {
    int id = 0;

    for (int w = 0; w < GRID.length; w++) {
      for (int h = 0; h < GRID.length; h++) {
        int pointx = w * ZOOMSTEP;
        int pointy = h * ZOOMSTEP;
        GRID[w][h] = new PVector(pointx, pointy);
      }
    }

    for (int i = 0; i < NBLOCKS; i++) {
      for (int y = 0; y < NBLOCKS; y++) {
        PVector startPoint = new PVector(GRID[y][i].x, GRID[y][i].y);         
        CELLS.add(new Cells(id, startPoint, new PVector(y, i), 1));
        id++;
      }
    }
  }


  /**
   * Draws the grid
   * @param: canvas  PGraphics object to draw on
   */
  public void draw(PGraphics canvas) {
    canvas.beginDraw();

    for (int i = 0; i <= NBLOCKS; i++) {
      canvas.line(i * STEP, 0, i * STEP, WIDTH);
    }

    for (int i = 0; i <= NBLOCKS; i++) {
      canvas.line(0, i * STEP, WIDTH, i * STEP);
    }

    canvas.endDraw();
  }


  /**
   * Scans an image looking for QR codes and gets their stored values. Prints the enumerated values of the QR codes to the console.
   * Resets the patterns of the Cells objects. Sets the pattern of the Cells where the QR code was found equal to its decoded pattern
   * @param: img  PImage object to scan in
   */
  public void checkPattern(PImage img) {
    String[] decodedArr = zxing4p.decodeMultipleQRCodes(true, img);
    for (Cells c : CELLS) {
      c.resetPattern();
    }

    for (int i = 0; i < decodedArr.length; i++) {
      println((i + 1) + ". " + decodedArr[i]);

      for (Cells c : CELLS) {
        if (c.check(zxing4p.getPositionMarkers(i)[0])) {
          c.setPattern(decodedArr[i]);
          break;
        }
      }
    }
  }


  /**
   * Creates a JSON file that will store the coordinates of the Cell objects along with their patterns. Calls the saveConfiguration method
   * for each stored Cells object
   */
  public void exportGrid() {
    JSONObject grid = new JSONObject();  
    int i = 0;

    for (Cells c : CELLS) {
      JSONObject cell = c.saveConfiguration();
      grid.setJSONObject(str(i), cell);
      i++;
    }

    saveJSONObject(grid, "data/grid.json", "compact");    
    println("Grid exported.");
  }
}
