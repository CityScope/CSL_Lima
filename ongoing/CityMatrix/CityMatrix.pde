/**
 * @copyright: Copyright (C) 2019
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.11
 * @legal:
 * This file is part of CityMatrix.
 
 * CityMatrix is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * CityMatrix is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with CityMatrix.  If not, see <http://www.gnu.org/licenses/>.
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
Capture cam;
Configuration configuration;
boolean exportToUdp = false;
PImage imageWarped;
PGraphics canvasCamera, canvasMesh;
boolean show = true;


/**
 * P3D needs to be passed as an argument to size to enable the use of vertices
 */
void settings() {
  size(sizeCanvas * 2, sizeCanvas, P2D);
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
    configuration = new Configuration("calibrationParameters.json");

    canvasMesh = createGraphics(sizeCanvas, sizeCanvas);
    canvasCamera = createGraphics(sizeCanvas, sizeCanvas, P2D);
    imageWarped = createImage(sizeCanvas, sizeCanvas, HSB);

    String[] patterns = {"Patterns"};
    String[] city = {"City3D"};

    configuration.runSketches(patterns, city);
    
    //Capture widht and height must match a supported camera resolution
    //This does not work: cam = new Capture(this, canvas.width, canvas.height, cameras[0]);
    cam = new Capture(this, 640, 480, cameras[cameras.length-1]);
    cam.start();
  }
}


void draw() {
  canvasCamera.beginDraw();
  canvasCamera.background(255);
  configuration.flip(canvasCamera, cam);
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
}


/**
 * Performs certain actions when a key is pressed
 * @param: e      KeyEvent
 * @case: UP      Increases brightness level
 * @case: DOWN    Decreases brightness level
 * @case: RIGHT   Increases saturation level
 * @case: LEFT    Decreases saturation level
 * @case: 'b'     Shows BlockReader PApplet
 * @case: 'c'     Shows City3D PApplet
 * @case: 'e'     Exports the grid
 * @case: 'f'     Toggles the mirroring of the image shown by the camera
 * @case: 'p'     Shows Patterns PApplet
 * @case: 'r'     Shows City3D PApplet
 * @case: 's'     Saves custom changes
 * @case: '+'     Increases the number of blocks in the grid
 * @case: '-'     Decreases the number of blocks in the grid
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
    configuration.toggle();
    break;

  case 'c':
    configuration.showCity();
    break;

  case 'e':
    configuration.exportGrid();
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
 * Starts reading from the camera
 * @param: cam  Capture object which represents the camera to read from
 */
void captureEvent(Capture cam) {
  cam.read();
}


void toggle() {
  show = !show;
  this.getSurface().setVisible(show);
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
