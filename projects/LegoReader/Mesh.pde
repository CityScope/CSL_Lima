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
 * Cells - Class which represents one square of a grid
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class Cells {
  private int ID;
  private PVector START;
  private int SIZE;
  private ArrayList<Color> COLORS = new ArrayList<Color>();
  private White W;
  private Black BL;
  private ArrayList<Other> OT = new ArrayList<Other>();
  private final int THRESH = 30; 
  private int[] COUNTER;
  private IntList INDEXES = new IntList();  
  private Color COLOR;


  /**
   * Create a Cells object with parameters that define itself
   * @param: id          ID of the object
   * @param: startPoint  Upper left coordinate of the object
   * @param: colors      Array with all the possible colors it can take
   */
  public Cells(int id, PVector startPoint, int size, ArrayList<Color> colors) {
    ID = id;
    START = startPoint;
    SIZE = size;
    COLORS = colors;
    setCounter();
    setColors();
  }


  /**
   * Sets the counter for every possible color of the object to 0
   */
  private void setCounter() {
    COUNTER = new int[COLORS.size()];
    for (int i = 0; i < COUNTER.length; i++) {
      COUNTER[i] = 0;
    }
  }


  /**
   * Instantiates the colors from the array separately to simplify color manipulation
   */
  private void setColors() {
    for (Color c : COLORS) {
      if (c instanceof White) {
        W = (White) c;
      } else if (c instanceof Black) {
        BL = (Black) c;
      } else {
        Other o = (Other) c;
        OT.add(o);
      }
    }
    COLOR = W;
  }


  /**
   * Asigns a standard color to every group of an image's pixels in the same color range
   * @param: img      PImage object to be affected
   * @param: sat      Saturation value
   * @param: bright   Brightness value
   */
  public void applyFilter(PImage img, float sat, float bright) {
    W.resetCounter();
    BL.resetCounter();    
    for (Other o : OT) {
      o.resetCounter();
    }

    for (int y = int(START.y); y < int(START.y + SIZE); y++) {
      for (int x = int(START.x); x < int(START.x + SIZE); x++) {
        int i = y * img.width + x;
        color actual = img.pixels[i];     

        float hue = hue(actual);
        float saturation = saturation(actual);
        float brightness = brightness(actual);

        saturation += sat;
        brightness += bright;

        Color standard = W;

        boolean breakLoop = false;

        if (((saturation < W.MAXSAT) & (brightness > W.MINBRI)) | ((saturation < W.MAXSAT2) & (hue < W.MAXHUE) & (hue > W.MINHUE))) {
          standard = W;
          breakLoop = true;
        }
        if (!breakLoop) {
          if (brightness < BL.MAXBRI | ((brightness < BL.MAXBRI2 ) & (saturation  < BL.MAXSAT))) {  
            standard = BL;
            breakLoop = true;
          }
        }
        if (!breakLoop) {
          for (Color o : OT) {
            if ((hue < o.MAXHUE)) {
              standard = o;
              breakLoop = true;
              break;
            }
          }
        }
        if (!breakLoop) standard = OT.get(0);
        standard.setCounter();
        img.pixels[i] = standard.getColor();
      }
    }

    int max = 0;
    Color maxColor = W;
    for (Color c : COLORS) {
      if (c.getCounter() > max) {
        max = c.getCounter();
        maxColor = c;
      }
    }

    COUNTER[maxColor.ID]++;
    INDEXES.append(maxColor.getID());
    if (INDEXES.size() >= THRESH) {
      COUNTER[INDEXES.get(0)]--;
      INDEXES.remove(0);
    }  

    int maxAverage = max(COUNTER);
    for (int i = 0; i < COUNTER.length; i++) {
      if (COUNTER[i] == maxAverage) {
        COLOR = COLORS.get(i);
        break;
      }
    }
  }


  /**
   * Draws the cell with the standard color
   * @param: canvas  PGraphics object to draw on
   */
  public void draw(PGraphics canvas) {
    canvas.fill(COLOR.getColor());
    canvas.stroke(0, 60);
    canvas.strokeWeight(1);
    canvas.rect(START.x, START.y, SIZE, SIZE);
  }


  /**
   * Gets the value of the COLOR attribute
   * @returns: Color  Value of COLOR
   */
  public Color getColor() {
    return COLOR;
  }
}


/**
 * PatternCells - Class which represents a 2x2 arrangement of Cells objects. Its ID depends on the color of the Cell objects surrounding it.
 * Creates Cells objects
 * @see:       Cells
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class PatternCells {
  private int ID;
  private PVector START;
  private int SIZE;
  private int INDEX = -1;
  private boolean CHECK;
  private PatternBlocks PBLOCKS;
  private ArrayList<Cells> CELLS = new ArrayList<Cells>();


  /**
   * Create a PatternCells object with parameters that define itself
   * @param: id          ID of the object
   * @param: startPoint  Upper left coordinate of the object
   * @param: pBlocks     PatternBlocks object with data of color ranges and patterns
   */
  public PatternCells(int id, PVector startPoint, int size, PatternBlocks pBlocks) {
    ID = id;
    START = startPoint;
    SIZE = (int) size;
    PBLOCKS = pBlocks;
    create(PBLOCKS.getColors().selectAll());
  }


  /**
   * Creates a group of Cells for the object
   * @param: colors  Array of possible colors the Cells objects can take
   */
  private void create(ArrayList<Color> colors) {
    CELLS.add(new Cells(0, START, SIZE/2, colors));
    CELLS.add(new Cells(1, new PVector(START.x + SIZE/2, START.y), SIZE/2, colors));
    CELLS.add(new Cells(2, new PVector(START.x, START.y + SIZE/2), SIZE/2, colors));
    CELLS.add(new Cells(3, new PVector(START.x + SIZE/2, START.y + SIZE/2), SIZE/2, colors));
  }


  /**
   * Calls the applyFilter method for each stored Cell
   * @param: img      PImage object to be affected
   * @param: sat      Saturation value
   * @param: bright   Brightness value
   */
  public void applyFilter(PImage img, float saturation, float brightness) {
    for (Cells c : CELLS) {
      c.applyFilter(img, saturation, brightness);
    }
  }


  /**
   * Calls the draw method for each stored Cell and shows a rectangle with its ID in the middle of the drawn Cells
   * @param: canvas  PGraphics object to draw on
   */
  public void draw(PGraphics canvas) {
    for (Cells c : CELLS) {
      c.draw(canvas);
    }

    canvas.noFill();
    canvas.strokeWeight(2);
    canvas.rect(START.x, START.y, SIZE, SIZE);
    canvas.textAlign(CENTER, CENTER);
    canvas.rectMode(CENTER); 

    if (INDEX != -1) canvas.fill(255);
    else canvas.fill(215);

    canvas.rect(START.x + SIZE/2, START.y + SIZE/2, SIZE/2, SIZE/2);
    canvas.fill(0);
    canvas.text(str(INDEX), START.x + SIZE/2, START.y + SIZE/2);  
    canvas.rectMode(CORNER);
  }


  /**
   * Draws squares that will form a grid
   * @param: canvas  PGraphics object to draw on
   */
  public void drawGrid(PGraphics canvas) {
    canvas.noFill();
    canvas.strokeWeight(2);
    canvas.rect(START.x, START.y, SIZE, SIZE);
  }


  /**
   * Checks if the color pattern of its cells - or a rotated version of it - can be found in the defined patterns of the Patterns class
   * Assigns an ID equal to the corresponding pattern's ID in the Patterns class
   */
  public void checkPattern() {
    CHECK = false;

    int index = 0;

    boolean correct1 = false;
    boolean correct2 = false;
    boolean correct3 = false;
    boolean correct4 = false;

    for (int i = 0; i < PBLOCKS.getGroups().size(); i++) {
      BlockGroup bg = PBLOCKS.getGroups().get(i);

      ArrayList<Color> blockColors = new ArrayList<Color>();
      ArrayList<Color> cellColors = new ArrayList<Color>();

      if (bg.getBlocks().size() == 4) {
        for (int j = 0; j < bg.getBlocks().size(); j++) {
          blockColors.add(bg.getBlocks().get(j).getColor());
          cellColors.add(CELLS.get(j).getColor());
        }

        correct1 = (blockColors.equals(cellColors));

        Collections.rotate(blockColors, 1);
        correct2 = (blockColors.equals(cellColors));

        Collections.rotate(blockColors, -1);
        Collections.rotate(blockColors, 2);
        correct3 = (blockColors.equals(cellColors));

        Collections.rotate(blockColors, -2);
        Collections.rotate(blockColors, 3);
        correct4 = (blockColors.equals(cellColors));
      }    

      if (correct1 || correct2 || correct3 || correct4) {
        INDEX = index; 
        CHECK = true; 
        break;
      }
      index++;
    }
    if (!CHECK) {
      INDEX = -1;
    }
  }


  /**
   * Gets the value of the INDEX attribute
   * @returns: int  Value of INDEX
   */
  public int getIndex() {
    return INDEX;
  }
}


/**
 * Mesh - Class which creates PatternCells objects. Represents a grid made of PatternCells
 * @see:       PatternCells
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class Mesh {
  private int NBLOCKS;
  private int SIZE;
  private float SATURATION;
  private float BRIGHTNESS;
  private PVector[][] GRID;
  private ArrayList<PatternCells> PCELLS = new ArrayList<PatternCells>();


  /**
   * Creates a Mesh object using parameters from a JSONObject and with an instance of PatternBlocks
   * @param: calibrationParameters  JSONObject with data to create the object
   * @param: pBlocks                PatternBlocks object to be used when creating instances of PatternCells
   */
  public Mesh(JSONObject calibrationParameters, PatternBlocks pBlocks) {
    load(calibrationParameters, pBlocks);
  }


  /**
   * Retrieves values from a JSONObject and passes the PatternBlocks instance to the create method
   * @param: calibrationParameters  JSONObject with data to be retrieved
   * @param: pBlocks                PatternBlocks object to be used when creating instances of PatternCells
   */
  private void load(JSONObject calibrationParameters, PatternBlocks pBlocks) {
    SATURATION = calibrationParameters.getFloat("Saturation");
    BRIGHTNESS = calibrationParameters.getFloat("Brightness");
    NBLOCKS = calibrationParameters.getInt("nblocks");
    SIZE = calibrationParameters.getInt("Canvas size")/NBLOCKS;
    GRID = new PVector[NBLOCKS][NBLOCKS];
    create(pBlocks);
  }


  /**
   * Creates a grid of nxn PatternCells
   * @param: pBlocks  PatternBlocks object to be used when creating instances of PatternCells
   */
  private void create(PatternBlocks pBlocks) {
    ArrayList<PatternCells> tempCells = new ArrayList<PatternCells>();
    int id = 0;
    for (int h = 0; h < GRID.length; h++) {
      for (int w = 0; w < GRID.length; w++) {
        float pointx = w * SIZE;
        float pointy = h * SIZE;
        tempCells.add(new PatternCells(id, new PVector(pointx, pointy), SIZE, pBlocks));
        id++;
      }
    }
    PCELLS = tempCells;
  }


  /**
   * Calls the draw method for each stored PatternCells object
   * @param: canvas  PGraphics object to draw on
   */
  public void draw(PGraphics canvas) {
    for (PatternCells pc : PCELLS) {
      pc.draw(canvas);
    }
  }


  /**
   * Calls the drawGrid method for each stored PatternCells object
   * @param: canvas  PGraphics object to draw on
   */
  public void drawGrid(PGraphics canvas) {
    for (PatternCells pc : PCELLS) {
      pc.drawGrid(canvas);
    }
  }


  /**
   * Overwrites the original configuration
   * @param: nBlocks  Number of squares in the grid
   * @param: w        Width of the PGraphics to draw on
   * @param: pBlocks  PatternBlocks object to be used when creating instances of PatternCells 
   */
  public void update(int w, PatternBlocks pBlocks) {
    SIZE = w/NBLOCKS;
    GRID = new PVector[NBLOCKS][NBLOCKS];
    create(pBlocks);
  } 


  /**
   * Calls the applyFilter method for each stored PatternCells object
   * @param: img  PImage object to be affected
   */
  public void applyFilter(PImage img) {
    img.loadPixels();
    for (PatternCells pc : PCELLS) {
      pc.applyFilter(img, SATURATION, BRIGHTNESS);
    }
    img.updatePixels();
  }

  /**
   * Calls the checkPattern method for each stored PatternCells object
   */
  public void checkPattern() {
    for (PatternCells pc : PCELLS) {
      pc.checkPattern();
    }
  }


  /**
   * Gets the value of the NBLOCKS attribute
   * @returns: int  Value of NBLOCKS
   */
  public int getBlocks() {
    return NBLOCKS;
  }


  /**
   * Increases the value of NBLOCKS attribute by 1
   */
  public void increaseBlocks() {
    NBLOCKS++;
  }


  /**
   * Decreases the value of NBLOCKS attribute by 1
   */
  public void decreaseBlocks() {
    if (NBLOCKS > 1) NBLOCKS--;
  }


  /**
   * Gets the value of the SATURATION attribute
   * @returns: float  Value of SATURATION
   */
  public float getSaturation() {
    return SATURATION;
  }


  /**
   * Increases the value of SATURATION
   * @param: inc  Amount of the increase
   */
  public void increaseSaturation(float inc) {
    SATURATION += inc;
  }


  /**
   * Decreases the value of SATURATION
   * @param: dec  Amount of the decrease
   */
  public void decreaseSaturation(float dec) {
    SATURATION -= dec;
  }


  /**
   * Gets the value of the BRIGHTNESS attribute
   * @returns: float  Value of BRIGHTNESS
   */
  public float getBrightness() {
    return BRIGHTNESS;
  }


  /**
   * Increases the value of BRIGHTNESS
   * @param: inc  Amount of the increase
   */
  public void increaseBrightness(float inc) {
    BRIGHTNESS += inc;
  }


  /**
   * Decreases the value of BRIGHTNESS
   * @param: dec  Amount of the decrease
   */
  public void decreaseBrightness(float dec) {
    BRIGHTNESS -= dec;
  }


  /**
   * Gets the value of the PCELLS attribute
   * @returns: ArrayList<PatternCells>  Value of PCELLS
   */
  public ArrayList<PatternCells> getPatterns() {
    return PCELLS;
  }
}   
