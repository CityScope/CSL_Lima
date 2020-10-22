/**
** @copyright: Copyright (C) 2018
** @authors:   Javier Zárate & Vanesa Alcántara
** @version:   1.0
** @legal:
    This file is part of LegoReader.
    LegoReader is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    LegoReader is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.
    
    You should have received a copy of the GNU Affero General Public License
    along with LegoReader.  If not, see <http://www.gnu.org/licenses/>.
**/

public class Patterns extends PApplet {
  int w;
  int h;
  PGraphics canvasPattern;
  final int blockSize = 20;
  Configuration config;

  public Patterns(PGraphics canvasPattern, Configuration config, int blockSize) {
    this.w = 480;
    this.h = blockSize * 4 * config.patterns.size()/3;
    this.canvasPattern = canvasPattern;
    this.config = config;
    patternBlocks = new PatternBlocks(this.canvasPattern, this.config, blockSize);
  }

  public void settings() {
    size(this.w, this.h);
  }

  public void setup() {
    colorMode(HSB, 360, 100, 100);
    patternBlocks.getColorString();
  }

  public void draw() {
    background(255);
    canvasPattern.beginDraw();
    canvasPattern.background(255);
    patternBlocks.draw(canvasPattern);
    canvasPattern.endDraw();
    image(canvasPattern, 0, 0);
  }

<<<<<<< HEAD:projects/LegoReader/PatternView.pde
  public void mouseClicked() {
    patternBlocks.selected(mouseX, mouseY);
=======
  /**
   * Draws an square using the stored coordinates and fills it using the Color object
   */
  public void drawBlock(PGraphics canvas) {
    canvas.stroke(0);
    canvas.fill(COLOR.getColor());
    canvas.rect(COORDS.x, COORDS.y, SIZE, SIZE);
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/PatternView.pde
  }

  public void keyPressed(KeyEvent e) {
    switch(e.getKeyCode()) {
    /**
     *Increment the amount of possible patterns
    **/
    case UP:     
      if (config.possiblePatterns()) {
        if ((config.patterns.size() % 3 == 0) ) {
          this.h += blockSize * 4;
          surface.setSize(this.w, this.h); 
          canvasPattern.setSize(width, height);
        }
        patternBlocks.createPattern(canvasPattern);
      }
      break;

<<<<<<< HEAD:projects/LegoReader/PatternView.pde
    case DOWN:
    /**
     *Reduce the amount of possible patterns
    **/
      if (config.patterns.size() > 1) {
        if (((config.patterns.size()-1) % 3 == 0)) {
          this.h -= blockSize * 4;
          surface.setSize(this.w, this.h );
          canvasPattern.setSize(width, height);
        }
        patternBlocks.deletePattern(canvasPattern);
=======
  /**
   * Changes the fill color of the square to the next one in the array of colors
   */
  public void select(int x, int y) {
    if ((x > COORDS.x) && (x < (COORDS.x + SIZE)) && (y > COORDS.y) && (y < (COORDS.y + SIZE))) {
      if (COLOR.getID() == COLORS.size()-1) {
        COLOR = COLORS.get(0);
      } else {
        COLOR = COLORS.get(COLOR.ID+1);
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/PatternView.pde
      }
      break;
    }
  }
}

public class Block {
  ArrayList<PVector> corners = new ArrayList<PVector>();
  Color col;
  int id;
  int colorIndex = 0;
  public Block(int id, ArrayList<PVector> corners, String colorName) {
    this.id = id;
    this.corners = corners;
    this.getColorFromName(colorName);
  }

  void getColorFromName(String colorName) {
    for (Color col : config.colorLimits) {
      if (col.name.equals(colorName)) {
        this.col = col;
        this.colorIndex = col.id;
        break;
      }
    }
  }

  void draw(PGraphics canvas) {
    canvas.stroke(0);
    canvas.fill(col.stdColor);
    canvas.beginShape();
    canvas.vertex(this.corners.get(0).x, this.corners.get(0).y);
    canvas.vertex(this.corners.get(1).x, this.corners.get(1).y);
    canvas.vertex(this.corners.get(2).x, this.corners.get(2).y);
    canvas.vertex(this.corners.get(3).x, this.corners.get(3).y);
    canvas.endShape(CLOSE);
  }

  /**
   *Change the color to the following in the colorLimits list
  **/  
  void selected(int x, int y) {
    PVector ul = corners.get(0);
    PVector ur = corners.get(1);
    PVector br = corners.get(2);
    PVector bl = corners.get(3);
    if ((x > ul.x) && (x < ur.x) && (y > ul.y) && (y < bl.y) ) {
      if (colorIndex == config.colorLimits.size() - 1) {
        colorIndex = 0;
      } else {
        this.colorIndex += 1;
      }
      this.col = config.colorLimits.get(colorIndex);
      patternBlocks.getColorString();
    }
  }
}

public class BlockGroup {
  ArrayList<Block> blocks = new ArrayList<Block>();
  int id;
  int size;
  PVector cornerUR;
  PVector cornerBL;
  
  public BlockGroup(int id, ArrayList<Block> blocks) {
    this.blocks = blocks;
    this.id = id;
    cornerUR = blocks.get(1).corners.get(1);
    cornerBL = blocks.get(2).corners.get(3);
  }

<<<<<<< HEAD:projects/LegoReader/PatternView.pde
  void draw(PGraphics canvas) {
=======

  /**
   * Draws Block objects in a 2x2 arrangement
   * @param: canvas  PGraphics object to draw on
   */
  public void drawGroup(PGraphics canvas) {
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/PatternView.pde
    canvas.stroke(0);
    canvas.fill(0);
    canvas.textSize(10);
    canvas.text("id: " + str(id), this.cornerUR.x + 10, cornerUR.y + 10);
    int spaceText = 0;
<<<<<<< HEAD:projects/LegoReader/PatternView.pde
    ;
    for (Block block : blocks) {
      block.draw(canvas);
=======

    for (Block block : BLOCKS) {
      block.drawBlock(canvas);
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/PatternView.pde
      canvas.fill(0);
      canvas.textSize(8);
      canvas.text(block.col.name + " ", this.cornerBL.x + spaceText, cornerBL.y + 10 );
      spaceText += 30;
    }
  }

  /**
<<<<<<< HEAD:projects/LegoReader/PatternView.pde
   *Change the color of the selected block to the following in the main list
  **/  
  public void selected(int x, int y) {
    for (Block b : this.blocks) {
      b.selected(x, y);
=======
   * Calls the select method for every Block in the group
   */
  public void select(int x, int y) {
    for (Block b : BLOCKS) {
      b.select(x, y);
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/PatternView.pde
    }
  }
}

public class PatternBlocks {
<<<<<<< HEAD:projects/LegoReader/PatternView.pde
  ArrayList<BlockGroup> groups = new ArrayList<BlockGroup>();
  ArrayList<ArrayList<String>> patternString = new ArrayList<ArrayList<String>>();
  ArrayList<ArrayList<String>> patternConf = new ArrayList<ArrayList<String>>();
  PGraphics canvas;
  final int sizeBlock;
  Configuration config;

  public PatternBlocks(PGraphics canvas, Configuration config, int sizeBlock) {
    this.canvas = canvas;
    this.config = config;
    this.sizeBlock = sizeBlock;
    this.createPallet(canvas);
  }

  /**
   *Upload the pattern array so it can be saved on the JSON file
  **/  
  public void getColorString() {
    this.patternString = new ArrayList<ArrayList<String>>();
    for (BlockGroup blockGroup : groups) {
      ArrayList<String> patternLatent = new ArrayList<String>();
      for (Block block : blockGroup.blocks) {
        patternLatent.add(block.col.name);
      }
      this.patternString.add(patternLatent);
=======
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
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/PatternView.pde
    }
  }

    /**
     *Creates a new pattern and assign it an standar W-W-W-W parameter
    **/
    public void createPattern(PGraphics canvas){
      ArrayList<String> pred = new ArrayList();
      pred.add(this.config.colorLimits.get(0).name);
      pred.add(this.config.colorLimits.get(0).name);
      pred.add(this.config.colorLimits.get(0).name);
      pred.add(this.config.colorLimits.get(0).name);
      this.config.patterns.add(pred);
      this.createPallet(canvas);
      getColorString();
    }   

    /**
     *Delete the last parameter in the parameters list
    **/    
    public void deletePattern(PGraphics canvas){
      this.config.patterns.remove(patternString.size()-1);
      this.createPallet(canvas);
      getColorString();
    } 

  void draw(PGraphics canvas) {
    for (BlockGroup blockGroup : groups) {
      blockGroup.draw(canvas);
    }
  }

  /**
   *Change the color of the selected block inside an specific parameter
  **/ 
  public void selected(int x, int y) {
    for (BlockGroup b : this.groups) {
      b.selected(x, y);
    }
<<<<<<< HEAD:projects/LegoReader/PatternView.pde
    this.config.patterns = this.patternString;
    mesh.updateString();
=======

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
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/PatternView.pde
  }


  /**
<<<<<<< HEAD:projects/LegoReader/PatternView.pde
   *Creates blocks and patterns
  **/ 
  public void createPallet(PGraphics canvas) {
    this.groups.clear();
    this.patternConf = this.config.patterns;
    int xStep = 3;
    int sizeT = floor(float(canvas.width)/float(xStep));
    int yStep = ceil(float(patternConf.size())/float(xStep));
    PVector initP = new PVector(10, sizeBlock);     
    int index= 0;

    for (int j = 0; j < yStep; j++) {
      for (int i = 0; i < xStep; i ++) {
        if (index < patternConf.size()) {
          ArrayList<String> colorNames = config.patterns.get(index);           
          ArrayList<Block> bloques = new ArrayList<Block>();
          ArrayList<PVector> corners = new ArrayList<PVector>();
          corners.add(new PVector(initP.x, initP.y));
          corners.add(new PVector(initP.x + sizeBlock, initP.y));
          corners.add(new PVector(initP.x + sizeBlock, initP.y + sizeBlock));
          corners.add(new PVector(initP.x, initP.y + sizeBlock));
          Block latent1 = new Block(1, corners, colorNames.get(0));

          ArrayList<PVector> corners2 = new ArrayList<PVector>();
          corners2.add(new PVector(initP.x + sizeBlock, initP.y));
          corners2.add(new PVector(initP.x + sizeBlock * 2, initP.y));
          corners2.add(new PVector(initP.x + sizeBlock * 2, initP.y + sizeBlock));
          corners2.add(new PVector(initP.x + sizeBlock, initP.y + sizeBlock));
          Block latent2 = new Block(1, corners2, colorNames.get(1));

          ArrayList<PVector> corners3 = new ArrayList<PVector>();
          corners3.add(new PVector(initP.x, initP.y + sizeBlock));
          corners3.add(new PVector(initP.x + sizeBlock, initP.y + sizeBlock));
          corners3.add(new PVector(initP.x + sizeBlock, initP.y + sizeBlock * 2));
          corners3.add(new PVector(initP.x, initP.y + sizeBlock * 2));
          Block latent3 = new Block(1, corners3, colorNames.get(2));

          ArrayList<PVector> corners4 = new ArrayList<PVector>();
          corners4.add(new PVector(initP.x + sizeBlock, initP.y + sizeBlock));
          corners4.add(new PVector(initP.x + sizeBlock*2, initP.y + sizeBlock));
          corners4.add(new PVector(initP.x + sizeBlock*2, initP.y + sizeBlock * 2));
          corners4.add(new PVector(initP.x + sizeBlock, initP.y + sizeBlock * 2));
          Block latent4 = new Block(1, corners4, colorNames.get(3));
          bloques.add(latent1);
          bloques.add(latent2);
          bloques.add(latent3);
          bloques.add(latent4);
          BlockGroup b = new BlockGroup(index, bloques);
          this.groups.add(b);
          index ++;
          initP.x += sizeT;
=======
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
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/PatternView.pde
        }
      }
      initP.x = 10;
      initP.y += sizeBlock * 4;
    }

    switch(key) {
    case 's':
      this.getSurface().setVisible(false);
      break;
    }
  }
<<<<<<< HEAD:projects/LegoReader/PatternView.pde
=======


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
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/PatternView.pde
}
