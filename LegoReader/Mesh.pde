public class Cells{
  ArrayList<PVector> corners = new ArrayList();
  color ownColor;
  PVector center;
  int[] counter; 
  int movilAverageRange;
  IntList indexes;
  public Cells(ArrayList<PVector> corners){
      this.corners = corners;
      setCenter();
      this.ownColor = color(random(0,255),random(0,255),random(0,255));
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
  public color movilAverage(){
    int indexMax = 0;
    int maxCount = 0;
    for(int i = 0; i < this.counter.length; i++){
      if (maxCount < this.counter[i]){
        maxCount = this.counter[i];
        indexMax = i;
      }
    }
    return this.gettingColor(indexMax, config.colorLimits);
  }
  
  
  /**
  *Get the color "i" in colorLimits
  **/
  public color gettingColor(int index, ArrayList<Color> colorLimits){
    Color col = colorLimits.get(index);
    color newCol = color(col.getColor().x,col.getColor().y,col.getColor().z);
    return newCol;
  }
  
  
  /**
  *draw the cells with its own color in the canvas
  *depend of the value of withColor to render its color or none.
  **/
  void draw(PGraphics canvas, boolean withColor){
    canvas.stroke(1);
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
           if(c == color(colorL.getColor().x,colorL.getColor().y,colorL.getColor().z)){
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
        this.ownColor = movilAverage();
      } 
    }
  }
  
}


public class Mesh{
  int scl;
  PVector[][] malla;
  ArrayList<Cells> celdas = new ArrayList();
  int nblocks;  
  
  public Mesh(int nblocks, int w){
    this.nblocks = nblocks;
    this.scl = w/nblocks;
    this.malla = new PVector[nblocks+1][nblocks+1];
    this.create();
  }
  
  
  /**
  * Create all the "n" blocks with a specific width
  **/
  public void create(){
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
          celdas.add(new Cells(cornersTemp));
          
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
}