/**
 ** @copyright: Copyright (C) 2018
 ** @authors:   Vanesa Alcántara & Jesús García
 ** @version:   1.0 
 ** @legal :
 This file is part of QRreader.
 
 QRreader is free software: you can redistribute it and/or modify
 it under the terms of the GNU Affero General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 QRreader is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU Affero General Public License for more details.
 
 You should have received a copy of the GNU Affero General Public License
 along with QReader.  If not, see <http://www.gnu.org/licenses/>.
 **/

/*
* Import ZXING library created by  Rolf van Gelder 
* Available for processing:(http://cagewebdev.com/zxing4processing-processing-library/)
*/
 
//Import the requiered libraries: OpenCV, Zxing
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import java.util.Collections;

import com.cage.zxing4p3.*;
import processing.video.*;

//Initialize the variables
ZXING4P zxing4p;
WarpPerspective warpPerspective;
Capture video;
OpenCV opencv;

Mesh mesh;
QR qr;

int nblocks = 16;
int w = 700;
PImage im0;
PGraphics canvas;
PGraphics meshCanvas;
String path = "data/points.json";
String exportPath = "data/grid.json";
String decodedText  = "";
String decodedArr[] = null;
String s = "Press 's' to save parameters.", space = "Press ' ' to print the decoded QR values.", e = "Press 'e' to export the QR values and their coordinates.";
boolean decoded = false;

void settings() {
  size(w*2, w);
}

void setup() {
  String[] cameras = Capture.list(); 
  String cameraSelected = cameras[0];
  for(String cam : cameras){
    println(cam);
    String[] name = cam.split(" ")[0].split("=");
    if(!name.equals("FaceTime")){
      cameraSelected = cam;
      break;
    }
  }
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    im0 = createImage(w*3, w*3, RGB); 
    canvas = createGraphics(w, w);
    meshCanvas = createGraphics(w, w);
    qr = new QR(path);
    zxing4p = new ZXING4P();
    zxing4p.version();
    warpPerspective = new WarpPerspective(qr.contour,w,w);
    mesh = new Mesh(nblocks,w,3);
    video = new Capture(this, 1280, 720, cameraSelected);
    video.start();
    opencv = new OpenCV(this, video);
  }
} 


void draw() {
  canvas.beginDraw();
  warpPerspective.flip(canvas, video, true);  
  warpPerspective.draw(canvas);
  canvas.endDraw(); 
  fill(0);
  rect(0, 720, 600, 180);
  textSize(20);
  fill(255);
  text(s, 310, 770);
  text(space, 250, 790);
  text(e, 200, 810);
  image(canvas,0,0);
  opencv.loadImage(video);
  opencv.toPImage(warpPerspective.warpPerspective(w*3, w * 3 , opencv), im0);
  meshCanvas.beginDraw();
  meshCanvas.background(0);
  meshCanvas.image(im0, 0, 0, mesh.wth, mesh.wth);
  mesh.draw(meshCanvas);
  meshCanvas.endDraw();
  image(meshCanvas,canvas.width,0);
}

void keyPressed(KeyEvent e) {
  //User interaction
  switch(key) {
  case ' ':
    //Decode the QR and print the values to the console
    qr.decode(mesh, im0);
    break;

  case 's':
    //After relocating the points, save their new coordinates for future program executions
    qr.saveData();
    break;

  case 'e':
    //Decode the QR, print their values to the console and export these along with their coordinates to a JSON file
    qr.decode(mesh, im0);
    mesh.exportGrid(exportPath); 
    break; 
  }
  
  switch(e.getKeyCode()){
    case UP:
    mesh.addBlock();
    break;
    
    case DOWN:
    mesh.deleteBlock();
    break;
    
  }
}

//Mouse interactions allow relocating the points
void mousePressed() {
  warpPerspective.selected(mouseX, mouseY, 5);
}

void mouseReleased() {
  warpPerspective.unSelect();
}

void mouseDragged() {
  warpPerspective.move(mouseX, mouseY);
}

void captureEvent(Capture video) {
  video.read();
}