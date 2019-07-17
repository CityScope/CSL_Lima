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
 * Block - Class that represents a square with specific coordinates and varying colors
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class Block {
  private int SIZE;
  private PVector COORDS;
  private ArrayList<Color> COLORS = new ArrayList<Color>();
  private Color COLOR;


  /**
   * Creates a Block object with parameters that define itself
   * @param: size          Size of the Block
   * @param: coordinates   Coordinates of the Block
   * @param: colors        Array with all the possible colors it can take
   * @param: colorName     Name of the color the Block should be filled with
   */
  public Block(int size, PVector coordinates, ArrayList<Color> colors, String colorName) {
    SIZE = size;
    COORDS = coordinates;
    COLORS = colors;
    getColorFromName(colorName);
  }


  /**
   * Gets a Color instance from a color name
   * @param: colorName  Name of the Color instance
   */
  private void getColorFromName(String colorName) {
    for (Color c : COLORS) {
      if (c.getColorName().equals(colorName)) {
        COLOR = c;
        break;
      }
    }
  }


  /**
   * Draws an square using the stored coordinates and fills it using the Color object
   */
  public void drawBlock(PGraphics canvas) {
    canvas.stroke(0);
    canvas.fill(COLOR.getColor());
    canvas.rect(COORDS.x, COORDS.y, SIZE, SIZE);
  }


  /**
   * Changes the fill color of the square to the next one in the array of colors
   */
  public void select(int x, int y) {
    if ((x > COORDS.x) && (x < (COORDS.x + SIZE)) && (y > COORDS.y) && (y < (COORDS.y + SIZE))) {
      if (COLOR.getID() == COLORS.size()-1) {
        COLOR = COLORS.get(0);
      } else {
        COLOR = COLORS.get(COLOR.ID+1);
      }
    }
  }


  /**
   * Gets the value of the COORDS attribute
   * @returns: PVector  Value of COORDS
   */
  public PVector getCoords() {
    return COORDS.copy();
  }


  /**
   * Gets the value of the COLOR attribute
   * @returns: Color  Value of COLOR
   */
  public Color getColor() {
    return COLOR;
  }


  /**
   * Gets the value of the SIZE attribute
   * @returns: int  Value of SIZE
   */
  public int getSize() {
    return SIZE;
  }
}


/**
 * BlockGroup - Class that represents a 2x2 arrangement of Block objects
 * @see:       Block
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class BlockGroup {
  private int ID;
  private ArrayList<Block> BLOCKS = new ArrayList<Block>();
  private PVector UR;
  private PVector BL;


  /**
   * Creates a BlockGroup object with parameters that define itself
   * @param: id      ID of the object
   * @param: blocks  Array of blocks composing the object
   */
  public BlockGroup(int id, ArrayList<Block> blocks) {
    ID = id;
    BLOCKS = blocks;
    findCorners();
  }


  /**
   * Sets the upper-right and bottom-left corners of the object
   */
  private void findCorners() {
    float URX = BLOCKS.get(1).getCoords().x + BLOCKS.get(1).getSize();
    float URY = BLOCKS.get(1).getCoords().y;
    UR = new PVector(URX, URY);

    float BLX = BLOCKS.get(2).getCoords().x;
    float BLY = BLOCKS.get(2).getCoords().y + BLOCKS.get(2).getSize();
    BL = new PVector(BLX, BLY);
  }


  /**
   * Draws Block objects in a 2x2 arrangement
   * @param: canvas  PGraphics object to draw on
   */
  public void drawGroup(PGraphics canvas) {
    canvas.stroke(0);
    canvas.fill(0);
    canvas.textSize(10);
    canvas.text("id: " + str(ID), UR.x + 10, UR.y + 10);
    int spaceText = 0;

    for (Block block : BLOCKS) {
      block.drawBlock(canvas);
      canvas.fill(0);
      canvas.textSize(8);
      canvas.text(block.getColor().getColorName() + " ", BL.x + spaceText, BL.y + 10 );
      spaceText += 30;
    }
  }


  /**
   * Calls the select method for every Block in the group
   */
  public void select(int x, int y) {
    for (Block b : BLOCKS) {
      b.select(x, y);
    }
  }


  /**
   * Gets the value of the BLOCKS attribute
   * @returns: ArrayList<Blocks>  Value of BLOCKS
   */
  public ArrayList<Block> getBlocks() {
    return BLOCKS;
  }
}


/**
 * PatternBlocks - Class that creates instances of BlockGroup
 * @see:       BlockGroup
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class PatternBlocks {
  private ArrayList<BlockGroup> GROUPS = new ArrayList<BlockGroup>();
  private ArrayList<JSONArray> OPTIONS = new ArrayList<JSONArray>();
  private ColorRange COLORS;
  private final int BLOCKSIZE;


  /**
   * Creates a PatternBlocks object with parameters that define itself
   * @param: patterns   Patterns object
   * @param: canvas     PGraphics to draw on
   * @param: blockSize  Size of the Block objects
   */
  public PatternBlocks(ArrayList<JSONArray> options, ColorRange colors, int canvasSize, int blockSize) {
    OPTIONS = options;
    COLORS = colors;
    BLOCKSIZE = blockSize;
    createPallet(canvasSize);
  }


  /**
   * Creates Block and BlockGroups objects
   * @param: canvas  PGrapics object where the groups of blocks will be drawn
   */
  private void createPallet(int canvasSize) {
    GROUPS.clear();
    int xStep = 3;
    int sizeT = floor(float(canvasSize)/float(xStep));
    int yStep = ceil(float(OPTIONS.size())/float(xStep));
    PVector initP = new PVector(10, BLOCKSIZE);     
    int index = 0;

    for (int j = 0; j < yStep; j++) {
      for (int i = 0; i < xStep; i++) {
        if (index < OPTIONS.size()) {
          ArrayList<Block> blocks = new ArrayList<Block>();
          JSONArray colorNames = OPTIONS.get(index);

          PVector coordinatesFirstBlock = new PVector(initP.x, initP.y);
          String nameFirstBlock = (String) colorNames.get(0);                    
          Block firstBlock = new Block(BLOCKSIZE, coordinatesFirstBlock, COLORS.selectAll(), nameFirstBlock);          

          PVector coordinatesSecondBlock = new PVector(initP.x + BLOCKSIZE, initP.y);
          String nameSecondBlock = (String) colorNames.get(1); 
          Block secondBlock = new Block(BLOCKSIZE, coordinatesSecondBlock, COLORS.selectAll(), nameSecondBlock);

          PVector coordinatesThirdBlock = new PVector(initP.x + BLOCKSIZE, initP.y + BLOCKSIZE);
          String nameThirdBlock = (String) colorNames.get(2); 
          Block thirdBlock = new Block(BLOCKSIZE, coordinatesThirdBlock, COLORS.selectAll(), nameThirdBlock);

          PVector coordinatesFourthBlock = new PVector(initP.x, initP.y + BLOCKSIZE);
          String nameFourthBlock = (String) colorNames.get(3); 
          Block fourthBlock = new Block(BLOCKSIZE, coordinatesFourthBlock, COLORS.selectAll(), nameFourthBlock); 

          blocks.add(firstBlock);
          blocks.add(secondBlock);
          blocks.add(thirdBlock);
          blocks.add(fourthBlock);

          BlockGroup bg = new BlockGroup(index, blocks);
          GROUPS.add(bg);

          index++;
          initP.x += sizeT;
        }
      }
      initP.x = 10;
      initP.y += BLOCKSIZE * 4;
    }
  }


  /**
   * Update the array of color names so it can be saved on a JSON file
   */
  public void updatePatternOptions() {
    OPTIONS.clear();
    for (BlockGroup bg : GROUPS) {
      JSONArray colorNames = new JSONArray();
      for (Block b : bg.BLOCKS) {
        colorNames.append(b.getColor().getColorName());
      }
      OPTIONS.add(colorNames);
    }
  }


  /**
   * Creates a new pattern and assigns it a default W-W-W-W parameter
   * @param: canvas  PGraphics object to draw the new pattern on
   */
  public void createPattern(PGraphics canvas) {
    JSONArray predetermined = new JSONArray();
    for (int i = 0; i < 4; i++) {
      predetermined.append(COLORS.getWhite().getColorName());
    }
    OPTIONS.add(predetermined);
    createPallet(canvas.width);
    updatePatternOptions();
  }


  /**
   * Deletes the last pattern of the pattern array
   * @param: canvas  PGraphics object from where to remove the pattern
   */
  public void deletePattern(PGraphics canvas) {
    OPTIONS.remove(OPTIONS.size()-1);
    createPallet(canvas.width);
    updatePatternOptions();
  } 


  /**
   * Calls the drawGroup method for all the BlockGroup objects
   * @param: canvas  PGraphics object to draw the groups of blocks
   */
  public void drawGroups(PGraphics canvas) {
    for (BlockGroup bg : GROUPS) {
      bg.drawGroup(canvas);
    }
  }


  /**
   * Calls the select method for every stored BlockGroup object and updates the pattern array
   * @parameter: x  X coordinate of the mouse
   * @parameter: y  Y coordinate of the mouse
   */
  public void select(int x, int y) {
    for (BlockGroup bg : GROUPS) {
      bg.select(x, y);
    }
    updatePatternOptions();
  }


  /**
   * Gets the value of the GROUPS attribute
   * @returns: ArrayList<BlockGroup>  Value of GROUPS
   */
  public ArrayList<BlockGroup> getGroups() {
    return GROUPS;
  }


  /**
   * Gets the value of the COLORS attribute
   * @returns: ColorRange  Value of COLORS
   */
  public ColorRange getColors() {
    return COLORS;
  }


  /**
   * Saves the values of the OPTIONS attribute
   * @returns: JSONObject  A JSONObject with the saved values of OPTIONS
   */
  public JSONObject saveConfiguration() {
    JSONObject patterns = new JSONObject();
    for (int i = 0; i < OPTIONS.size(); i++) {
      patterns.setJSONArray(str(i), OPTIONS.get(i));
    }

    return patterns;
  }
}


/**
 * Patterns - Extends PApplet. Shows color patterns along with their id's. The color patterns can be changed and groups
 * of patterns can be added or removed
 * @see:       PatternBlocks
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class Patterns extends PApplet {
  private PGraphics CANVAS;
  private int WIDTH;
  private int HEIGHT;
  private ArrayList<JSONArray> OPTIONS = new ArrayList<JSONArray>();
  private PatternBlocks PBLOCKS;
  private ColorRange COLORS;
  private final int BLOCKSIZE = 20;


  /**
   * Creates a Patterns object with values retrieved from a JSONObject and a ColorRange object
   * @param: calibrationParameters  JSONObject with pattern data
   * @param: colors                 ColorRange object with data of all the colors
   */
  public Patterns(JSONObject calibrationParameters, ColorRange colors) {
    load(calibrationParameters, colors);
  }


  /**
   * Retrieves preoviously defined patterns from a JSONObject, the size of the PApplet, the size of
   * the PGraphics object and sets the ColorRange object
   * @param: calibrationParameters  JSONObject with pattern data
   * @param: colors                 ColorRange object with data of all the colors
   */
  private void load(JSONObject calibrationParameters, ColorRange colors) {
    JSONObject patterns = calibrationParameters.getJSONObject("Patterns");
    for (int i = 0; i < patterns.size(); i++) {
      JSONArray pattern = patterns.getJSONArray(str(i));
      OPTIONS.add(pattern);
    }

    WIDTH = calibrationParameters.getInt("Canvas size");
    HEIGHT = BLOCKSIZE * 4 * ceil(float(OPTIONS.size())/3);
    COLORS = colors;
    PBLOCKS = new PatternBlocks(OPTIONS, COLORS, WIDTH, BLOCKSIZE);
  }


  /**
   * Gets the factorial of a number
   * @param:   num  The number to get the factorial from
   * @returns: int holding the factorial of num
   */
  private final int fact(int num) {
    return num == 1? 1 : fact(num - 1) * num;
  }


  /**
   * Checks if there is any other possible combination to create a new pattern
   * @returns: true - there more possible combinations / false - there are no more possible combinations
   */
  private boolean getPossiblePatterns() {
    int total = fact(6)/(fact(4) * fact(2));
    return (OPTIONS.size() < total);
  }


  /**
   * Sets the size of the PApplet. P3D enables the use of vertices
   */
  public void settings() {
    size(WIDTH, HEIGHT, P2D);
  }

  /**
   * Sets colorMode to HSB and calls the updatePatternOptions of PBLOCKS
   */
  public void setup() {
    CANVAS = createGraphics(WIDTH, HEIGHT);
    colorMode(HSB, 360, 100, 100);
    PBLOCKS.updatePatternOptions();
  }


  /**
   * Shows the PGraphics object with the patterns
   */
  public void draw() {
    CANVAS.beginDraw();
    CANVAS.background(255);
    PBLOCKS.drawGroups(CANVAS);
    CANVAS.endDraw();
    image(CANVAS, 0, 0);
  }

  /**
   * Calls the select method of PatternBlocks
   */
  public void mouseClicked() {
    PBLOCKS.select(mouseX, mouseY);
  }


  /**
   * Performs certain actions when a key is pressed
   * @param: e      KeyEvent
   * @case: UP      Increases the amount of possible patterns
   * @case: DOWN    Reduces the amount of possible patterns
   * @case: 's'     Hides the PApplet
   */
  public void keyPressed(KeyEvent e) {
    switch(e.getKeyCode()) {
    case UP:     
      if (getPossiblePatterns()) {
        if ((OPTIONS.size() % 3 == 0) ) {
          HEIGHT += BLOCKSIZE * 4;
          surface.setSize(WIDTH, HEIGHT); 
          CANVAS.setSize(width, height);
        }
        PBLOCKS.createPattern(CANVAS);
      }
      break;

    case DOWN:
      if (OPTIONS.size() > 1) {
        if (((OPTIONS.size() - 1) % 3 == 0)) {
          HEIGHT -= BLOCKSIZE * 4;
          surface.setSize(WIDTH, HEIGHT);
          CANVAS.setSize(width, height);
        }
        PBLOCKS.deletePattern(CANVAS);
      }
      break;
    }

    switch(key) {
    case 's':
      this.getSurface().setVisible(false);
      break;
    }
  }


  /**
   * Gets the WIDTH value of the PApplet
   * @returns: int  Value of WIDTH
   */
  public int getSize() {
    return WIDTH;
  }


  /**
   * Gets the value of the BLOCKSIZE attribute
   * @returns: int  Value of BLKOCKSIZE
   */
  public int getBlockSize() {
    return BLOCKSIZE;
  }


  /**
   * Gets the value of the OPTIONS attribute
   * @returns: ArrayList<JSONArray>  Value of OPTIONS
   */
  public ArrayList<JSONArray> getOptions() {
    return OPTIONS;
  }


  /**
   * Gets the value of the PBLOCKS attribute
   * @returns: PatternBlocks  Value of PBLOCKS
   */
  public PatternBlocks getPBlocks() {
    return PBLOCKS;
  }


  /**
   * Shows the PApplet
   */
  public void show() {
    this.getSurface().setVisible(true);
  }


  /**
   * Calls the saveConfiguration method of the PBLOCKS attribute
   * @returns: JSONObject  A JSONObject with the values of PBLOCKS
   */
  public JSONObject saveConfiguration() {
    return PBLOCKS.saveConfiguration();
  }
}
