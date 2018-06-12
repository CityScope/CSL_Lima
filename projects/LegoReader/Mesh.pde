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

public class Cells{
  ArrayList<PVector> corners = new ArrayList();
  //Color ownColor;
  Color col;
  color ownColor;
  PVector center;
  int[] counter; 
  int movilAverageRange;
  IntList indexes;
  int id;
  String colorName;
  String acron;
    
  public Cells(int id, ArrayList<PVector> corners){
      this.corners = corners;
      this.id = id;
      setCenter();
      this.ownColor = color(random(0,255),random(0,255),random(0,255));
      this.colorName = "";
      this.acron = "";
      this.settingCounter(config.colorLimits);
      this.indexes = new IntList();
  }
  
  
  /**
  * Set the counter of the Cell to 0
  **/
  public void settingCounter(ArrayList<Color> colorLimits){
    this.counter = new int[colorLimits.size()];
    //set all values to 0
    for(int i = 0; i < counter.length; i++){
      counter[i] = 0;
    }
  }
  
  
  /**
  * Add an amount to the counter in a specfic index
  * Add the index to the list of indexes.
  **/
  public void addingCounter(int index, int amount){
    this.counter[index] += amount;
    this.indexes.append(index);
  }
  
  
  /**
  *Check the size of the movil average
  *Remove the last item if the size is equal to a threshold
  **/
  public void checkMovilAverage(int threshold, int inc){
    if(this.indexes.size() >= threshold){
      counter[this.indexes.get(0)] += inc;
      indexes.remove(0);
    }
  }
  
  
  /**
  * Get the most frequent color  
  **/
  public void movilAverage(){
    int indexMax = 0;
    int maxCount = 0;
    for(int i = 0; i < this.counter.length; i++){
      if (maxCount < this.counter[i]){
        maxCount = this.counter[i];
        indexMax = i;
      }
    }
    this.col = config.colorLimits.get(indexMax);
  }
  **/
   
  /**
  *draw the cells with its own color in the canvas
  *depend of the value of withColor to render its color or none.
  **/
  void draw(PGraphics canvas, boolean withColor){
    canvas.stroke(0,60);
    canvas.fill(ownColor);
    if(!withColor) canvas.noFill();
    canvas.beginShape();
    canvas.vertex(this.corners.get(0).x,this.corners.get(0).y);
    canvas.vertex(this.corners.get(1).x,this.corners.get(1).y);
    canvas.vertex(this.corners.get(2).x,this.corners.get(2).y);
    canvas.vertex(this.corners.get(3).x,this.corners.get(3).y); 
    canvas.endShape(CLOSE);
  }
 
  /**
  *get the center point of the cell
  **/
  public void setCenter(){
    int xSum = 0;
    int ySum = 0;
    for(PVector i : corners){
      xSum += i.x;
      ySum += i.y;
    }
    this.center = new PVector(xSum/corners.size(), ySum/corners.size());
  }
  
  
  /**
  *Process the canvas and get the colors
  *Check the color channels and assign it according to the established ranges 
  **/
  public void getColor(PGraphics canvas, ArrayList<Color> colorLimits){
    canvas.loadPixels();
    
    for(Color colorL : colorLimits){
      colorL.n = 0;
    }
    
    for(int y = int(this.corners.get(0).y); y < int(this.corners.get(2).y); y++){
       for(int x = int(this.corners.get(0).x) ; x < int(this.corners.get(2).x); x++ ){
         int loc = x + y * canvas.width;      
         color c = canvas.pixels[loc];
         for(Color colorL:colorLimits){
           if(c == colorL.getColor()){
             colorL.n ++;
             break;
           }         
         }
      }
    }
    int maximo = 0;
    for(Color colorL:colorLimits){
      if (colorL.n > maximo){
        maximo = colorL.n;
      }
    } 
    
    for(Color colorL:colorLimits){
      if(colorL.n == maximo){
        this.addingCounter(colorL.id, 1);
        this.checkMovilAverage(30, -1);
        movilAverage();
        this.ownColor = col.stdColor;
        this.colorName = col.name;
        this.acron = col.acron;
      } 
    }
  }
  
}


public class Mesh{
  int scl;
  PVector[][] malla;
  ArrayList<Cells> celdas = new ArrayList();
  int nblocks;  
  ArrayList<patternBlock> patternBlocks = new ArrayList<patternBlock>();
  
  public Mesh(int nblocks, int w){
    this.nblocks = nblocks;
    this.scl = w/nblocks;
    this.malla = new PVector[nblocks+1][nblocks+1];
    this.create();
    this.setSizePattern();
  }
  
  public void actualizeString(){
    for(patternBlock p : patternBlocks){
      p.setColorPattern();
    }
  }

  public void actualize(int nblocks, int w){
    this.nblocks = nblocks;
    this.scl = w/nblocks;
    this.malla = new PVector[nblocks+1][nblocks+1];
    celdas = new ArrayList();
    patternBlocks = new ArrayList<patternBlock>();
    this.create();
    this.setSizePattern();
  }
  
  
  /**
  * Create all the "n" blocks with a specific width
  **/
  public void create(){
    int id = 0;
    for(int w = 0; w < this.malla.length; w++){
       for(int h = 0; h < this.malla.length; h++){
        int puntox = w*scl;
        int puntoy = h*scl;
        malla[w][h] = new PVector(puntox,puntoy);
      } 
    }
      for(int i = 0; i < this.nblocks; i++){
        for(int y = 0; y < this.nblocks; y++){
          ArrayList<PVector> cornersTemp = new ArrayList();
          cornersTemp.add(malla[y][i]);
          cornersTemp.add(malla[y][i+1]);
          cornersTemp.add(malla[y+1][i+1]);
          cornersTemp.add(malla[y+1][i]);
          celdas.add(new Cells(id,cornersTemp));
          id++;
        }
    }
  }  
  
  
  /**
  * draw the mesh
  * if withColor is false, only the mesh is rendered
  * if withColor is true, the mesh with its color is rendered
  **/
  void draw(PGraphics canvas, boolean withColor){
    for(Cells i : celdas){
      i.draw(canvas, withColor);
    }
  }
   
   
  /**
  * get colors with specific ranges in the canvas
  **/
  public void getColors(PGraphics canvas, ArrayList<Color> colors){
    for (Cells cell: celdas){
      cell.getColor(canvas, colors);
    }
  }
  
  /**
  **/
  public void setSizePattern(){
    int n = config.nblocks;
    int cont = 0;
    for(int i = 0; i < n*(n-1); i+=n*2){
      for(int j = 0; j < n; j+=2){
        ArrayList<Cells> latent = new ArrayList<Cells>();
        latent.add(celdas.get(j+i));
        latent.add(celdas.get(j+i+1));
        latent.add(celdas.get(j+i+n));
        latent.add(celdas.get(j+i+n+1));
        patternBlocks.add(new patternBlock(cont,latent, j/2, i/(n*2)));
        cont++;
     }
    }
  }
  
  /**
  
  */

  public void drawPattern(PGraphics canvas){
    for(patternBlock pattern : patternBlocks){
      pattern.draw(canvas);
    }
  }
  
  public void checkPattern(){
    for(patternBlock pattern : patternBlocks){
      pattern.checkPattern();
    }
  }
  
}

public class patternBlock{
  ArrayList<Cells> cells = new ArrayList<Cells>();
  ArrayList<PVector> corners = new ArrayList<PVector>();
  ArrayList<BlockGroup> colorPatterns = new ArrayList();
  BlockGroup blockGroup;
  PVector coords = new PVector();
  int id;
  int indexPattern = -1;
  int dif = 7;
  color ownColor = color(random(0,255),random(0,255),random(0,255));  
  boolean pattern = false;
  PVector center = new PVector();
  
  public patternBlock(int id, ArrayList<Cells> cells, int x, int y){
    this.id =id; 
    this.coords.x =  x; this.coords.y = y;
    this.cells = cells;
    this.getCorners();
    this.setColorPattern();
  }
   
  
  public void getCorners(){
    PVector latent1 = cells.get(0).corners.get(0);
    PVector latent2 = cells.get(1).corners.get(3);
    PVector latent3 = cells.get(3).corners.get(2);
    PVector latent4 = cells.get(2).corners.get(1);
    this.corners.add(latent1);
    this.corners.add(latent2);
    this.corners.add(latent3);
    this.corners.add(latent4);
    this.center = cells.get(0).corners.get(2);
    this.dif = int(cells.get(0).corners.get(2).y - cells.get(0).corners.get(0).y);
  }
  
  void draw(PGraphics canvas){
    /*
      for(PVector vector : corners){
        canvas.fill(this.ownColor);
        canvas.ellipse(vector.x,vector.y,20,20);
      }
      */
      
      canvas.fill(0);canvas.stroke(0);
      canvas.textSize(dif/1.5); canvas.textAlign(CENTER, CENTER);
      //canvas.text(str(indexPattern), corners.get(2).x, corners.get(2).y);
      //for(Cells cell: cells){
      //  canvas.text(cell.acron,cell.center.x, cell.center.y);
      //}
      canvas.strokeWeight(1.25); canvas.noFill(); 
      canvas.beginShape();
      canvas.vertex(corners.get(0).x, corners.get(0).y);
      canvas.vertex(corners.get(1).x, corners.get(1).y);
      canvas.vertex(corners.get(2).x, corners.get(2).y);
      canvas.vertex(corners.get(3).x, corners.get(3).y);
      canvas.endShape(CLOSE);
      canvas.rectMode(CENTER); 
      if(indexPattern != -1) canvas.fill(255);
      else canvas.fill(215);
      canvas.rect(center.x,center.y, dif,dif);
      canvas.fill(0);
      canvas.text(str(indexPattern), center.x, center.y);
      
  }

  
  public void setColorPattern(){
    colorPatterns = patternBlocks.groups;

  }
  
  public void checkPattern(){
    this.pattern = false;
    int index = 0;
    for(int i = 0; i < colorPatterns.size(); i++){
      BlockGroup colorPattern = colorPatterns.get(i);
      boolean correct1 = true;
      boolean correct2 = true;
      boolean correct3 = true;
      boolean correct4 = true;        
      
      //check 0123
      for(int j = 0 ; j < colorPattern.blocks.size(); j++){
        Block cPattern = colorPattern.blocks.get(j);
        Cells cCelda = cells.get(j);
        if(cPattern.col != cCelda.col ){
          correct1 = false;
          break;
        }
      }
      
      //check 3210
      for(int j = 0 ; j < colorPattern.blocks.size(); j++){
        Block cPattern = colorPattern.blocks.get(colorPattern.blocks.size()-1-j);
        Cells cCelda = cells.get(j);
        if(cPattern.col != cCelda.col){
          correct2 = false;
          break;
        }
      }

      //check 1302
      if(colorPattern.blocks.size() == 4){
        boolean verify1 =  colorPattern.blocks.get(1).col == (cells.get(0).col);
        boolean verify2 =  colorPattern.blocks.get(3).col == (cells.get(1).col);
        boolean verify3 =  colorPattern.blocks.get(0).col == (cells.get(2).col);
        boolean verify4 =  colorPattern.blocks.get(2).col == (cells.get(3).col);
        if(!(verify1 && verify2 && verify3 && verify4)){ correct3 = false;}
      }
      
      //check 2031
      if(colorPattern.blocks.size() == 4){
        boolean verify1 =  colorPattern.blocks.get(2).equals(cells.get(0).colorName);
        boolean verify2 =  colorPattern.blocks.get(0).equals(cells.get(1).colorName);
        boolean verify3 =  colorPattern.blocks.get(3).equals(cells.get(2).colorName);
        boolean verify4 =  colorPattern.blocks.get(1).equals(cells.get(3).colorName);
        if(!(verify1 && verify2 && verify3 && verify4)){ correct4 = false;}
      }
      
      if(correct1 || correct2 || correct3 || correct4){this.indexPattern = index; this.pattern = true; break;}
      index += 1;
    }
    if(!pattern){this.indexPattern = -1;}
  }
  
}