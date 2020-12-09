/**
 * @copyright: Copyright (C) 2018
 * @authors:   Vanesa Alcántara & Jesús García
 * @version:   1.1 
 * @legal:
 * This file is part of HumanitarianModel.
 
 * HumanitarianModel is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 
 * HumanitarianModel is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 
 * You should have received a copy of the GNU Affero General Public License
 * along with HumanitarianModel.  If not, see <http://www.gnu.org/licenses/>.
 */


/**
 * Import required libraries
 */
import pathfinder.*;
import java.util.*;
import org.gicentre.utils.stat.*;
import deadpixel.keystone.*;


/**
 * Variable initialization
 */
Configuration configuration;
PGraphics canvas;
PGraphics canvasZoom;
String roadPath = "clean_vias.geojson";
String poiPath = "SH.geojson";
String[] zoomName = {"Zoom Map"};
boolean locked;
float xOffset1 = 0.0; 
float yOffset1 = 0.0; 
float xOffset2 = 0.0; 
float yOffset2 = 0.0;   
float sval = 1;
float bx = 0;
float by = 0;
boolean ADDS;
boolean DELETES;

/**
 * P3D needs to be passed as an argument to enable the use of vertices
 */
public void settings() {
  fullScreen(P3D);
}


/**
 * Instantiate variables
 */
public void setup() { 
  canvas = createGraphics(width, height, P3D);
  canvasZoom = createGraphics(height/2, height/2, P3D);
  configuration = new Configuration(roadPath, poiPath, this, height/2, height/2);
}


public void draw() {
  canvas.beginDraw();
  canvas.strokeWeight(0.30);
  configuration.drawGrapho(canvas, false); 
  configuration.drawVisor(canvas);
  canvas.endDraw();
  image(canvas, 0, 0);
  
  configuration.ZOOM.draw(canvasZoom);

}


/**
 * Perform certain actions when a key is pressed
 * @param: e      KeyEvent
 * @case: 1       Use "Breadth First Search" algorithm
 * @case: 2       Use "Dijkstra Search" algorithm   
 * @case: 3       Use "Ashcrow Flight Search" algorithm
 * @case: 4       Use "Ashmanhattan Search" algorithm
 * @case: UP      Increase 
 * @case: DOWN    Decrease
 * @case: RIGHT   Increase size of the zoom visor to the right
 * @case: LEFT    Increase size of the zoom visor to the left
 */
void keyPressed(KeyEvent e) {
  switch(key) {
  case '1':
    configuration.changeAlgorithm(1);
    break;

  case '2':
    configuration.changeAlgorithm(2);
    break;

  case '3':
    configuration.changeAlgorithm(3);
    break;

  case '4':
    configuration.changeAlgorithm(4);
    break;
    
  case 'a':
    ADDS = !ADDS;
    DELETES = false;
    println("add = ", ADDS, " delete = ", DELETES);
    break;

  case 'd':
    DELETES = !DELETES;
    ADDS = false;
    println("add = ", ADDS, " delete = ", DELETES);
    break;  
  }

  switch(e.getKeyCode()) {
  case UP:
    sval += 0.2;
    break;

  case DOWN:
    sval -= 0.2;
    break;

  case RIGHT:
    configuration.reduceSide1();
    configuration.increaseSide2();
    break;

  case LEFT:
    configuration.increaseSide1();
    configuration.reduceSide2();
    break;
  }
}


/**
 * Mouse related functions are used to move the zoom visor
 */
void mousePressed() {
  if (DELETES | ADDS) {
    configuration.pressedZoom();
  } else {
    float sclX = (mouseX - bx)/sval;
    float sclY = (mouseY - by)/sval;
  
    if (sclX > configuration.getSide1().x && sclX < configuration.getSide2().x && sclY > configuration.getSide1().y && sclY < configuration.getSide2().y) {
      locked = true;
      xOffset1 = sclX - configuration.getSide1().x;
      yOffset1 = sclY - configuration.getSide1().y; 
      xOffset2 = sclX - configuration.getSide2().x;
      yOffset2 = sclY - configuration.getSide2().y;
    } else {
      locked = false;
    }
  }
}


void mouseDragged() {
  float sclX = (mouseX - bx)/sval;
  float sclY = (mouseY - by)/sval;

  if (locked) {
    configuration.setSide1(int(sclX-xOffset1), int(sclY-yOffset1));
    configuration.setSide2(int(sclX-xOffset2), int(sclY-yOffset2));
  } else {
    bx += mouseX - pmouseX; 
    by += mouseY - pmouseY;
  }
}


void mouseReleased() {
  if (DELETES) {
    configuration.deleteNode();
  }else if (ADDS) {
    configuration.addNode();
  } else{
    locked = false;
  }
}

public void mouseClicked() {
  configuration.clickZoom();
}
