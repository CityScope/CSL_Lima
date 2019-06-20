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

int nblocks = 6;
int sizeCanvas = 480;
PImage colorImage;
PImage imageWrapped;
float inc = 1;

boolean warpMode = false;

Capture cam;
OpenCV opencv;
WarpedPerspective warpedPerspective;
Mesh mesh;
Configuration config = new Configuration("data/calibrationParameters.json");
Simulation simulation;


void settings() {
  size(sizeCanvas, sizeCanvas);
}


void setup() {
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

    config.loadConfiguration();

    mesh = new Mesh(nblocks, canvas.width);

    warpedPerspective = new WarpedPerspective(config.contour);

    cam = new Capture(this, 640, 480, cameras[0]);
    cam.start();

    opencv = new OpenCV(this, cam);
    opencv.useColor(HSB);

    String[] argsS = {"Simulation"};
    simulation = new Simulation(1000, 800);
    PApplet.runSketch(argsS, simulation);
  }
}


void draw() {
  canvasOriginal.beginDraw();
  config.flip(canvasOriginal, cam, true);
  config.SBCorrection(canvasOriginal);
  warpedPerspective.drawWarp(canvasOriginal);
  canvasOriginal.endDraw();
  if (warpMode) image(canvasOriginal, 0, 0);

  //Filter colors with specific ranges
  config.applyFilter(canvasOriginal, colorImage);

  //canvas with the color processing and wrapped image
  colorImage.updatePixels();
  opencv.loadImage(colorImage);
  opencv.toPImage(warpedPerspective.warpPerspective(sizeCanvas, sizeCanvas), imageWrapped);

  canvas.beginDraw();
  canvas.image(imageWrapped, 0, 0);
  mesh.getColors(canvas, config.colorLimits);
  mesh.draw(canvas, true);
  canvas.endDraw();
  if (!warpMode) image(canvas, 0, 0);
}


void captureEvent(Capture cam) {
  cam.read();
}


void keyPressed() {
  switch(key) {
  case 'w':
    warpMode = !warpMode;
    break;
  }
}


/**
 * Calls the select method of warpedPerspective
 */
void mousePressed() {
  if (warpMode) warpedPerspective.select(mouseX, mouseY, 5);
}


/**
 * Calls the move method of warpedPerspective
 */
void mouseDragged() {
  if (warpMode) warpedPerspective.move(mouseX, mouseY);
}


/**
 * Calls the unselect method of warpedPerspective
 */
void mouseReleased() {
  if (warpMode) warpedPerspective.unselect();
}
