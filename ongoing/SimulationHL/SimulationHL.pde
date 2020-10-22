import java.util.*;
import org.gicentre.utils.stat.*;
import java.lang.Integer;
import java.lang.Double;
import processing.video.*;
import java.util.Collections;

final String roadsPath = "mirafloresRoad.geojson";
final String poiPath = "muestreoPOI.csv";

PGraphics canvas, canvasOriginal, simulation;
PImage imageWarped;

int nblocks = 6, sizeCanvas = 480;
float inc = 1;

boolean toggle = true, warpMode = false, result = false;

Capture cam;
WarpedPerspective warpedPerspective;
Mesh mesh;
Configuration config;
WarpSurface surface;
Roads roads;
POIs pois;


void setup() {
  fullScreen(P3D);
  colorMode(HSB, 360, 100, 100);

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    canvas = createGraphics(sizeCanvas, sizeCanvas, P3D);
    canvasOriginal = createGraphics(sizeCanvas, sizeCanvas, P3D);
    simulation = createGraphics(1000, 800);

    imageWarped = createImage(sizeCanvas, sizeCanvas, HSB);

    surface = new WarpSurface(this, simulation.width, simulation.height, 2, 2);
    //surface.loadConfig("data/surface.xml");

    config = new Configuration("data/calibrationParameters.json");
    config.loadConfiguration();

    mesh = new Mesh(nblocks, canvas.width);

    warpedPerspective = new WarpedPerspective(config.contour);

    roads = new Roads(roadsPath, simulation);
    pois = new POIs();
    pois.loadCSV(poiPath, roads);

    cam = new Capture(this, 640, 480, cameras[cameras.length - 1]);
    cam.start();
  }
}


void draw() {
  background(0);

  canvasOriginal.beginDraw();
  config.flip(canvasOriginal, cam, true);
  config.SBCorrection(canvasOriginal);
  warpedPerspective.drawWarp(canvasOriginal);
  canvasOriginal.endDraw();
  if (toggle & warpMode) image(canvasOriginal, 0, 0);

  imageWarped = warpedPerspective.applyPerspective(canvasOriginal);
  config.applyFilter(imageWarped);

  canvas.beginDraw();
  canvas.image(imageWarped, 0, 0);
  mesh.getColors(canvas, config.colorLimits);
  mesh.draw(canvas, true);
  canvas.endDraw();
  if (toggle & !warpMode) image(canvas, 0, 0);

  if (!toggle) {
    simulation.beginDraw();
    simulation.background(255);
    roads.draw(simulation, 1);
    roads.readMesh(mesh.cells, canvas);
    simulation.pushStyle();
    simulation.fill(0);
    simulation.textSize(25);
    simulation.textAlign(LEFT);     
    simulation.text("Objective function result:", 100, 650);
    if (!result) simulation.text("No solution found!", 100, 680);
    else simulation.text(String.valueOf(pois.MINIMUM), 100, 680);    
    simulation.popStyle();
    simulation.endDraw();
    surface.draw(simulation);
  }
}


void captureEvent(Capture cam) {
  cam.read();
}


void keyPressed() {
  switch(key) {
  case 'a':
    pois.wrappedOptimization();
    break;

  case 'b':
    pois.resetLanes();
    break;

  case 'c':
    toggle = !toggle;
    break;

  case 'd':
    surface.toggleCalibration();
    break;

  case 'e':
    surface.saveConfig("data/surface.xml");
    break;

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
