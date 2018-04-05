/**
** @copyright: Copyright (C) 2018
** @authors:   Vanesa Alcántara
** @version:   2.0
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

public class Building_Plan extends PApplet {
  // building window size
  int w = 800;
  int h = 800;
  // inicial coordinates, zoom and angles of the buildings canvas
  float x0;
  float y0;
  float zoom = 1;
  float angleZ = radians(30);
  float angleX = radians(30);
  Boolean selected = false;
  
  ArrayList<PVector> buildingType;
  ArrayList<Building> buildings;
  PGraphics canvas;
  // zoom and angles of a zoom building
  float angle = -90;
  float centerX;
  float centerY;
  int id = 0;
  Building pickedBuilding;
  Plan plan;

  Building_Plan(PGraphics canvas,int sizeCanvas, int nblocks, ArrayList<patternBlock> patternBlocks) {
    this.canvas = canvas;
    plan = new Plan(sizeCanvas, nblocks, patternBlocks);
  }

  public void settings() {
    size(this.w, this.h, P3D); 
  }

  public void setup() {   
    //smooth();
    colorMode(HSB, 360, 100, 100);
    angle = -90;
    x0 = centerX = this.w/2;
    y0 = centerY = this.h/2;
    canvas = createGraphics(this.w, this.h, P3D);
  }

  public void draw() {
    canvas.beginDraw();
    canvas.background(0, 0, 10);
    canvas.noFill(); 
    canvas.stroke(#818181); 
    canvas.strokeWeight(2);     
    if(!selected ){
      canvas.scale(zoom);
      canvas.translate(x0, y0);
      canvas.rotateX(angleX);
      canvas.rotateZ(angleZ);
      plan.draw(canvas); 
    }else{
      plan.drawZoom(canvas,pickedBuilding.id, centerX, centerY);
    }
    canvas.endDraw();
    image(canvas,0,0);
  }


  public void keyPressed(KeyEvent e) {
    switch(key) {
    case ' ':
      angleX = radians(30);
      zoom = 1;
      x0 = width/2;
      y0 = height/2;

    case '+':
      zoom += 0.3;
      break;

    case '-':
      zoom -= 0.3;
      break;

    case 'e':
      selected = false;
      break;
    }
    switch(e.getKeyCode()) {
    case UP:
      angleX += 0.5;
      break;

    case DOWN:
      angleX -= 0.5;
      break;

    case RIGHT:
      angleZ += 0.5;
      break;

    case LEFT:
      angleZ -= 0.5;
      break;
    }
  }

  public void mouseClicked(){  
    buildings = plan.getBuildings();
    color id = get(mouseX,mouseY);
    for(Building b:buildings){
      if(brightness(id) == brightness(b.select_color)) {
       pickedBuilding = b;
       selected = true;
       break;
      }
    }
  }
   
  public void mouseDragged() {
    x0 = x0 + (mouseX - pmouseX);
    y0 = y0 + (mouseY - pmouseY);
  }
}

//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
public class Plan {
  int sizeCanvas;
  int nblocks;
  int scl;
  float variancia;
  ArrayList<patternBlock> patternBlocks;
  //ArrayList<patternBlock> prevPatterns = new ArrayList();
  ArrayList<Building> buildings = new ArrayList();
  PVector[][] malla;  
  HashMap<Integer, PVector> hm = new HashMap<Integer, PVector>();
  float angle = -90;
  //int c=0;
  

  public Plan(int sizeCanvas, int nblocks, ArrayList<patternBlock> patternBlocks) {
    this.sizeCanvas = sizeCanvas;
    this.scl = (sizeCanvas/nblocks) * 2;
    this.nblocks = nblocks;
    this.malla = new PVector[nblocks+1][nblocks+1];     
    this.patternBlocks = patternBlocks; 
    asignType();
  }

  /*
  * draw basic canvas
  * create every building
  */
  public void draw(PGraphics canvas) {
    canvas.translate(-sizeCanvas/2,-sizeCanvas/2);
    canvas.pushMatrix();
    canvas.fill(#D4D3D3);
    canvas.rect(0,0, sizeCanvas, sizeCanvas);
    create(canvas);
    canvas.popMatrix();
    canvas.noFill();
    createBuildings(canvas);
  }
  
  /*
  * Draw when a building is selected
  */
  public void drawZoom(PGraphics canvas, int id,float centerX,float centerY){
    drawParameter(canvas,id);
    canvas.fill(#FFFFFF,90);canvas.stroke(#FFFFFF);
    canvas.rect((5*width)/6,height/3,200,40,7);
    canvas.fill(#000000);canvas.textSize(20);canvas.textAlign(CENTER);
    canvas.text("Num Floors = "+str(int(buildings.get(id).numFloors)),(5*width)/6 + 100,height/3+25);
    canvas.pushMatrix();
    canvas.fill(#D4D3D3);  
    canvas.translate(centerX,centerY);
    canvas.rotateY(radians(angle));
    canvas.scale(3);
    buildings.get(id).drawZoom(canvas);
    canvas.popMatrix();
    
    this.angle+=1; // speed
    if (this.angle>=360) {
      this.angle=0; // keep in degree
    }
  }
  
  /*
  * Draw parameter for the selected building
  */
  public void drawParameter(PGraphics canvas,int id){
    for(int x=0; x<2;x++){
      for(int y=0; y<2;y++){
        color c = buildings.get(id).assignColor(x, y,2,2);
        canvas.fill(c);canvas.stroke(#000000);canvas.strokeWeight(1);
        canvas.rect(width/3+x*30, height/3+y*30,30,30);
      }
    }
  }

  /*
  * Depending of the patters asign a number of floors
  */
  public void asignType() {
    int a = patternBlocks.get(0).colorPatterns.size();
    for (int i=0; i<a; i++) {
      if (i==0) hm.put(i, new PVector(i+2, 4));
      if (i==1) hm.put(i, new PVector(i+2, 4));
      if (i==2) hm.put(i, new PVector(i+2, 4));
      if (i==3) hm.put(i, new PVector(i+2, 3));
      if (i==4) hm.put(i, new PVector(i+2, 4));
      if (i==5) hm.put(i, new PVector(i+2, 4));
      if (i==6) hm.put(i, new PVector(i+2, 4));
    }
  }

  /*
  * call every patternBlock and draws it
  */
  public void create(PGraphics canvas) {
    for (patternBlock p : patternBlocks) {
      p.draw(canvas,false);
    }
  }

  /*
  * If the block has a pattern draw its design building
  */
  public void createBuildings(PGraphics canvas) {
    buildings.clear();
    int c = 0;
      for (patternBlock p : patternBlocks) {
        if (p.indexPattern != -1) {
          PVector a = hm.get(p.indexPattern);
          Building b = new Building(c,a.x, a.y, scl, p.corners.get(0), p.cells); 
          buildings.add(b);
          canvas.pushMatrix();
          int variancia = int(scl/(a.y * 2 - 0.5));
          canvas.translate(variancia, variancia, variancia);   
          b.draw(canvas);
          canvas.popMatrix();
          c++;
        }
      }
  }  
  
  /*
  * Get building size
  */
  public int buildingsSize(){
    return buildings.size();
  }
  
  /*
  * Get a building array
  */
  public ArrayList<Building> getBuildings(){
    return buildings;
  }
}

public class Building {
  float roomSide;
  float numFloors;
  int scl;
  PVector loc;
  ArrayList<Cells> cells;
  int id;
  color select_color;

  Building(int id,float numFloors, float roomSide, int scl, PVector loc, ArrayList<Cells> cells) {
    this.id = id;
    this.select_color = setColor();
    this.roomSide = roomSide;
    this.numFloors = numFloors; 
    this.scl = scl;
    this.loc = new PVector(loc.x, 0, loc.y);
    this.cells = cells;
  }

  /*
  * Asign a color to each building in order to sepate them while clicking
  */
  public color setColor(){
    return color(0,0,80-(this.id));
  }

  /*
  * Draw each building considering its floor number and room number per side
  */
  public void draw(PGraphics canvas) {
    noFill();
    for (int y=0; y<numFloors; y++) {
      for (int x=0; x<roomSide; x++ ) {
        for (int z=0; z<roomSide; z++) {
          float ratio = scl/roomSide;
          if ( x == 0 | x == roomSide - 1| z == 0 | z == roomSide - 1) {
            //ClassRoom(b,pos.x + x*newR,  pos.z + z*newR,pos.y+ floorNumber *newR,newR,rooms.get(x+z))
            PVector pos = new PVector(loc.x + x*ratio, loc.z + z*ratio, loc.y+ y *ratio);
            canvas.pushMatrix();
            canvas.fill(this.select_color);
            if (y == numFloors-1) canvas.fill(assignColor(x, z, (int)roomSide, (int)roomSide));            
            canvas.translate(pos.x, pos.y, pos.z);
            canvas.box(ratio);
            canvas.popMatrix();
          }
        }
      }
    }
  }

  /*
  * Draw a single building when it is selected
  */
  public void drawZoom(PGraphics canvas){
    for(int y=0; y<numFloors; y++){
      for(int x=-floor(roomSide/2); x<roomSide/2;x++){
        for(int z=-floor(roomSide/2);z<roomSide/2;z++){
          float ratio = scl/roomSide;
          if( x == -floor(roomSide/2) | x == roomSide/2 - 1| z == -floor(roomSide/2) | z == roomSide/2 - 1){
            PVector pos = new PVector(x*ratio,y *ratio,z*ratio);
            canvas.pushMatrix();
            canvas.fill(this.select_color);
            if (y == 0) canvas.fill(assignColor(x+floor(roomSide/2), z+floor(roomSide/2), (int)roomSide, (int)roomSide));
            canvas.translate(pos.x,pos.y,pos.z);
            canvas.box(ratio);
            canvas.popMatrix();            
          }
        }
      }
    }
  }
  
  /*
  * Asign each cube a color depending its position
  * corners woth the parameter and the other with the color to select it
  */
  public color assignColor(int x, int y, int limitX, int limitY) {
    color col = this.select_color;
    if (x == 0 && y == 0) col = cells.get(0).ownColor;
    if (x == limitX-1 && y == 0) col = cells.get(1).ownColor;
    if (x == limitX-1 && y == limitY-1) col = cells.get(3).ownColor;
    if (x == 0 && y == limitY-1) col = cells.get(2).ownColor;
    return col;
  }
}