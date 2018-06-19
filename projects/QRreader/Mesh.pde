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

//Each cell is a block inside the mesh 
public class Cells {
  PVector canvasCoords;
  ArrayList<PVector> coords;
  String pattern = "No pattern available" ;
  int id;

  public Cells(int id, ArrayList<PVector> coords, PVector canvasCoords) {
    this.id = id;
    this.coords = coords;
    this.canvasCoords = canvasCoords;
  }

  /*
  *Check wether the coordinate of a QR is inside a cell or not
  */
  public boolean selected(PVector check) {
    if ((check.x > coords.get(0).x) & (check.x < coords.get(1).x) & (check.y > coords.get(0).y) & (check.y < coords.get(3).y)) return true;
    return false;
  }

  /*
  *Sets the pattern of the cell equal to the decoded value of the QR inside it
  */
  public void setPattern(String decoded) {
    this.pattern = decoded;
  }

  /*
  *Sets the pattern back to its default value
  */
  public void restartPattern() {
    this.pattern = "No pattern";
  }

  public void draw(PGraphics canvas) {
    canvas.stroke(1);
    canvas.noFill();
    canvas.beginShape();
    canvas.vertex(this.coords.get(0).x, this.coords.get(0).y);
    canvas.vertex(this.coords.get(1).x, this.coords.get(1).y);
    canvas.vertex(this.coords.get(2).x, this.coords.get(2).y);
    canvas.vertex(this.coords.get(3).x, this.coords.get(3).y);
    canvas.endShape(CLOSE);
  }
}

//Mesh is a grid made of cells
public class Mesh {
  //zoom step and width variables
  int sclZ, w;
  //step and width variables with standar bases
  int scl, wth;
  PVector[][] grid;
  int nblocks,zoom,canvasW;  
  ArrayList<Cells> cells = new ArrayList();

  public Mesh(int nblocks, int w, int zoom) {
    this.nblocks = nblocks;
    this.zoom = zoom;
    this.canvasW = w;
    uploadMesh(nblocks);
  }

  /*
  *Add new block;
  */    
  public void addBlock(){
    if(scl > nblocks){
      nblocks++;
      uploadMesh(nblocks);
    }    
  }

  /*
  *Delete a block;
  */   
  public void deleteBlock(){
    if(nblocks > 1) {
      nblocks--;
      uploadMesh(nblocks);
    }    
  }

  /*
  *Upload size for each cell;
  */  
  public void uploadMesh(int nblocks){
    this.grid = new PVector[nblocks+1][nblocks+1];
    this.scl = floor(this.canvasW/nblocks);
    this.sclZ = floor(this.canvasW*this.zoom/nblocks);
    this.w = nblocks * sclZ;
    this.wth = nblocks * scl;
    cells = new ArrayList();
    this.create();
  }
  
  /**
   * Create all the "n" blocks with a specific width
   * 0 - 1
   * |   |
   * 3 - 2
  **/
  public void create() {
    int id = 0;
    for (int w = 0; w < this.grid.length; w++) {
      for (int h = 0; h < this.grid.length; h++) {
        int pointx = w*sclZ;
        int pointy = h*sclZ;
        grid[w][h] = new PVector(pointx, pointy);
      }
    }
    for (int i = 0; i < this.nblocks; i++) {
      for (int y = 0; y < this.nblocks; y++) {
        ArrayList<PVector> coords = new ArrayList();
        coords.add(grid[y][i]);
        coords.add(grid[y+1][i]);
        coords.add(grid[y+1][i+1]);
        coords.add(grid[y][i+1]);            
        cells.add(new Cells(id, coords, new PVector(y, i) ));
        id++;
      }
    }
  }

  public void draw(PGraphics canvas){
    canvas.beginDraw();
    for(int i=0; i<=nblocks; i++){
      canvas.line(i*scl,0,i*scl,wth);
    }
    for(int i=0; i<=nblocks; i++){
      canvas.line(0,i*scl,wth,i*scl);
    }
    canvas.endDraw();
  }
  


  /*
  *Scans the image for QR codes and gets the stored values in them
  *Whenever called, the function resets the values of each cell in the grid
  *Prints the enumerated values of the QR to the console
  *If the coordinate of the QR is within the boundaries of a cell, set the pattern of said cell equal to the decoded QR value
  */
  public void checkPattern(PImage im0) {
    /* */
    decodedArr = zxing4p.decodeMultipleQRCodes(true, im0);
    /* */
    for (Cells c : cells) {
      c.restartPattern();
    }

    for (int i = 0; i < decodedArr.length; i++) {
      /* */
      println((i + 1) + ". " + decodedArr[i]);
      for (Cells c : cells) {
        if (c.selected(zxing4p.getPositionMarkers(i)[0])) {
          /* */
          c.setPattern(decodedArr[i]);
          break;
        }
      }
    }
  }

  /*
  *Creates a JSON file that will store the coordinates of the QR codes along with their values
  */
  public void exportGrid(String exportPath) {
    /* */
    JSONObject grid = new JSONObject();  
    int i=0;
    for (Cells c : cells) {
      JSONObject cell = new JSONObject();
      cell.setFloat("x", c.canvasCoords.x);
      cell.setFloat("y", c.canvasCoords.y);
      cell.setString("Pattern", c.pattern);
      grid.setJSONObject(str(i), cell);
      i++;
    }
    println("Grid exported.");
    saveJSONObject(grid, exportPath, "compact");
  }
}