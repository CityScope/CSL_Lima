/**
 * @copyright: Copyright (C) 2018
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
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
 * Import required libraries
 */
import processing.video.*;
import java.util.Collections;
import hypermedia.net.*;


/**
 * Variable initialization
 */
int sizeCanvas = 480;
float inc = 3;
boolean flipped = true;
Capture cam;
Configuration configuration;
boolean exportToUdp = false;
PImage imageWarped;
PGraphics canvasCamera;
PGraphics canvasMesh;
PGraphics canvasPatterns;
PImage white, black, col;


/**
 * P3D needs to be passed as an argument to size to enable the use of vertices
 */
void settings() {
  size(sizeCanvas * 2, sizeCanvas, P3D);
}


/**
 * Looks for connected cameras and instantiates variables if cameras are available
 */
void setup() {
  colorMode(HSB, 360, 100, 100);

  String[] cameras = Capture.list();
  println(cameras.length);

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    white = loadImage("background/white.png");
    black = loadImage("background/black.png");
    col = loadImage("background/color.png");

    configuration = new Configuration("calibrationParameters.json", white, black, col);

    canvasMesh = createGraphics(sizeCanvas, sizeCanvas, P3D);
    canvasCamera = createGraphics(sizeCanvas, sizeCanvas, P3D);
    canvasPatterns = createGraphics(sizeCanvas, sizeCanvas, P3D);
    imageWarped = createImage(sizeCanvas, sizeCanvas, HSB);

    String[] patterns = {"Patterns"};
    String[] colors = {"ColorRange"};
    String[] block = {"BlockReader"};

    configuration.runSketches(patterns, colors, block);

    cam = new Capture(this, canvasCamera.width, canvasCamera.height, cameras[0]);
    cam.start();
  }
}


void draw() {
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
    if (frameCount % 5 == 0) {
      configuration.exportGridUDP();
    }
  }
}


/**
 * Perform certain actions when a key is pressed
 * @param: e      KeyEvent
 * @case: UP      Increase brightness level
 * @case: DOWN    Decrease brightness level
 * @case: RIGHT   Increase saturation level
 * @case: LEFT    Decrease saturation level
 * @case: 'b'     Toggle visibility of BlockReader PApplet
 * @case: 'c'     Toggle visibility of ColorRange PApplet
 * @case: 'p'     Toggle visibility of Patterns PApplet
 * @case: 'e'     Export the grid
 * @case: 's'     Save custom changes
 * @case: 'f'     Toggle the mirroring of the image shown by the camera
 * @case: '+'     Increase the number of blocks in the grid
 * @case: '-'     Decrease the number of blocks in the grid
 */
void keyPressed(KeyEvent e) {
  switch(e.getKeyCode()) {
  case UP:
    configuration.increaseBrightness(inc);
    break;

  case DOWN:
    configuration.decreaseBrightness(inc);
    break;

  case RIGHT:
    configuration.increaseSaturation(inc);
    break;

  case LEFT:
    configuration.decreaseSaturation(inc);
    break;
  }

  switch(key) {
  case 'b':
    configuration.showBlockReader();
    break;

  case 'c':
    configuration.showColorRange();
    break;

  case 'e':
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

  case '+':
    configuration.increaseBlocks();
    configuration.update(canvasMesh.width);
    configuration.updateSizeCanvas(canvasMesh.width, canvasMesh.height);
    break;

  case '-':
    configuration.decreaseBlocks();
    configuration.update(canvasMesh.width);
    configuration.updateSizeCanvas(canvasMesh.width, canvasMesh.height);
    break;
  }
}


/**
 * Start reading from the camera
 * @param: cam  Capture object which represents the camera to read from
 */
void captureEvent(Capture cam) {
  cam.read();
}


/**
 * Calls the select method of configuration
 */
void mousePressed() {
  configuration.select(mouseX, mouseY, 5);
}


/**
 * Calls the move method of configuration
 */
void mouseDragged() {
  configuration.move(mouseX, mouseY);
}


/**
 * Calls the unselect method of configuration
 */
void mouseReleased() {
  configuration.unselect();
}
