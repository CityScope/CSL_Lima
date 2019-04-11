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
import processing.serial.*;


/**
 * Variable initialization
 */
int sizeCanvas = 480;
float inc = 3;
boolean flipped = true;
Capture cam;
Configuration configuration;
boolean exportToUdp = true;
PImage imageWarped;
PGraphics canvasCamera;
PGraphics canvasMesh;
PImage white, black, col;

//FIXME: Temporay solution to integrate a physical slider
boolean slider=true;
Serial myPort;
private UDP udp; //Create UDP object for recieving
private int PORT = 9878;
private String HOST_IP = "localhost"; //IP Address of the PC in which this App is running
String val; // variable that is passed from processing to arduino
//END FIXME


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
  
  //FIXME: Temporal arduino
  String portName = Serial.list()[3]; ///*** change the port and CLOSE arduino serial monitor
  myPort = new Serial(this, portName, 74880); 
  //ENDFIMXE
  
  colorMode(HSB, 360, 100, 100);

  String[] cameras = Capture.list();
  println(cameras.length);

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    white = loadImage("data/background/white.png");
    black = loadImage("data/background/black.png");
    col = loadImage("data/background/color.png");

    configuration = new Configuration("calibrationParameters.json", white, black, col);

    canvasMesh = createGraphics(sizeCanvas, sizeCanvas);
    canvasCamera = createGraphics(sizeCanvas, sizeCanvas, P2D);
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
    if (frameCount % 60 == 0) {
      configuration.exportGridUDP();
    }
    //FIXME: Temporal Hack for Arduino
    if (myPort.available() > 0) {  
      val = myPort.readStringUntil('\n');
    }
  }
}


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
 * Starts reading from the camera
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
