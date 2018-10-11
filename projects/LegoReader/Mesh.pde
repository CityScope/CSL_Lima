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
  int id;
  int threshold = 30;
  PVector initPoint;
  int[] counter;
  IntList indexes = new IntList();
  int sclCell;
  Color c = config.colorLimits.get(0);
    
  public Cells(int id,PVector initPoint, int sclCell){
    this.id = id;
    this.initPoint = initPoint;
    this.sclCell = sclCell;
    this.settingCounter(config.colorLimits);
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
    this.c = config.colorLimits.get(indexMax);
  }

  /**
  *Asign a standar color in the range to every pixel in the canvas 
  *Black and white: comparing brightness and saturation in a HSV scale
  *Other Colors: comparing hue in a HSV scale
  *Specific parameters for white and Red
  **/    
  public void applyFilter(PImage img, ArrayList<Color> colorLimits){
    config.restartColors();
    for (int y = int(initPoint.y); y < int(initPoint.y+sclCell); y+=1) {
      for (int x = int(initPoint.x); x < int(initPoint.x+sclCell) ; x+=1) {
        int i = y *img.width + x;
        color actual = img.pixels[i];  
        Color colors = colorLimits.get(0);
        float hue = hue(actual);
        float brightness = brightness(actual);
        float saturation = saturation(actual);
        saturation += config.saturationLevel;
        brightness += config.brightnessLevel;  
        boolean breakLoop = false;
        for(Color colorL: colorLimits){
          if(colorL.name.equals("white")){
            if( ( (saturation < colorL.satMax) & (brightness > colorL.briMin)) | ((saturation < colorL.satMax2) & (hue < colorL.maxHue) & (hue > colorL.hueMin)) ) {
            //if( ( (saturation < 15) & (brightness > 55)) | ((saturation < 50) & (hue < 70) & (hue > 30)) ){
              colors = colorL;
              breakLoop = true;
              break;
            }
          }else if(colorL.name.equals("black")){
            if( brightness < colorL.briMax | ( (brightness < colorL.briMax2 ) & (saturation  < colorL.satMax ) )){
            //if( brightness < 25 | ( (brightness < 40 ) & (saturation  < 15 ) )){  
              colors = colorL;
              breakLoop = true;
              break; 
            }
          }else{
            if((hue < colorL.maxHue)){
              colors = colorL;
              breakLoop = true;
              break;    
            }
          }
        }
        if(!breakLoop) colors = colorLimits.get(2);
        colors.n +=1;
        img.pixels[i] = colors.getColor();
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
      } 
    }     
     
   }

  /**
  *draw the cells with its own color in the canvas
  *depend of the value of withColor to render its color or none.
  **/
  void draw(PGraphics canvas){
    canvas.fill(c.stdColor);
    canvas.stroke(0, 60);
    canvas.strokeWeight(1);
    canvas.rect(initPoint.x, initPoint.y,sclCell, sclCell);
  }  
  
}

public class patternBlock{
  PVector initPoint;
  int scl;
  int id;
  int indexPattern = -1;
  boolean pattern = false;
  ArrayList<Cells> cells = new ArrayList<Cells>();
  ArrayList<BlockGroup> colorPatterns = new ArrayList();
  
  public patternBlock(int id, PVector initPoint, int scl,Patterns patterns){
    this.id =id; 
    this.initPoint = initPoint;
    this.scl = (int) scl;
    this.create();
    this.setColorPattern(patterns);
  }
   
  /**
  *Create cells for a patternBlock
  **/  
  public void create(){
    cells.add(new Cells(0,initPoint,this.scl/2));
    cells.add(new Cells(1,new PVector(initPoint.x+this.scl/2,initPoint.y),this.scl/2));
    cells.add(new Cells(2,new PVector(initPoint.x,initPoint.y+this.scl/2),this.scl/2));
    cells.add(new Cells(3,new PVector(initPoint.x+this.scl/2,initPoint.y+this.scl/2),this.scl/2));
  }

  
  /**
  *Calls applyFilter for each cell
  **/ 
  public void applyFilter(PImage img, ArrayList<Color> colors){
    for(Cells c:cells){
      c.applyFilter(img, colors);
    }
  }  
  
  void draw(PGraphics canvas){
    for(Cells c: cells){
      c.draw(canvas);
    }
    canvas.noFill();
    canvas.strokeWeight(2);
    canvas.rect(initPoint.x, initPoint.y, scl, scl);
    canvas.textAlign(CENTER, CENTER);
    canvas.rectMode(CENTER); 
    if (indexPattern != -1) canvas.fill(255);
    else canvas.fill(215);
    canvas.rect(initPoint.x+this.scl/2, initPoint.y+this.scl/2, scl/2, scl/2);
    canvas.fill(0);
    canvas.text(str(indexPattern), initPoint.x+this.scl/2, initPoint.y+this.scl/2);  
    canvas.rectMode(CORNER);
  }

  /**
  *Draw the lines inside the grid
  **/ 
  public void drawGrid(PGraphics canvas){
    canvas.noFill();
    canvas.strokeWeight(2);
    canvas.rect(initPoint.x, initPoint.y, scl, scl);    
  }
  
  
  public void setColorPattern(Patterns patterns){
    colorPatterns = patterns.patternBlocks.groups;
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
      //check 0123  0132
      if(colorPattern.blocks.size() == 4){
        boolean verify1 =  colorPattern.blocks.get(0).col == (cells.get(0).c);
        boolean verify2 =  colorPattern.blocks.get(1).col == (cells.get(1).c);
        boolean verify3 =  colorPattern.blocks.get(3).col == (cells.get(3).c);
        boolean verify4 =  colorPattern.blocks.get(2).col == (cells.get(2).c);
        if(!(verify1 && verify2 && verify3 && verify4)){ correct1 = false;}
      }
      
      //check 3210 2013
      if(colorPattern.blocks.size() == 4){
        boolean verify1 =  colorPattern.blocks.get(2).col == (cells.get(0).c);
        boolean verify2 =  colorPattern.blocks.get(0).col == (cells.get(1).c);
        boolean verify3 =  colorPattern.blocks.get(1).col == (cells.get(3).c);
        boolean verify4 =  colorPattern.blocks.get(3).col == (cells.get(2).c);
        if(!(verify1 && verify2 && verify3 && verify4)){ correct2 = false;}
      }

      //check 1302  3201
      if(colorPattern.blocks.size() == 4){
        boolean verify1 =  colorPattern.blocks.get(3).col == (cells.get(0).c);
        boolean verify2 =  colorPattern.blocks.get(2).col == (cells.get(1).c);
        boolean verify3 =  colorPattern.blocks.get(0).col == (cells.get(3).c);
        boolean verify4 =  colorPattern.blocks.get(1).col == (cells.get(2).c);
        if(!(verify1 && verify2 && verify3 && verify4)){ correct3 = false;}
      }
      
      //check 2031 1320
      if(colorPattern.blocks.size() == 4){
        boolean verify1 =  colorPattern.blocks.get(1).col ==(cells.get(0).c);
        boolean verify2 =  colorPattern.blocks.get(3).col == (cells.get(1).c);
        boolean verify3 =  colorPattern.blocks.get(2).col == (cells.get(3).c);
        boolean verify4 =  colorPattern.blocks.get(0).col ==(cells.get(2).c);
        if(!(verify1 && verify2 && verify3 && verify4)){ correct4 = false;}
      }    
      if(correct1 || correct2 || correct3 || correct4){this.indexPattern = index; this.pattern = true; break;}
      index += 1;
    }
    if(!pattern){this.indexPattern = -1;}
  }
  
}

public class Mesh{
  int scl;
  PVector[][] grid;
  int nblocks;  
  ArrayList<patternBlock> patternBlocks = new ArrayList<patternBlock>();
  
  public Mesh(int nblocks, int w,Patterns patterns){
    this.nblocks = nblocks;
    this.scl = w/nblocks;
    this.grid = new PVector[nblocks][nblocks];
    this.create(patterns);
  }
  
  
  /**
  * Create all the "n" blocks with a specific width
  **/
  public void create(Patterns patterns){
    int id = 0;
    for(int h = 0; h < this.grid.length; h++) {
      for (int w = 0; w < this.grid.length; w++) {
        float pointx = w * scl;
        float pointy = h * scl;
        patternBlocks.add(new patternBlock(id,new PVector(pointx, pointy),scl,patterns));
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
    for(patternBlock pb: patternBlocks){
      pb.draw(canvas);
    }
  }
  
  public void drawGrid(PGraphics canvas){
    for(patternBlock pb: patternBlocks){
      pb.drawGrid(canvas);
    }    
  }
   
  public void update(int nblocks, int w,Patterns patterns){
    this.nblocks = nblocks;
    this.scl = w/nblocks;
    this.grid = new PVector[nblocks+1][nblocks+1];
    patternBlocks = new ArrayList<patternBlock>();
    this.create(patterns);
  }


  public PImage applyFilter(PGraphics canvas, ArrayList<Color> colors){
    PImage img = canvas.get();
    img.loadPixels();
    for(patternBlock pb :patternBlocks ){
      pb.applyFilter(img,colors);
    }
    img.updatePixels();
    
    return img;
  }
  
  public void checkPattern(){
    for(patternBlock pattern : patternBlocks){
      pattern.checkPattern();
    }
  }
  
}