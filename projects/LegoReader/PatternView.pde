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

public class Patterns extends PApplet{
  int w;
  int h;
  PGraphics canvasPattern;
  final int blockSize = 20;
  Configuration config;

  public Patterns(PGraphics canvasPattern, Configuration config){
    this.w = 480;
    this.h = blockSize * 4 * ceil(float(config.patterns.size())/3);
    this.canvasPattern = canvasPattern;
    this.config = config;
  }
  
  public void settings(){
    size(this.w,this.h);
  }

  public void setup(){
    colorMode(HSB,360,100,100);
    canvasPattern = createGraphics(this.w, this.h);
    patternBlocks = new PatternBlocks(canvasPattern, this.config, blockSize);
    patternBlocks.getColorString();
  }
  
  public void draw(){
    background(255);
    canvasPattern.beginDraw();
    canvasPattern.background(255);
    patternBlocks.draw(canvasPattern);
    canvasPattern.endDraw();
    image(canvasPattern, 0, 0);
  }
  
  public void mouseClicked(){
    patternBlocks.selected(mouseX,mouseY);
  }
  
  
  public void keyPressed(KeyEvent e){
   switch(e.getKeyCode()){
     case UP:     
     if(config.possiblePatterns()){
       if((config.patterns.size() % 3 == 0) ) {
         this.h += blockSize * 4;
         surface.setSize(this.w, this.h); 
         canvasPattern.setSize(width, height);
       }
       patternBlocks.createPattern(canvasPattern);
     }
     break;
     
     case DOWN:     
     if(config.patterns.size() > 1){
       if( ( (config.patterns.size()-1) % 3 == 0 )){
         this.h -= blockSize * 4;
         surface.setSize(this.w, this.h );
         canvasPattern.setSize(width, height);
       }
     patternBlocks.deletePattern(canvasPattern);
     }
     break;
     
   }
  }
    
  
}

  public class Block{
    ArrayList<PVector> corners = new ArrayList<PVector>();
    Color col;
    int id;
    int colorIndex = 0;
    public Block(int id, ArrayList<PVector> corners, String colorName){
      this.id = id;
      this.corners = corners;
      this.getColorFromName(colorName);  
    }

    /*
    * Assign a Color to a block depending of its name.
    */     
    void getColorFromName(String colorName){
      for(Color col : config.colorLimits){
        if(col.name.equals(colorName)){
          this.col = col;
          this.colorIndex = col.id;
        }
      }
    }
    
    void draw(PGraphics canvas){
      canvas.stroke(0);
      canvas.fill(col.stdColor);
      canvas.beginShape();
      canvas.vertex(this.corners.get(0).x,this.corners.get(0).y);
      canvas.vertex(this.corners.get(1).x,this.corners.get(1).y);
      canvas.vertex(this.corners.get(2).x,this.corners.get(2).y);
      canvas.vertex(this.corners.get(3).x,this.corners.get(3).y);
      canvas.endShape(CLOSE);
    }

    /*
    * Change the color to the follow in the main list.
    */     
    void selected(int x, int y){
      PVector ul = corners.get(0);
      PVector ur = corners.get(1);
      PVector br = corners.get(2);
      PVector bl = corners.get(3);
      if((x > ul.x) && (x < ur.x) && (y > ul.y) && (y < bl.y) ){
        if(colorIndex == config.colorLimits.size()-1){
          colorIndex = 0;
        }else{
          this.colorIndex +=1;
        }
        this.col = config.colorLimits.get(colorIndex);
        patternBlocks.getColorString();
      }
    }
  }


public class BlockGroup{
    ArrayList<Block> blocks = new ArrayList<Block>();
    int id;
    int size;
    PVector cornerUR;
    PVector cornerBL;
    public BlockGroup(int id, ArrayList<Block> blocks){
      this.blocks = blocks;
      this.id = id;
      cornerUR = blocks.get(1).corners.get(1);
      cornerBL = blocks.get(2).corners.get(3);
    }
    
    void draw(PGraphics canvas){
      canvas.stroke(0);
      canvas.fill(0);
      canvas.textSize(10);
      canvas.text("id: " + str(id), this.cornerUR.x + 10, cornerUR.y + 10);
      int spaceText = 0;;
      for(Block block : blocks){
        block.draw(canvas);
        canvas.fill(0);
        canvas.textSize(8);
        canvas.text(block.col.name + " ",this.cornerBL.x + spaceText, cornerBL.y + 10 );
        spaceText += 30;
      }
    }

    /*
    * Change the color of the selected block to the follow in the main list.
    */     
   public void selected(int x, int y){
     for (Block b : this.blocks){
       b.selected(x,y);
     }
   }
  }
  
  
  public class PatternBlocks{
    ArrayList<BlockGroup> groups = new ArrayList<BlockGroup>();
    ArrayList<ArrayList<String>> patternString = new ArrayList<ArrayList<String>>();
    ArrayList<ArrayList<String>> patternConf = new ArrayList<ArrayList<String>>();
    PGraphics canvas;
    final int sizeBlock;
    Configuration config;
    
    public PatternBlocks(PGraphics canvas, Configuration config, int sizeBlock){
      this.canvas = canvas;
      this.config = config;
      this.sizeBlock = sizeBlock;
      this.createPallet(canvas);
    }

    /*
    * Upload the patterns array so it can be safe on the JSONfile.
    */
    public void getColorString(){
      this.patternString = new ArrayList<ArrayList<String>>();
      for(BlockGroup blockGroup : groups){
        ArrayList<String> patternLatent = new ArrayList<String>();
        for (Block block : blockGroup.blocks){
          patternLatent.add(block.col.name);
        }
        this.patternString.add(patternLatent);
      }
    }
    
    /*
    * Creates a new pattern and assign it an standar W-W-W-W parameter
    */
    public void createPattern(PGraphics canvas){
      ArrayList<String> pred = new ArrayList();
      pred.add(this.config.colorLimits.get(0).name);
      pred.add(this.config.colorLimits.get(0).name);
      pred.add(this.config.colorLimits.get(0).name);
      pred.add(this.config.colorLimits.get(0).name);
      this.config.patterns.add(pred);
      patternString.add(pred);
      this.createPallet(canvas);
    }   

    /*
    * Delete the last parameter in the parameters list
    */    
    public void deletePattern(PGraphics canvas){
      this.config.patterns.remove(this.config.patterns.size()-1);
      patternString.remove(patternString.size()-1);
      this.createPallet(canvas);
    } 
    
    void draw(PGraphics canvas){
      for(BlockGroup blockGroup : groups){
        blockGroup.draw(canvas);
      }
    }
    
   /*
   * Change the color of the selected block inside an specific parameter
   */
   public void selected(int x, int y){
     for (BlockGroup b : this.groups){
       b.selected(x,y);
     }
     this.config.patterns = this.patternString;
     mesh.updateString();
   }
   
   /*
   * Creates blocks, blockGroups and patterns
   */
   public void createPallet(PGraphics canvas){
     this.groups.clear();
     this.patternConf = this.config.patterns;
     int xStep = 3;
     int sizeT = floor(float(canvas.width)/float(xStep));
     int yStep = ceil(float(patternConf.size())/float(xStep));
     PVector initP = new PVector(10,sizeBlock);     
     int index= 0;
     
     for(int j = 0; j < yStep; j++){
       for(int i = 0; i < xStep; i ++){
         if(index < patternConf.size()){
           ArrayList<String> colorNames = config.patterns.get(index);           
           ArrayList<Block> bloques = new ArrayList<Block>();
           
           ArrayList<PVector> corners = new ArrayList<PVector>();
           corners.add(new PVector(initP.x,initP.y));
           corners.add(new PVector(initP.x+sizeBlock,initP.y));
           corners.add(new PVector(initP.x+sizeBlock,initP.y+sizeBlock));
           corners.add(new PVector(initP.x,initP.y+sizeBlock));
           Block latent1 = new Block(1,corners, colorNames.get(0));
           
           ArrayList<PVector> corners2 = new ArrayList<PVector>();
           corners2.add(new PVector(initP.x+sizeBlock,initP.y));
           corners2.add(new PVector(initP.x+sizeBlock*2,initP.y));
           corners2.add(new PVector(initP.x+sizeBlock*2,initP.y+sizeBlock));
           corners2.add(new PVector(initP.x+sizeBlock,initP.y+sizeBlock));
           Block latent2 = new Block(1,corners2,colorNames.get(1));
           
           ArrayList<PVector> corners3 = new ArrayList<PVector>();
           corners3.add(new PVector(initP.x,initP.y+sizeBlock));
           corners3.add(new PVector(initP.x+sizeBlock,initP.y+sizeBlock));
           corners3.add(new PVector(initP.x+sizeBlock,initP.y+sizeBlock*2));
           corners3.add(new PVector(initP.x,initP.y+sizeBlock*2));
           Block latent3 = new Block(1,corners3, colorNames.get(2));
        
           ArrayList<PVector> corners4 = new ArrayList<PVector>();
           corners4.add(new PVector(initP.x+sizeBlock,initP.y+sizeBlock));
           corners4.add(new PVector(initP.x+sizeBlock*2,initP.y+sizeBlock));
           corners4.add(new PVector(initP.x+sizeBlock*2,initP.y+sizeBlock*2));
           corners4.add(new PVector(initP.x+sizeBlock,initP.y+sizeBlock*2));
           Block latent4 = new Block(1,corners4, colorNames.get(3));
           bloques.add(latent1);
           bloques.add(latent2);
           bloques.add(latent3);
           bloques.add(latent4);
           BlockGroup b = new BlockGroup(index, bloques);
           this.groups.add(b);
           index ++;
           initP.x += sizeT;
         }
       }
       initP.x = 10;
       initP.y += sizeBlock * 4;
     }
    }
  }