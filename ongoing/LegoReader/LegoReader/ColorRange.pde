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
 * ColorRange - Extendeds PApplet. Allows to change calibrations regarding hue, saturation and brightness for the colors
 * @see:       Color, White, Black, Other
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public class ColorRange extends PApplet {
  private PGraphics LEGEND;
  private PImage WHITEBG;
  private PImage BLACKBG;
  private PImage OTHERBG;
  private int WIDTH;
  private int HEIGHT;
  private White W;
  private Black BL;
  private ArrayList<Other> OT = new ArrayList<Other>();  
  private int CONTROLLER = 5;
  private boolean WMODE = true;
  private boolean BMODE = false;
  private boolean OMODE = true;


  /**
   * Creates a ColorRange object from a group of files and a JSONObject
   * @param: whiteBackground   Image with the modification panel for color white
   * @param: blackBackground   Image with the modification panel for color black
   * @param: otherBackground   Image with the modification panel for the rest of the colors
   * @param: calibrationParameters  JSONObject with values to create Color objects and to set the PApplet's size
   */
  public ColorRange(PImage whiteBackground, PImage blackBackground, PImage otherBackground, JSONObject calibrationParameters) {
    load(calibrationParameters);
    WHITEBG = whiteBackground;
    BLACKBG = blackBackground;
    OTHERBG = otherBackground;
  }


  /**
   * Creates Color instances from a JSONObject and sets the width and height of the PApplet
   * @param: calibrationParameters  JSONObject with values to create Color objects and to set the PApplet's size
   */
  private void load(JSONObject calibrationParameters) {
    JSONObject colorRange = calibrationParameters.getJSONObject("Color Range");
    WIDTH = colorRange.getInt("w");
    HEIGHT = colorRange.getInt("h");

    JSONArray colorLimits = calibrationParameters.getJSONArray("Color Limits");      
    for (int i = 0; i < colorLimits.size(); i++) {
      JSONObject c = colorLimits.getJSONObject(i);  
      String acronym = c.getString("acronym");  
      if (acronym.equals("W")) {
        White w = new White(c);
        W = w;
      } else if (acronym.equals("BK")) {
        Black bl = new Black(c);
        BL = bl;
      } else {
        Other o = new Other(c);
        OT.add(o);
      }
    }
  }


  /**
   * Sets the size of the PApplet. P3D enables the use of vertices
   */
  public void settings() {
    size(WIDTH, HEIGHT + 20, P2D);
  }


  /**
   * Creates a PGraphics opbject to be displayed in the PApplet and sets colorMode to HSB
   */
  public void setup() {
    LEGEND = createGraphics(WIDTH, HEIGHT + 20);
    colorMode(HSB, 360, 100, 100);
  }


  /**
   * Depending on the mode, shows a modification panel to change color calibrations while running
   * WMODE: Shows modification panel for color white
   * BMODE: Shows modification panel for color black
   * OMODE: Shows modification panel for other colors
   */
  public void draw() {
    LEGEND.beginDraw();
    if (WMODE) {
      controlPanelWhite();
    } else if (BMODE) {
      controlPanelBlack();
    } else if (OMODE) {
      controlPanelOthers();
    }
    LEGEND.endDraw();

    image(LEGEND, 0, 0);
  }


  /**
   * Enables the option to modify hue, saturation and brightness for color white using control bars
   */
  private void controlPanelWhite() {
    int maxHue = (int) map(W.getMaxHue(), 0, 100, 0, HEIGHT);
    int minHue = (int) map(W.getMinHue(), 0, 100, 0, HEIGHT);
    int maxSat = (int) map(W.getMaxSat(), 0, 100, 0, HEIGHT);
    int maxSat2 = (int) map(W.getMaxSat2(), 0, 100, 0, HEIGHT);
    int minBri = (int) map(W.getMinBri(), 0, 100, 0, HEIGHT);

    LEGEND.image(WHITEBG, 0, 0, WIDTH, HEIGHT + 20);
    LEGEND.fill(0);
    LEGEND.stroke(0);
    LEGEND.rect(WIDTH/5, 0, 1.5, HEIGHT);
    LEGEND.rect((3 * WIDTH)/5, 0, 1.5, HEIGHT);
    LEGEND.rect((4 * WIDTH)/5, 0, 1.5, HEIGHT);
    LEGEND.fill(255);
    LEGEND.stroke(255);
    LEGEND.rect(2, maxSat, WIDTH/5 - 3, CONTROLLER);
    LEGEND.rect(WIDTH/5 + 2, minBri, WIDTH/5 - 3, CONTROLLER);    
    LEGEND.rect((2 * WIDTH)/5 + 4, maxSat2, WIDTH/5 - 5, CONTROLLER);
    LEGEND.rect((3 * WIDTH)/5 + 2, maxHue, WIDTH/5 - 3, CONTROLLER);
    LEGEND.rect((4 * WIDTH)/5 + 2, minHue, WIDTH/5 - 3, CONTROLLER);
  }


  /**
   * Enables the option to modify saturation and brightness for color black using control bars
   */
  private void controlPanelBlack() {
    int maxSat = (int) map(BL.getMaxSat(), 0, 100, 0, WIDTH/2);
    int maxBri = (int) map(BL.getMaxBri(), 0, 100, 0, WIDTH/2);
    int maxBri2 = (int) map(BL.getMaxBri2(), 0, 100, 0, WIDTH/2);

    LEGEND.image(BLACKBG, 0, 0, WIDTH, HEIGHT + 20);
    LEGEND.fill(255);
    LEGEND.stroke(0);
    LEGEND.rect(WIDTH/2, 0, 4, HEIGHT + 20);
    LEGEND.fill(255);
    LEGEND.stroke(255);
    LEGEND.rect(maxBri, 0, CONTROLLER, HEIGHT);
    LEGEND.rect(maxBri2 + WIDTH/2, 0, CONTROLLER, HEIGHT/2);
    LEGEND.rect(maxSat + WIDTH/2, HEIGHT/2, CONTROLLER, HEIGHT/2);
  }


  /**
   * Enables the option to modify ranges for the rest of the colors using control bars
   */
  private void controlPanelOthers() {
    LEGEND.image(OTHERBG, 0, 0, WIDTH, HEIGHT + 20);
    for (Color c : OT) {
      int x = (int) map(c.getMaxHue(), 0, 360, 0, WIDTH);
      LEGEND.stroke(255);
      LEGEND.rect(x, 0, CONTROLLER, HEIGHT);
    }
  }


  /**
   * Depending on which panel is being shown, allows selecting and moving control bars for hue, saturation and brigthness
   * WMODE: Control bars to change hue, saturation and brightness for color white
   * BMODE: Control bars to change brightness and saturation for color black
   * OMODE: Control bars to change hue - if near a threshold - for other colors
   */
  public void mousePressed() {
    int mousex = mouseX;
    int mousey = mouseY;
    if (WMODE) {
      int maxHue = (int) map(W.getMaxHue(), 0, 100, 0, HEIGHT);
      int minHue = (int) map(W.getMinHue(), 0, 100, 0, HEIGHT);
      int maxSat = (int) map(W.getMaxSat(), 0, 100, 0, HEIGHT);
      int maxSat2 = (int) map(W.getMaxSat2(), 0, 100, 0, HEIGHT);
      int minBri = (int) map(W.getMinBri(), 0, 100, 0, HEIGHT);
      if ((mousex < WIDTH/5) && (mousey > maxSat) && (mousey < maxSat + CONTROLLER)) {
        W.changeMode();
      } else if ((mousex < (2 * WIDTH)/5) && (mousey > minBri) && (mousey < minBri + CONTROLLER)) {
        W.changeMode();
      } else if ((mousex < (3 * WIDTH)/5) && (mousey > maxSat2) && (mousey < maxSat2 + CONTROLLER)) {
        W.changeMode();
      } else if ((mousex < (4 * WIDTH)/5) && (mousey > maxHue) && (mousey < maxHue + CONTROLLER)) {
        W.changeMode();
      } else if ((mousex < WIDTH) && (mousey > minHue) && (mousey < minHue + CONTROLLER)) {
        W.changeMode();
      }
    } else if (BMODE) {
      int maxBri = (int) map(BL.getMaxBri(), 0, 100, 0, WIDTH/2);
      int maxBri2 = (int) map(BL.getMaxBri2(), 0, 100, 0, WIDTH/2);
      int maxSat = (int) map(BL.getMaxSat(), 0, 100, 0, WIDTH/2);
      if ((mousex > maxBri) && (mousex < maxBri + CONTROLLER)) {
        BL.changeMode();
      } else if ((mousex > maxBri2 + WIDTH/2) && (mousex < maxBri2 + CONTROLLER + WIDTH/2) && (mousey < HEIGHT/2)) {
        BL.changeMode();
      } else if ( (mousex > maxSat + WIDTH/2) && (mousex < maxSat + CONTROLLER + WIDTH/2) && (mousey > HEIGHT/2) ) {
        BL.changeMode();
      }
    } else {
      for (Color c : OT) {
        int x = (int) map(c.getMaxHue(), 0, 360, 0, WIDTH);
        if ((mousex > x) && (mousex < x + CONTROLLER)) {
          c.changeMode();
        }
      }
    }
  }


  /**
   * Depending on which panel is being shown, sets a new color calibration for hue, saturation and brightness after releasing a control bar
   * WMODE: New hue, saturation and brightness values for color white
   * BMODE: New brightness and saturation values for color black
   * OMODE: New hue values for other colors
   */
  public void mouseReleased() {
    int mousex = mouseX;
    int mousey = mouseY;
    if (WMODE) {
      if (W.getSelected()) {
        if ((mousex < WIDTH/5)) {
          W.setMaxSat(map(mousey, 0, HEIGHT, 0, 100));
          W.changeMode();
        } else if ((mousex < (2 * WIDTH)/5)) {
          W.setMinBri(map(mousey, 0, HEIGHT, 0, 100));
          W.changeMode();
        } else if ((mousex < (3 * WIDTH)/5)) {
          W.setMaxSat2(map(mousey, 0, HEIGHT, 0, 100));
          W.changeMode();
        } else if ((mousex < (4 * WIDTH)/5)) {
          W.setMaxHue(map(mousey, 0, HEIGHT, 0, 100));
          W.changeMode();
        } else if ((mousex < WIDTH)) {
          W.setMinHue(map(mousey, 0, HEIGHT, 0, 100));
          W.changeMode();
        }
      }
    } else if (BMODE) {
      if (BL.getSelected()) {
        if (mousex < WIDTH/2) {
          BL.setMaxBri(map(mousex, 0, WIDTH/2, 0, 100));
        } else if (mousey < HEIGHT/2) {
          BL.setMaxBri2(map(mousex - WIDTH/2, 0, WIDTH/2, 0, 100));
        } else {
          BL.setMaxSat(map(mousex - WIDTH/2, 0, WIDTH/2, 0, 100));
        }         
        BL.changeMode();
      }
    } else {
      for (Color c : OT) {
        if (c.SELECTED) {
          c.setMaxHue(map(mousex, 0, WIDTH, 0, 360));
          c.changeMode();
          break;
        }
      }
    }
  }


  /**
   * Performs certain actions when a key is pressed
   * @case: 'b'  Activates BMODE
   * @case: 'w'  Activates WMODE
   * @case: 'o'  Activates OMODE
   * @case: 's'  Hides the PApplet
   */
  public void keyPressed() {
    switch(key) {
    case 'b':
      if (WMODE | OMODE) {
        WMODE = false;
        OMODE = false;
      }
      BMODE = !BMODE;
      break;

    case 'w':
      if (BMODE | OMODE) {
        BMODE = false;
        OMODE = false;
      }
      WMODE = !WMODE;
      break;

    case 'o':
      if (BMODE | WMODE) {
        BMODE = false;
        WMODE =false;
      }
      OMODE = !OMODE;
      break;

    case 's':
      this.getSurface().setVisible(false);
      break;
    }
  }


  /**
   * Gets the value of the W attribute
   * @returns: White  Value of W
   */
  public White getWhite() {
    return W;
  }


  /**
   * Gets all the stored colors
   * @returns: ArrayList<Color>  An array with all the stored colors
   */
  public ArrayList<Color> selectAll() {
    ArrayList<Color> colors = new ArrayList<Color>();
    colors.add(W);
    colors.add(BL);
    colors.addAll(OT);
    return colors;
  }

  /**
   * Gets the size of the PApplet
   * @returns: JSONObject  A JSONObject with the values of WIDTH and HEIGHT
   */
  public JSONObject getSize() {
    JSONObject size = new JSONObject();
    size.setInt("w", WIDTH);
    size.setInt("h", HEIGHT);

    return size;
  }


  /**
   * Shows the PApplet
   */
  public void show() {
    this.getSurface().setVisible(true);
  }


  /**
   * Calls the saveConfiguration method for each stored Color instance
   * @returns:  JSONArray  A JSONArray with values of all the stored Color objects
   */
  public JSONArray saveConfiguration() {
    JSONArray colorLimits = new JSONArray();

    JSONObject whiteLimit = W.saveConfiguration();
    colorLimits.append(whiteLimit);

    JSONObject blackLimit = BL.saveConfiguration();
    colorLimits.append(blackLimit);

    for (Other o : OT) {
      JSONObject otherLimit = o.saveConfiguration();
      colorLimits.append(otherLimit);
    }

    return colorLimits;
  }
}
