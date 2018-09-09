/**
 ** @copyright: Copyright (C) 2018
 ** @authors:   Vanesa Alcántara & Jesús García
 ** @version:   1.0 
 ** @legal :
 This file is part of HumanitarianModel.
 
 HumanitarianModel is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 HumanitarianModel is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License
 along with HumanitarianModel.  If not, see <http://www.gnu.org/licenses/>.
 **/

/**
 *Import Path_Finder library created by Peter Lager 
 *Available for processing:(http://www.lagers.org.uk/pfind/download.html)
 **/

/**
 *Class variables
 **/
Grapho graphos;
Zoom zoom;

/**
 *Graphic and file variables
 **/
PGraphics canvas;
PGraphics canvasSimulation;
String roadPath = "clean_vias.geojson";
String poiPath = "SH.geojson";

/**
 *Zoom variables
 **/
boolean activateZoom = true;
boolean locked = false, delete = false, alreadySelected = false;
float xOffset1 = 0.0; 
float yOffset1 = 0.0; 
float xOffset2 = 0.0; 
float yOffset2 = 0.0;   

/**
 *Transformation variables
 **/
float sval = 1;
float bx = 0;
float by = 0;

public void settings() {
  fullScreen(P3D);
}

public void setup() { 
  canvas = createGraphics(this.width, this.height,P3D);
  graphos = new Grapho(roadPath, poiPath);
  if (activateZoom) {
    zoom = new Zoom(this, this.height/2, this.height/2, canvasSimulation);
    String[] zoomName = {"Zoom Map"};
    PApplet.runSketch(zoomName, zoom);
  }
}

public void draw() {
  canvas.beginDraw();
  canvas.strokeWeight(0.30);
  graphos.draw(canvas, false, mouseX, mouseY); 
  if (activateZoom) zoom.drawVisor(canvas);
  canvas.endDraw();
  image(canvas, 0, 0);
}

void keyPressed(KeyEvent e) {
  switch(key) {
    //BFS
  case '1':
    graphos.algorithm = 1;
    graphos.pathFinder = graphos.makePathFinder(graphos.gs, graphos.algorithm);
    graphos.usePathFinder(graphos.pathFinder);
    break;
    //DIJKSTRA
  case '2':
    graphos.algorithm = 2;
    graphos.pathFinder = graphos.makePathFinder(graphos.gs, graphos.algorithm);
    graphos.usePathFinder(graphos.pathFinder);
    break;
    //ASHCROWFLIGHT
  case '3':
    graphos.algorithm = 3;
    graphos.pathFinder = graphos.makePathFinder(graphos.gs, graphos.algorithm);
    graphos.usePathFinder(graphos.pathFinder);
    break;
    //ASHMANHATTAN
  case '4':
    graphos.algorithm = 4;
    graphos.pathFinder = graphos.makePathFinder(graphos.gs, graphos.algorithm);
    graphos.usePathFinder(graphos.pathFinder);
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
    zoom.side1.x -= 1;
    zoom.side2.x += 1;
    zoom.side1.y -= 1;
    zoom.side2.y += 1;
    break;

  case LEFT:
    zoom.side1.x += 1;
    zoom.side2.x -= 1;
    zoom.side1.y += 1;
    zoom.side2.y -= 1;
    break;
  }
}

/**
  *Mouse related functions are used to move the zoom
  **/
void mousePressed() {
  float sclX = (this.mouseX-bx)/sval;
  float sclY = (this.mouseY-by)/sval;
  if (sclX>zoom.side1.x && sclX<zoom.side2.x && sclY> zoom.side1.y && sclY<zoom.side2.y) {
    locked = true;
    xOffset1 = sclX - zoom.side1.x;
    yOffset1 = sclY - zoom.side1.y; 
    xOffset2 = sclX - zoom.side2.x;
    yOffset2 = sclY - zoom.side2.y;
  } else {
    locked = false;
  }
}

void mouseDragged() {
  float sclX = (this.mouseX-bx)/sval;
  float sclY = (this.mouseY-by)/sval;
  if (locked) {
    zoom.side1.x = int(sclX-xOffset1);
    zoom.side1.y = int(sclY-yOffset1);
    zoom.side2.x = int(sclX-xOffset2);
    zoom.side2.y = int(sclY-yOffset2);
  } else {
    bx += this.mouseX-this.pmouseX; 
    by += this.mouseY-this.pmouseY;
  }
}

void mouseReleased() {
  locked = false;
}