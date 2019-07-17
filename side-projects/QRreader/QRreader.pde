/**
 * @copyright: Copyright (C) 2018
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1
 * @legal :
 * This file is part of QRreader.
 
 * QRreader is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * QRreader is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with QReader.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * Import required libraries
 */
import java.util.Collections;
import com.cage.zxing4p3.*;
import processing.video.*;


/**
 * Variable initialization
 */
Configuration configuration;
Capture video;
int size = 700;
PImage imageWarped;
PGraphics canvasCamera;
PGraphics canvasMesh;


/**
 * P3D needs to be passed as an argument to enable the use of vertices
 */
void settings() {
  size(size * 2, size, P3D);
}


/**
 * Instantiates variables if cameras are available
 */
void setup() {
  String[] cameras = Capture.list(); 
  String cameraSelected = cameras[0];
  for (String cam : cameras) {
    println(cam);
    String[] name = cam.split(" ")[0].split("=");
    if (!name.equals("FaceTime")) {
      cameraSelected = cam;
      break;
    }
  }

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    imageWarped = createImage(size * 3, size * 3, RGB); 
    canvasCamera = createGraphics(size, size, P3D);
    canvasMesh = createGraphics(size, size);

    configuration = new Configuration("calibrationParameters.json", size);
    
    video = new Capture(this, 1280, 720, cameraSelected);
    video.start();
  }
} 


void draw() {
  canvasCamera.beginDraw();
  configuration.flip(canvasCamera, video, true);  
  configuration.drawWarp(canvasCamera);
  canvasCamera.endDraw();  
  image(canvasCamera, 0, 0);

  imageWarped = configuration.applyPerspective(canvasCamera);

  canvasMesh.beginDraw();
  canvasMesh.background(0);
  canvasMesh.image(imageWarped, 0, 0);
  configuration.drawGrid(canvasMesh);
  canvasMesh.endDraw();
  image(canvasMesh, canvasCamera.width, 0);
}


/**
 * Perfor certain actions when a key is pressed
 * @param:  e   KeyEvent
 * @case:  ' '  Decodes the QR codes shown in the video
 * @case:  'e'  Decodes the QR codes shown in the video. Exports their values along with their coordinates to a JSON file
 * @case:  's'  Saves custom configuration
 * @case:  UP   Adds blocks
 * @case: DOWN  Deletes blocks
 */
void keyPressed(KeyEvent e) {
  switch(key) {
  case ' ':
    configuration.decode(imageWarped);
    break;

  case 'e':
    configuration.decode(imageWarped);
    configuration.exportGrid(); 
    break;

  case 's':
    configuration.saveConfiguration();
    break;
  }

  switch(e.getKeyCode()) {
  case UP:
    configuration.addBlock();
    break;

  case DOWN:
    configuration.deleteBlock();
    break;
  }
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


void captureEvent(Capture video) {
  video.read();
}
