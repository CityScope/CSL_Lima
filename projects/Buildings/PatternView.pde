/**
* estadictic_graphics - templates for different kinds of graphics changing with time
* @author        Javier Zarate
* @version       2.0
*/
public class Patterns extends PApplet{
  int w;
  int h;
  PGraphics canvasPattern;
  //PatternBlock patternBlocks;
  public Patterns(PGraphics canvasPattern, int w, int h){
    this.w = w;
    this.h = h;
    this.canvasPattern = canvasPattern;
  }
  
  public void settings(){
    size(this.w,this.h);
  }

  public void setup(){
    colorMode(HSB,360,100,100);
    canvasPattern = createGraphics(this.w, this.h);
    patternBlocks = new PatternBlocks(canvasPattern, 10);
  }
  
  public void draw(){
    canvasPattern.beginDraw();
    canvasPattern.background(255);
    //createPallet(canvasPattern, 9);
    patternBlocks.draw(canvasPattern);
    canvasPattern.endDraw();
    image(canvasPattern, 0, 0);
  }
  
  public void mouseClicked(){
    patternBlocks.selected(mouseX,mouseY);
  }
}

  public class Block{
    ArrayList<PVector> corners = new ArrayList<PVector>();
    String colors;
    color ownColor = color(255);
    int id;
    int colorIndex = 0;
    public Block(int id, ArrayList<PVector> corners, String colorName){
      this.id = id;
      this.corners = corners;
      this.ownColor = color(config.colorLimits.get(0).getColor());
      //colors = config.colorLimits.get(0).name;
      this.colors = colorName;
      this.getColorFromName();      
    }
    
    void getColorFromName(){
      for(Color col : config.colorLimits){
        if(col.name.equals(this.colors)){
          this.ownColor = col.stdColor;
        }
      }
    }
    
    void draw(PGraphics canvas){
      canvas.stroke(0);
      canvas.fill(ownColor);
      canvas.beginShape();
      canvas.vertex(this.corners.get(0).x,this.corners.get(0).y);
      canvas.vertex(this.corners.get(1).x,this.corners.get(1).y);
      canvas.vertex(this.corners.get(2).x,this.corners.get(2).y);
      canvas.vertex(this.corners.get(3).x,this.corners.get(3).y);
      canvas.endShape(CLOSE);
    }
    
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
        this.ownColor = color(config.colorLimits.get(colorIndex).getColor());
        this.colors = config.colorLimits.get(colorIndex).name;
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
        canvas.text(block.colors + " ",this.cornerBL.x + spaceText, cornerBL.y + 10 );
        spaceText += 30;
      }
    }
    
   public void selected(int x, int y){
     for (Block b : this.blocks){
       b.selected(x,y);
     }
   }
  }
  
  
  public class PatternBlocks{
    ArrayList<BlockGroup> groups = new ArrayList<BlockGroup>();
    ArrayList<ArrayList<String>> patternString = new ArrayList<ArrayList<String>>();
    PGraphics canvas;
    public PatternBlocks(PGraphics canvas, int blocks){
      this.canvas = canvas;
      this.createPallet(canvas, blocks);
    }
    
    public void getColorString(){
      this.patternString = new ArrayList<ArrayList<String>>();
      for(BlockGroup blockGroup : groups){
        ArrayList<String> patternLatent = new ArrayList<String>();
        for (Block block : blockGroup.blocks){
          patternLatent.add(block.colors);
        }
        this.patternString.add(patternLatent);
      }
    }
    
    void draw(PGraphics canvas){
      for(BlockGroup blockGroup : groups){
        blockGroup.draw(canvas);
      }
    }
    
   public void selected(int x, int y){
     for (BlockGroup b : this.groups){
       b.selected(x,y);
     }
     config.patterns = this.patternString;
     mesh.actualizeString();
   }
   
   
   
   public void createPallet(PGraphics canvas, int blocks){
     int sizeT = 160;
     int xStep = canvas.width / sizeT;
     int yStep = canvas.height / sizeT;
     int sizeBlock = 20;
     PVector initP = new PVector(10,60);
     int index= 0;
     
     for(int j = 0; j < yStep; j++){
       for(int i = 0; i < xStep; i ++){
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
       initP.x = 10;
       initP.y += sizeT;
     }
    }
  }