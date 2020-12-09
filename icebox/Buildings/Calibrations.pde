/**
** @copyright: Copyright (C) 2018
** @authors:   Javier Zárate & Vanesa Alcántara
** @version:   1.0
** @legal:
This file is part of Building.

    Building is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Building is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with Building.  If not, see <http://www.gnu.org/licenses/>.
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
Configuration config;
Mesh mesh;
PatternBlocks patternBlocks;

public class Calibration extends PApplet {
  PGraphics canvas;
  PGraphics canvasOriginal;
  PGraphics canvasColor;
  PGraphics canvasPattern;
  PGraphics plano_e; 

  int sizeCanvas = 480; 
  PImage colorImage;
  PImage imageWrapped;
  PImage capture;  
  ArrayList<PVector> posibles = new ArrayList();
  ArrayList<PVector> calibrationPoints = new ArrayList();

  Capture cam;
  OpenCV opencv;
  WrappedPerspective wrappedPerspective;
  Patterns patterns;
  Building_Plan plan;
  
  public void settings() {
    size(sizeCanvas, sizeCanvas);
  }

  public void setup() {
    colorMode(HSB, 360, 100, 100);
    String[] cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      canvas = createGraphics(sizeCanvas, sizeCanvas);
      canvasOriginal = createGraphics(sizeCanvas, sizeCanvas);
      canvasColor = createGraphics(sizeCanvas, sizeCanvas);
      colorImage = createImage(sizeCanvas, sizeCanvas, HSB);
      imageWrapped = createImage(sizeCanvas, sizeCanvas, HSB);
      config = new Configuration(sizeCanvas,"data/calibrationParameters.json");

      config.loadConfiguration();
      mesh = new Mesh(config.nblocks, canvas.width);

      wrappedPerspective = new WrappedPerspective(config.contour);

      //Capture width and height must match a supported camera resolution
      //This does not work: cam = new Capture(this, canvas.width, canvas.height, cameras[0]);
      cam = new Capture(this, 640, 480, cameras[cameras.length-1]);
      cam.start();
      
      
      String[] pattern = {"Patterns"};
      patterns = new Patterns(canvasPattern, 480,350);
      PApplet.runSketch(pattern, patterns);
      
      String[] pled = {"Building plan"};
      plan = new Building_Plan(plano_e,sizeCanvas, config.nblocks, mesh.patternBlocks);
      PApplet.runSketch(pled, plan);  
      

      opencv = new OpenCV(this, cam);
      opencv.useColor(HSB);
      frameRate(5);
    }
  }

  public void draw() {
    canvasOriginal.beginDraw();
    config.flip(canvasOriginal, cam, true);
    config.SBCorrection(canvasOriginal, config.brightnessLevel, config.saturationLevel);
    canvasOriginal.endDraw();

    //Filter colors with specific ranges
    config.applyFilter(canvasOriginal, colorImage);

    //canvas with the color processing and wrapped image
    colorImage.updatePixels();
    opencv.loadImage(colorImage);
    opencv.toPImage(wrappedPerspective.warpPerspective(sizeCanvas - config.resizeCanvas.get(0), sizeCanvas - config.resizeCanvas.get(1), opencv), imageWrapped);

    canvas.beginDraw();
    canvas.background(255);
    imageWrapped.resize(canvas.width - config.resizeCanvas.get(0), canvas.height - config.resizeCanvas.get(1));
    canvas.image(imageWrapped, 0, 0);
    mesh.getColors(canvas, config.colorLimits);
    canvas.endDraw();

    mesh.drawBlockReader(canvasColor);
    image(canvasColor, 0, 0);
  }

  void captureEvent(Capture cam) {
    cam.read();
  }
  
  void keyPressed(KeyEvent e) {
    switch(key){
     case 's':
       config.safeConfiguration(config.colorLimits);
       break;
    }
  }
}
