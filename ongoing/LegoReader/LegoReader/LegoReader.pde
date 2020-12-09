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
import hypermedia.net.*;
import processing.serial.*;

/**
  *Initialize variables
**/
PGraphics canvas, canvasOriginal, canvasPattern, canvasColor, legendColor;

final int blockSize = 20;
int patternsw;
int patternsh;
int sizeCanvas = 480; 
PImage colorImage, imageWarped, camFlipped, capture, shot;
float inc = 3;
<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
=======
boolean flipped = true;
Capture cam;
Configuration configuration;
boolean exportToUdp = true;
PImage imageWarped;
PGraphics canvasCamera;
PGraphics canvasMesh;
PImage white, black, col;
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde

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
Boolean exportToUdp = true;

void settings() {
<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
  /**
    *P3D needs to be passed as an argument to size to enable the use of vertices
  **/
  size(sizeCanvas * 2, sizeCanvas, P3D);
}

=======
  size(sizeCanvas * 2, sizeCanvas, P2D);
}


/**
 * Looks for connected cameras and instantiates variables if cameras are available
 */
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde
void setup() {
  
  colorMode(HSB, 360, 100, 100);
  /**
    *Looks for connected cameras
  **/
  String[] cameras = Capture.list();
<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
  print(cameras.length);
=======
  println(cameras.length);

>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
    canvas = createGraphics(sizeCanvas, sizeCanvas,P3D);
    canvasOriginal = createGraphics(sizeCanvas, sizeCanvas,P3D);
    imageWarped = createImage(sizeCanvas, sizeCanvas, HSB);

    config.loadConfiguration();
    
    patternsw = 480;
    patternsh = blockSize * 4 * ceil(float(config.patterns.size())/3);
    canvasPattern = createGraphics(patternsw, patternsh);    
    String[] pattern = {"Patterns"};
    patterns = new Patterns(canvasPattern, config, blockSize);
    PApplet.runSketch(pattern, patterns);

    mesh = new Mesh(config.nblocks/2, canvas.width);
    warpedPerspective = new WarpedPerspective(config.contour);

    cam = new Capture(this,canvas.width, canvas.height, cameras[0]);
    cam.start();
=======
    white = loadImage("data/background/white.png");
    black = loadImage("data/background/black.png");
    col = loadImage("data/background/color.png");

    configuration = new Configuration("calibrationParameters.json", white, black, col);

    canvasMesh = createGraphics(sizeCanvas, sizeCanvas);
    canvasCamera = createGraphics(sizeCanvas, sizeCanvas, P2D);
    imageWarped = createImage(sizeCanvas, sizeCanvas, HSB);
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde

    String[] args = {"Animation"};
    String[] name = {"color"};

    blockReader = new BlockReader(sizeCanvas, sizeCanvas);
    colorRange = new ColorRange(config.colorLimits, 600, 100);

<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
    PApplet.runSketch(name, colorRange);
    PApplet.runSketch(args, blockReader);
=======
    cam = new Capture(this, 640, 480, cameras[cameras.length - 1]);
    cam.start();
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde
  }
}

void draw() {
<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
  if(canvasOriginal !=null){
    canvasOriginal.beginDraw();
    canvasOriginal.clear();
    config.flip(canvasOriginal, cam, flipped);
    warpedPerspective.draw(canvasOriginal);
    canvasOriginal.endDraw();
    image(canvasOriginal, 0, 0);
    
    imageWarped = warpedPerspective.applyPerspective(canvasOriginal);  
    mesh.applyFilter(imageWarped);
    
    canvas.beginDraw();
    canvas.clear();
    canvas.background(255);
    canvas.image(imageWarped, 0, 0);
    mesh.drawGrid(canvas);
    canvas.endDraw();
    image(canvas, canvas.width, 0);
    if (exportToUdp){
      if (frameCount % 5 == 0){
        config.exportGridUDP(mesh.patternBlocks,patterns);
      }
=======
  canvasCamera.beginDraw();
  canvasCamera.background(255);
  configuration.flip(canvasCamera, cam, flipped);
  configuration.drawWarp(canvasCamera);
  canvasCamera.endDraw();
  image(canvasCamera, 0, 0);

  imageWarped = configuration.applyPerspective(canvasCamera);  
  configuration.applyFilter(imageWarped);

  canvasMesh.beginDraw();
  canvasMesh.background(255);
  canvasMesh.image(imageWarped, 0, 0);
  configuration.drawGrid(canvasMesh);
  canvasMesh.endDraw();
  image(canvasMesh, canvasMesh.width, 0);

  if (exportToUdp) {
    if (frameCount % 60 == 0) {
      configuration.exportGridUDP();
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde
    }
  }else{
    println("canvasOriginal is null");
    setup();
  }
}

<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
=======

/**
 * Performs certain actions when a key is pressed
 * @param: e      KeyEvent
 * @case: UP      Increases brightness level
 * @case: DOWN    Decreases brightness level
 * @case: RIGHT   Increases saturation level
 * @case: LEFT    Decreases saturation level
 * @case: 'b'     Shows BlockReader PApplet
 * @case: 'c'     Shows ColorRange PApplet
 * @case: 'p'     Shows Patterns PApplet
 * @case: 'e'     Exports the grid
 * @case: 's'     Saves custom changes
 * @case: 'f'     Toggles the mirroring of the image shown by the camera
 * @case: '+'     Increases the number of blocks in the grid
 * @case: '-'     Decreases the number of blocks in the grid
 */
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde
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
<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
    //saves the calibration points
  case 's':
    config.saveConfiguration(colorRange.selectAll());
=======
  case 'b':
    configuration.showBlockReader();
    break;

  case 'c':
    configuration.showColorRange();
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde
    break;

    //exports the configuration of the patterns
  case 'e':
<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
    config.exportGrid(mesh.patternBlocks, patterns);
    config.exportGridUDP(mesh.patternBlocks,patterns);
    break;

    //refreshes
  case 'r':
    print(true);
    refresh = !refresh;
=======
    configuration.exportGrid();
    break;

  case 'f':
    flipped = !flipped;
    configuration.flip(canvasCamera, cam, flipped);
    break;

  case 'p':
    configuration.showPatterns();
    break;

  case 's':
    configuration.saveConfiguration();
    break;
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde

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

<<<<<<< HEAD:projects/LegoReader/LegoReader.pde
=======

/**
 * Starts reading from the camera
 * @param: cam  Capture object which represents the camera to read from
 */
>>>>>>> 769bf08e79ae99e5d0912f69f0d1c794f6921b8b:ongoing/LegoReader/LegoReader/LegoReader.pde
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
