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

import java.util.Collections;
import java.util.*;
import org.gicentre.utils.stat.*;
import deadpixel.keystone.*;
class Zoom extends PApplet {
  Keystone ks;
  CornerPinSurface keyStone; 
  GraphNode startNode;
  GraphNode endNode;
  PGraphics zoomCanvas;
  PGraphics parentCanvas;
  Boolean add = false;
  Boolean delete = false, n = false;
  int w, h;
  String parentPath = null;
  String path;
  PVector side1, side2;

  /**
   *Create class if it is taken as principal sketch
   *@param  PApplet parent,width, height, canvas
   **/
  public Zoom(int w, int h, PGraphics canvas) {
    this.w = w;
    this.h = h;
    this.parentCanvas = canvas;
  }

  /**
   *Create class if it is an extension of a principal sketch
   *@param  PApplet parent,width, height, canvas
   **/
  public Zoom(PApplet parent, int w, int h, PGraphics canvas) {
    this.w = w;
    this.h = h;
    this.parentCanvas = canvas; 
    parentPath = parent.sketchPath();
    path = parentPath+"/data/calibration.json";
  }

  public void settings() {
    size(this.w, this.h, P3D);
  }

  public void setup() {
    loadJSON(path);
    zoomCanvas = createGraphics(this.width, this.height, P3D);
    ks = new Keystone(this);
    keyStone = ks.createCornerPinSurface(width, height, 20);
  }

  public void draw() {
    this.background(255);
    zoomCanvas.beginDraw();
    zoomCanvas.background(255);
    zoomCanvas.scale(zoomCanvas.width/(side2.x-side1.x));
    zoomCanvas.translate(-side1.x, -side1.y);
    zoomCanvas.strokeWeight(0.15);
    PVector mouseXY = toXYAntiZoom(new PVector(mouseX, mouseY));
    graphos.draw(zoomCanvas, true, int(mouseXY.x), int(mouseXY.y));
    //zoomCanvas.ellipse(mouseXY.x, mouseXY.y, 0.25, 0.25);
    zoomCanvas.endDraw();
    keyStone.render(zoomCanvas);
  }

  void mousePressed() {
    if(delete | add){
      PVector mouseXY = toXYAntiZoom(new PVector(mouseX, mouseY));
      startNode = graphos.gs.getNodeAt(mouseXY.x, mouseXY.y, 0, 0.25f);
    }
  }

  void mouseReleased() {
    if(delete){
      PVector mouseXY = toXYAntiZoom(new PVector(mouseX, mouseY));
      endNode = graphos.gs.getNodeAt(mouseXY.x, mouseXY.y, 0, 0.25f);
      boolean ge = graphos.deleteLane(startNode.id(), endNode.id());
      println(ge);
    }
    if(add){
      boolean ge = graphos.addLane(startNode.id(), endNode.id());
      println(ge);
    }
  }

  void mouseClicked() {
    PVector mouseXY = toXYAntiZoom(new PVector(mouseX, mouseY));
    POI p = graphos.getPOIAt(mouseXY.x, mouseXY.y, 0.25f);
    if (!delete) {
      graphos.linkPoi(p);
      alreadySelected = !alreadySelected;
      if (alreadySelected) {
        graphos.show = !graphos.show;
        alreadySelected = !alreadySelected;
      }
    }
  }
  

  /**
   * @function 'x'  - Add point mode
   * @function 'z'  - Delete point mode 
   * @function 'k'  - Calibrate keystone canvas
   * @function 's'  - Save keystone canvas
   * @function 'l'  - Load keystone canvas
   * @function 'g'  - Load square properties
   */
  void keyPressed() {
    switch(key) { 
    case 'd':
      delete = !delete;
      add = false;
      println("add = ",add, " delete = ", delete);
      break;
    case 'a':
      add = !add;
      delete = false;
      println("add = ",add, " delete = ", delete);
      break;
    case 'k':
      ks.toggleCalibration();
      break;
    case 's':
      if (parentPath != null) {
        ks.save( parentPath + "/data/keystone.xml");
      } else {
        ks.save( sketchPath() +"/data/keystone.xml");
      }  
      break;
    case 'l':
      if (parentPath != null) {
        ks.load( parentPath + "/data/keystone.xml");
      } else {
        ks.load( sketchPath() +"/data/keystone.xml");
      }
      break;
    case 'g':
      saveJSON();
      break;
    case 'n':
      n = !n;
      break;
    }
  }

  /**
   *Map mouse to principal sketch coordinates to create a general POI
   *@param  xy = mouseX, mouseY
   **/
  public PVector toXYAntiZoom(PVector xy) {
    return new PVector(
      map(xy.x, 0, this.w, int(side1.x), int(side2.x)), 
      map(xy.y, 0, this.h, int(side1.y), int(side2.y))
      );
  }

  /**
   *Show the selected area on the principal sketch
   **/
  void drawVisor(PGraphics canvas) {
    canvas.rectMode(CORNER);
    canvas.noFill();
    canvas.stroke(255, 0, 0); 
    canvas.strokeWeight(3);   
    canvas.rect(side1.x, side1.y, side2.x-side1.x, side2.y-side1.y);
  }

  /**
   *Load the two guide points > left and up / right and down 
   **/
  void loadJSON(String path) {
    JSONObject rectParameter = loadJSONObject(path);
    this.side1 = new PVector(rectParameter.getJSONArray("Side1").getFloat(0), rectParameter.getJSONArray("Side1").getFloat(1));
    this.side2 = new PVector(rectParameter.getJSONArray("Side2").getFloat(0), rectParameter.getJSONArray("Side2").getFloat(1));
  } 

  /**
   *Update the two guide points > left and up / right and down 
   **/
  void saveJSON() {
    JSONArray Side1 = new JSONArray();
    Side1.setFloat(0, this.side1.x);
    Side1.setFloat(1, this.side1.y);
    JSONArray Side2 = new JSONArray();
    Side2.setFloat(0, this.side2.x);
    Side2.setFloat(1, this.side2.y);
    JSONObject points = new JSONObject();
    points.setJSONArray("Side1", Side1);
    points.setJSONArray("Side2", Side2);
    saveJSONObject(points, this.path, "compact");
    println("Calibration parameters uploaded");
  }
} 