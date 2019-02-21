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

public class ColorRange extends PApplet {
  ArrayList<Color> colorLimits = new ArrayList();
  int w;
  int h;
  Boolean black =  false;
  Boolean white = false;
  Boolean otherColors = true;
  int mx;
  int my;
  int scale = 6;
  int control = 5;

  public ColorRange(ArrayList<Color> colorLimits, int w, int h) {
    this.colorLimits = colorLimits;
    this.w = w;
    this.h = h;
  }

  public void settings() {
    size(this.w, this.h + 20);
  }

  public void setup() {
    legendColor = createGraphics(this.w, this.h + 20);
    colorMode(HSB, 360, 100, 100);
  }

  /**
   *Create the manual control to change color limits while running
   **/
  public void draw() {
      legendColor.beginDraw();
      legendColor.fill(0);
      legendColor.rect(0, h, w, 20);
      legendColor.fill(255);
      legendColor.textAlign(CENTER); 
      legendColor.rectMode(CORNER);
      legendColor.colorMode(HSB, 360, 100, 100);
      if (white) {
        controlPanelWhite();
      } else if (black) {
        controlPanelBlack();
      } else {
        controlPanelOthers();
      }
      legendColor.endDraw();
      image(legendColor, 0, 0);
  }

  /**
    *Enable the option to modify hue, saturation and brightness for the color white
  **/
  void controlPanelWhite() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        float max = map(y, 0, h, 0, 100);
        if (x < w/5) { //SatMax
          legendColor.stroke(0, 0, 100 - max);
          legendColor.point(x, y);
        } else if (x < (2 * w)/5) { //BriMin
          legendColor.stroke(0, 0, max);
          legendColor.point(x, y);
        } else if (x < (3 * w)/5) { //SatMax
          legendColor.stroke(0, 0, 100 - max);
          legendColor.point(x, y);
        } else if (x< (4 * w)/5) { //HueMax
          legendColor.stroke(max, 50, 100);
          legendColor.point(x, y);
        } else {//HueMin
          legendColor.stroke(max, 50, 100);
          legendColor.point(x, y);
        }
      }
    }
    int satMax = (int) map(config.colorW.satMax, 0, 100, 0, h);
    int briMin = (int) map(config.colorW.briMin, 0, 100, 0, h);
    int satMax2 = (int) map(config.colorW.satMax2, 0, 100, 0, h);
    int maxHue = (int) map(config.colorW.maxHue, 0, 100, 0, h);
    int hueMin = (int) map(config.colorW.hueMin, 0, 100, 0, h);
    /**
      *Display the ranges for hue, saturation and brightness
    **/
    legendColor.fill(0);
    legendColor.stroke(0);
    legendColor.textSize(legendColor.height/3);
    legendColor.textAlign(CENTER, CENTER);
    legendColor.text("S", w/10, h/2 );
    legendColor.text("B", w/10 + w/5, h/2 );
    legendColor.text("S", w/10 +(2 * w)/5, h/2 );
    legendColor.textSize(legendColor.height/3.5);
    legendColor.text("Hmax", w/10 +(3 * w)/5, h/2 );
    legendColor.text("Hmin", w/10 +(4 * w)/5, h/2 );
    legendColor.rect(w/5, 0, 1.5, h);
    legendColor.rect((3 * w)/5, 0, 1.5, h);
    legendColor.rect((4 * w)/5, 0, 1.5, h);
    legendColor.fill(0, 0, 100);
    legendColor.stroke(0);
    legendColor.rect((2 * w)/5, 0, 4, h + 20);
    legendColor.textSize(12);
    legendColor.textAlign(CENTER);
    legendColor.text("Modify white parameters", w/5, h + 15);
    legendColor.text("Modify yellow bias", (7 * w)/10, h+15); 
    legendColor.fill(255);
    legendColor.stroke(255);
    legendColor.rect(2, satMax, w/5 - 3, control);
    legendColor.rect(w/5 + 2, briMin, w/5 - 3, control);    
    legendColor.rect((2 * w)/5 + 4, satMax2, w/5 - 5, control);
    legendColor.rect((3 * w)/5 + 2, maxHue, w/5 - 3, control);
    legendColor.rect((4 * w)/5 + 2, hueMin, w/5 - 3, control);
  }

  /**
    *Enable the option to modify saturation and brightness for the color black
  **/
  void controlPanelBlack() {
    for (int x = 0; x < w/2; x++) {
      for (int y = 0; y < h; y++) {
        float max = map(x, 0, w/2, 0, 100);
        legendColor.stroke(0, 0, max);
        legendColor.point(x, y);
        if (y < h/2) {
          legendColor.point(x + w/2, y);
        } else {
          legendColor.stroke(0, 0, 100 - max);
          legendColor.point(x + w/2, y);
        }
      }
    }
    int brimax = (int) map(config.colorB.briMax, 0, 100, 0, w/2);
    int brimax2 = (int) map(config.colorB.briMax2, 0, 100, 0, w/2);
    int satmax = (int) map(config.colorB.satMax, 0, 100, 0, w/2);
    /**
      *Display the ranges for saturation and brightness
    **/
    legendColor.fill(0);
    legendColor.stroke(0);
    legendColor.textSize(legendColor.height/3);
    legendColor.textAlign(CENTER, CENTER);
    legendColor.text("B", w/4, h/2);
    legendColor.text("B", w/4 + w/2, h/4);
    legendColor.text("S", w/4 + w/2, h/4 + h/2);
    legendColor.fill(0, 0, 100);
    legendColor.stroke(0);
    legendColor.rect(w/2, 0, 4, h + 20);
    legendColor.textSize(12);
    legendColor.textAlign(CENTER);
    legendColor.text("Modify black parameters ", w/4, h + 15);
    legendColor.text("Modify red bias", (3 * w)/4, h + 15);
    legendColor.fill(255);
    legendColor.stroke(255);
    legendColor.rect(brimax, 0, control, h);
    legendColor.rect(brimax2 + w/2, 0, control, h/2);
    legendColor.rect(satmax + w/2, h/2, control, h/2);
  }

  /**
    *Enable the option to modify ranges for the rest of the colors
  **/
  void controlPanelOthers() {
    for (int x = 0; x < w; x++) {
      for (int y = 0; y < h; y++) {
        float i = map(x, 0, w, 0, 360);
        legendColor.stroke(i, y, 100);
        legendColor.point(x, y);
      }
    }
    for (Color c : config.colorO) {
      int x = (int) map(c.maxHue, 0, 360, 0, w);
      legendColor.fill(255);
      legendColor.stroke(255);
      legendColor.rect(x, 0, control, h);
      legendColor.text("x = Modify color limits", w/2, h + 15);
    }
  }

  /**
   *White: Select a color rect to change hue, saturation and brightness
   *Black: Select a color rect to change brigness and saturation or rect for brightness
   *Other colors:Select a color rect if it is near threshold
   **/
  void mousePressed() {
    int mousex = mouseX;
    int mousey = mouseY;
    if (white) {
      int satMax = (int) map(config.colorW.satMax, 0, 100, 0, h);
      int briMin = (int) map(config.colorW.briMin, 0, 100, 0, h);
      int satMax2 = (int) map(config.colorW.satMax2, 0, 100, 0, h);
      int maxHue = (int) map(config.colorW.maxHue, 0, 100, 0, h);
      int hueMin = (int) map(config.colorW.hueMin, 0, 100, 0, h);
      if ((mousex < w/5) && (mousey > satMax) && (mousey < satMax + control)) {
        config.colorW.changeMode();
      } else if ((mousex < (2 * w)/5) && (mousey > briMin) && (mousey < briMin + control)) {
        config.colorW.changeMode();
      } else if ((mousex < (3 * w)/5) && (mousey > satMax2) && (mousey < satMax2 + control)) {
        config.colorW.changeMode();
      } else if ((mousex < (4 * w)/5) && (mousey > maxHue) && (mousey < maxHue + control)) {
        config.colorW.changeMode();
      } else if ((mousex < w) && (mousey > hueMin) && (mousey<hueMin+control)) {
        config.colorW.changeMode();
      }
    } else if (black) {
      int brimax = (int) map(config.colorB.briMax, 0, 100, 0, w/2);
      int brimax2 = (int) map(config.colorB.briMax2, 0, 100, 0, w/2);
      int satmax = (int) map(config.colorB.satMax, 0, 100, 0, w/2);
      if ((mousex > brimax) && (mousex < brimax + control)) {
        config.colorB.changeMode();
      } else if ((mousex > brimax2 + w/2) && (mousex < brimax2 + control + w/2) && (mousey < h/2)) {
        config.colorB.changeMode();
      } else if ( (mousex > satmax + w/2) && (mousex < satmax + control + w/2) && (mousey > h/2) ) {
        config.colorB.changeMode();
      }
    } else {
      for (Color c : config.colorO) {
        int x = (int) map(c.maxHue, 0, 360, 0, w);
        if ((mousex > x) && (mousex < x + control)) {
          c.changeMode();
        }
      }
    }
  }

  /**
   *Set a new color Limit for hue, saturation and brightness
   **/
  void mouseReleased() {
    int mousex = mouseX;
    int mousey = mouseY;
    if (white) {
      if (config.colorW.selectionMode) {
        if ((mousex < w/5)) {
          config.colorW.satMax = (int) map(mousey, 0, h, 0, 100);
          config.colorW.changeMode();
        } else if ((mousex < (2 * w)/5)) {
          config.colorW.briMin = (int) map(mousey, 0, h, 0, 100);
          config.colorW.changeMode();
        } else if ((mousex < (3 * w)/5)) {
          config.colorW.satMax2 = (int) map(mousey, 0, h, 0, 100);
          config.colorW.changeMode();
        } else if ((mousex < (4 * w)/5)) {
          config.colorW.maxHue = (int) map(mousey, 0, h, 0, 100);
          config.colorW.changeMode();
        } else if ((mousex < w)) {
          config.colorW.hueMin = (int) map(mousey, 0, h, 0, 100);
          config.colorW.changeMode();
        }
      }
    } else if (black) {
      if (config.colorB.selectionMode) {
        if (mousex < w/2) {
          config.colorB.briMax = (int) map(mousex, 0, w/2, 0, 100);
        } else if (mousey < h/2) {
          config.colorB.briMax2 = (int) map(mousex - w/2, 0, w/2, 0, 100);
        } else {
          config.colorB.satMax = (int) map(mousex - w/2, 0, w/2, 0, 100);
        }         
        config.colorB.changeMode();
      }
    } else {
      for (Color c : config.colorO) {
        if (c.selectionMode) {
          c.maxHue = map(mousex, 0, w, 0, 360);
          c.changeMode();
          break;
        }
      }
    }
  }

  /**
   *Choose between white, black or other colors configuration
   **/
  void keyPressed() {
    switch(key) {
    case 'b':
      if (white | otherColors) {
        white=false;
        otherColors=false;
      }
      black = !black;
      if (black) print("\n Black mode on");
      break;

    case 'w':
      if (black | otherColors) {
        black=false;
        otherColors=false;
      }
      white = !white;
      if (white) print("\n White mode on");
      break;

    case 'o':
      if (black | white) {
        black=false;
        white=false;
      }
      otherColors = !otherColors;
      if (otherColors) print("\n Hue mode on");
      break;
    }
  }

  /**
   *Get all the colors
   **/
  public ArrayList<Color> selectAll() {
    return colorLimits;
  }
}
