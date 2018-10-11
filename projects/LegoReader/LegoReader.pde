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

import processing.video.*;
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import java.util.Collections;

PGraphics canvas;
PGraphics canvasOriginal;
PGraphics canvasColor;
PGraphics legendColor;
PGraphics grayScale;
PGraphics canvasPattern;


int sizeCanvas = 480; 
PImage colorImage;
PImage imageWrapped;
PImage capture;
float inc = 1;

Boolean refresh = false, flipped = true, done = false ;
ArrayList<PVector> posibles = new ArrayList();
ArrayList<PVector> calibrationPoints = new ArrayList();

Capture cam;
OpenCV opencv;
Corners corners;
WarpedPerspective warpedPerspective;
ColorRange colorRange;
Mesh mesh;
BlockReader blockReader;
Configuration config = new Configuration(sizeCanvas, "data/calibrationParameters.json");
Patterns patterns;

void settings(){
  size(sizeCanvas*2, sizeCanvas);
}


void setup() {
  colorMode(HSB,360,100,100);
  String[] cameras = Capture.list();
  print(cameras.length);
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    canvas = createGraphics(sizeCanvas,sizeCanvas);
    canvasOriginal = createGraphics(sizeCanvas, sizeCanvas);
    grayScale = createGraphics(sizeCanvas, sizeCanvas);
    colorImage = createImage(sizeCanvas, sizeCanvas, HSB);
    imageWrapped = createImage(sizeCanvas, sizeCanvas, HSB);
    
    corners = new Corners(grayScale);

    config.loadConfiguration();
    String[] pattern = {"Patterns"};
    patterns = new Patterns(canvasPattern, config);
    PApplet.runSketch(pattern, patterns);
    
    mesh = new Mesh(config.nblocks/2, canvas.width,patterns);

    warpedPerspective = new WarpedPerspective(config.contour);
    
    cam = new Capture(this,canvas.width, canvas.height, cameras[0]);
    cam.start();

    String[] args = {"Animation"};
    String[] name = {"color"};
    
    blockReader = new BlockReader(sizeCanvas,sizeCanvas);
    colorRange = new ColorRange(config.colorLimits, 600, 100);
    
    PApplet.runSketch(name,colorRange);
    PApplet.runSketch(args, blockReader);
    
    opencv = new OpenCV(this, cam);
    opencv.useColor(HSB);
    frameRate(5);
  }
}


void draw() {
  if(!done){
    corners.applyHCD(refresh, warpedPerspective);
    
    canvasOriginal.beginDraw();
    config.flip(canvasOriginal, cam, flipped);
    warpedPerspective.draw(canvasOriginal);
    config.SBCorrection(canvasOriginal,config.brightnessLevel,config.saturationLevel);
    corners.drawCalibrationPoints(canvasOriginal, refresh);
  
    canvasOriginal.endDraw();
    image(canvasOriginal, 0, 0);
    

    //canvas with the color processing and wrapped image
    colorImage.updatePixels();
    opencv.loadImage(canvasOriginal.get());
    opencv.toPImage(warpedPerspective.warpPerspective(sizeCanvas - config.resizeCanvas.get(0), sizeCanvas - config.resizeCanvas.get(1),opencv), imageWrapped);
    
    canvas.beginDraw();
    canvas.background(255);
    imageWrapped.resize(canvas.width - config.resizeCanvas.get(0), canvas.height - config.resizeCanvas.get(1));
    canvas.image(imageWrapped, 0, 0);
    colorImage = mesh.applyFilter(canvas,config.colorLimits);
    canvas.image(colorImage,0,0);
    mesh.drawGrid(canvas);
    canvas.endDraw();
    image(canvas, canvas.width, 0);
  }
}


void keyPressed(KeyEvent e) {
  switch(e.getKeyCode()){
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
   
   switch(key){
     case 's':
     config.saveConfiguration(colorRange.selectAll(),patterns);
     break;
     
     case 'e':
     config.exportGrid(mesh.patternBlocks,patterns);
     break;
     
     case 'r':
     print(true);
     refresh = !refresh;
     break;

     //flips the image in the canvas
     case 'f':
     flipped = !flipped;
     config.flip(canvasOriginal, cam, flipped);
     break;

     case 'd':
     done = ! done;
     break;

     case '+':
     config.nblocks += 4;
     mesh.update(config.nblocks, canvas.width,patterns);
     config.updateSizeCanvas(canvas.width % config.nblocks,canvas.height % config.nblocks);
     break;
     
     case '-':
     config.nblocks-=4;
     mesh.update(config.nblocks, canvas.width,patterns);
     config.updateSizeCanvas(canvas.width % config.nblocks,canvas.height % config.nblocks);
     break;    
       
   }

}

void captureEvent(Capture cam){
  cam.read();
}


void mousePressed(){
  warpedPerspective.selected(mouseX,mouseY,5);
}

void mouseReleased(){
  warpedPerspective.unSelect();
}

void mouseDragged(){
  warpedPerspective.move(mouseX,mouseY);
}