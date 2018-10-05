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

/**
  Import required libraries
**/
import processing.video.*;
import java.util.Collections;

/**
  *Initialize variables
**/
PGraphics canvas, canvasOriginal, canvasPattern, canvasColor, legendColor;

int sizeCanvas = 480; 
PImage colorImage, imageWarped, camFlipped, capture, shot;
float inc = 1;

Boolean refresh = false, flipped = true;
ArrayList<PVector> posibles = new ArrayList();
ArrayList<PVector> calibrationPoints = new ArrayList();

Capture cam;
WarpedPerspective warpedPerspective;
ColorRange colorRange;
Mesh mesh;
BlockReader blockReader;
Configuration config = new Configuration(sizeCanvas, "data/calibrationParameters.json");
PatternBlocks patternBlocks;
Patterns patterns;

void settings() {
  /**
    *P3D needs to be passed as an argument to size to enable the use of vertices
  **/
  size(sizeCanvas * 2, sizeCanvas, P3D);
}

void setup() {
  colorMode(HSB, 360, 100, 100);
  /**
    *Looks for connected cameras
  **/
  String[] cameras = Capture.list();
  print(cameras.length);
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    canvas = createGraphics(sizeCanvas, sizeCanvas,P3D);
    canvasOriginal = createGraphics(sizeCanvas, sizeCanvas, P3D);
    imageWarped = createImage(sizeCanvas, sizeCanvas, HSB);

    config.loadConfiguration();
    String[] pattern = {"Patterns"};
    patterns = new Patterns(canvasPattern, config);
    PApplet.runSketch(pattern, patterns);

    mesh = new Mesh(config.nblocks/2, canvas.width);
    warpedPerspective = new WarpedPerspective(config.contour);

    cam = new Capture(this);
    cam.start();

    String[] args = {"Animation"};
    String[] name = {"color"};

    blockReader = new BlockReader(sizeCanvas, sizeCanvas);
    colorRange = new ColorRange(config.colorLimits, 600, 100);

    PApplet.runSketch(name, colorRange);
    PApplet.runSketch(args, blockReader);
  }
}

void draw() {
    canvasOriginal.beginDraw();
    config.flip(canvasOriginal, cam, flipped);
    warpedPerspective.draw(canvasOriginal);
    canvasOriginal.endDraw();
    image(canvasOriginal, 0, 0);
    
    imageWarped = warpedPerspective.applyPerspective(canvasOriginal);  
    mesh.applyFilter(imageWarped);
    
    canvas.beginDraw();
    canvas.background(255);
    canvas.image(imageWarped, 0, 0);
    mesh.drawGrid(canvas);
    canvas.endDraw();
    image(canvas, canvas.width, 0);
}

void keyPressed(KeyEvent e) {
  switch(e.getKeyCode()) {
  case UP:
    config.brightnessLevel += inc;
    println(config.brightnessLevel);
    break;

  case DOWN:
    config.brightnessLevel -= inc;
    println(config.brightnessLevel);
    break;

  case RIGHT:
    config.saturationLevel += inc;
    println(config.saturationLevel);
    break;

  case LEFT:
    config.saturationLevel -= inc;
    println(config.saturationLevel);
    break;
  }

  switch(key) {
    //saves the calibration points
  case 's':
    config.saveConfiguration(colorRange.selectAll());
    break;

    //exports the configuration of the patterns
  case 'e':
    config.exportGrid(mesh.patternBlocks, patterns);
    break;

    //refreshes
  case 'r':
    print(true);
    refresh = !refresh;

    //flips the image in the canvas
  case 'f':
  flipped = !flipped;
  config.flip(canvasOriginal, cam, flipped);
  break;
  
  //adds pattern blocks
  case '+':
    config.nblocks += 1;
    mesh.update(config.nblocks, canvas.width);
    config.updateSizeCanvas(canvas.width % config.nblocks, canvas.height % config.nblocks);
    break;

    //reduces pattern blocks
  case '-':
    config.nblocks-=1;
    mesh.update(config.nblocks, canvas.width);
    config.updateSizeCanvas(canvas.width % config.nblocks, canvas.height % config.nblocks);
    break;
  }
}

void captureEvent(Capture cam) {
  cam.read();
}

void mousePressed() {
  warpedPerspective.selected(mouseX, mouseY, 5);
}

void mouseReleased() {
  warpedPerspective.unselect();
}

void mouseDragged() {
  warpedPerspective.move(mouseX, mouseY);
}