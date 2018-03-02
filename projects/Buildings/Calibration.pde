import processing.video.*;
import gab.opencv.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import java.util.Collections;

public class Calibration extends PApplet{
  PGraphics canvas;
  PGraphics canvasOriginal;
  PGraphics canvasColor;
  PGraphics lengedColor;
  PGraphics grayScale;
  PGraphics plano_e; 
  int sizeCanvas = 480; 
  PImage colorImage;
  PImage imageWrapped;
  PImage capture;
  float inc = 1;  
  Boolean refresh = false;
  ArrayList<PVector> posibles = new ArrayList();
  ArrayList<PVector> calibrationPoints = new ArrayList();
  
  Capture cam;
  OpenCV opencv;
  WrappedPerspective wrappedPerspective;
  Mesh mesh;

  Configuration config;
  Plano_edificio planos;
 
  public Calibration(){
    //this.setup();
  }
  
  public void settings(){
    size(sizeCanvas, sizeCanvas);
  }

  public void setup(){
    colorMode(HSB,360,100,100);
    String[] cameras = Capture.list();
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } else {
      canvas = createGraphics(sizeCanvas,sizeCanvas);
      canvasOriginal = createGraphics(sizeCanvas, sizeCanvas);
      canvasColor = createGraphics(sizeCanvas, sizeCanvas);
      grayScale = createGraphics(sizeCanvas, sizeCanvas);
      colorImage = createImage(sizeCanvas, sizeCanvas, HSB);
      imageWrapped = createImage(sizeCanvas, sizeCanvas, HSB);
      config = new Configuration("../LegoReader/data/calibrationParameters.json");
  
      config.loadConfiguration();
      mesh = new Mesh(config.nblocks, canvas.width,config);
  
      wrappedPerspective = new WrappedPerspective(config.contour);
      
      cam = new Capture(this,canvas.width, canvas.height, cameras[0]);
      cam.start();
  
      //blockReader = new BloackReader();
      String[] pled = {"Plano"};
      planos = new Plano_edificio(plano_e,sizeCanvas, config.nblocks, mesh.patternBlocks);
      PApplet.runSketch(pled, planos);      
      
      opencv = new OpenCV(this, cam);
      opencv.useColor(HSB);
      frameRate(5);
    }    
  }
  
  public void draw(){
    canvasOriginal.beginDraw();
    config.flip(canvasOriginal, cam, true);
    config.SBCorrection(canvasOriginal,config.brightnessLevel,config.saturationLevel);
    canvasOriginal.endDraw();
    
  
    //Filter colors with specific ranges
    config.applyFilter(canvasOriginal,colorImage);
    
    //canvas with the color processing and wrapped image
    colorImage.updatePixels();
    opencv.loadImage(colorImage);
    opencv.toPImage(wrappedPerspective.warpPerspective(sizeCanvas - config.resizeCanvas.get(0), sizeCanvas - config.resizeCanvas.get(1),opencv), imageWrapped);
    
    canvas.beginDraw();
    canvas.background(255);
    imageWrapped.resize(canvas.width - config.resizeCanvas.get(0), canvas.height - config.resizeCanvas.get(1));
    canvas.image(imageWrapped, 0, 0);
    mesh.getColors(canvas, config.colorLimits);
    //mesh.draw(canvas, false);
    canvas.endDraw();
   
    mesh.drawBlockReader(canvasColor);
    image(canvasColor, 0, 0);
  }
  
  void captureEvent(Capture cam){
    cam.read();
  }

}

//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------

public class Configuration{
  String path;
  ArrayList<PVector> contour;
  ArrayList<Color> colorLimits;
  float saturationLevel;
  float brightnessLevel;
  int nblocks; 
  IntList resizeCanvas = new IntList();
  
  Configuration(String path){
    this.path = path;
  }
  public void actualizeSizeCanvas(int w, int h){
    this.resizeCanvas= new IntList();
    resizeCanvas.append(w);
    resizeCanvas.append(h);
  }
  
  /**
  *flip Image
  **/
  public void flip(PGraphics canvas, Capture cam, boolean flip){
    if(flip){
      canvas.pushMatrix();
      canvas.scale(-1,1);
      canvas.image(cam, -canvas.width, 0);
      canvas.popMatrix();
    }else{
      canvas.image(cam, 0, 0);
    }
  }
  
  /**
  *Increase/decrease the brightness and saturation of the canvas
  **/
  public void SBCorrection(PImage canvas, float b, float s){
    canvas.loadPixels();
    for (int y = 0; y < canvas.height; y++) {
      for (int x = 0; x < canvas.width; x++) {
        int i = y*canvas.width + x;
        color actual = canvas.pixels[i];
        float h = hue(actual);
        float newS = saturation(actual);
        float newB = brightness(actual);
        newS += s;
        newB += b;
        canvas.set(x,y,color(h, newS, newB));
      }
    }
  }
  
  public void SBCorrection(PGraphics cam, float b, float s){
    cam.loadPixels();
    for (int y = 0; y < cam.height; y++) {
      for (int x = 0; x < cam.width; x++) {
        int i = y*cam.width + x;
        color actual = cam.pixels[i];
        float h = hue(actual);
        float newS = saturation(actual);
        float newB = brightness(actual);
        newS += s;
        newB += b;
        cam.set(x,y,color(h, newS, newB));
      }
    }
  }  
  
  /**
  *Asign a standar color in the range to every pixel in the canvas 
  *Black and white: comparing brightness and saturation in a HSV scale
  *Other Colors: comparing hue in a HSV scale
  *Specific parameters for white and Red
  **/    
  public void applyFilter(PGraphics cam, PImage colorimage){
    for(int x=0; x<cam.width;x++){
      for(int y=0; y<cam.height;y++){
        
        PVector colors = new PVector();
        float hue = hue(cam.get(x,y));
        float brightness = brightness(cam.get(x,y));
        float saturation = saturation(cam.get(x,y));
        boolean breakLoop = false;
        for(Color colorL: this.colorLimits){
          if(colorL.name.equals("white")){
            if( ( (saturation < colorL.satMax) & (brightness > colorL.briMin)) | ((saturation < colorL.satMax2) & (hue < colorL.maxHue) & (hue > colorL.hueMin)) ) {
            //if( ( (saturation < 15) & (brightness > 55)) | ((saturation < 50) & (hue < 70) & (hue > 30)) ){
              colors = colorL.getColor();
              breakLoop = true;
              break;
            }
          }else if(colorL.name.equals("black")){
            if( brightness < colorL.briMax | ( (brightness < colorL.briMax2 ) & (saturation  < colorL.satMax ) )){
            //if( brightness < 25 | ( (brightness < 40 ) & (saturation  < 15 ) )){  
              colors = colorL.getColor();
              breakLoop = true;
              break; 
            }
          }else{
            if((hue < colorL.maxHue)){
              colors = colorL.getColor();
              breakLoop = true;
              break;    
            }
          }
        }
        if(!breakLoop) colors = new PVector(colorLimits.get(2).getColor().x,colorLimits.get(2).getColor().y,colorLimits.get(2).getColor().z);
       
        colorimage.set(x,y,color(colors.x,colors.y,colors.z));
      }
     }
   }

  
  /**
  * load colors ranges, saturation, brightness and perspective calibration points.
  **/
  public void loadConfiguration(){
   ArrayList<Color> colorConf = new ArrayList();
   ArrayList<PVector> calibrationPoints = new ArrayList();
   JSONObject calibrationParameters =  loadJSONObject(this.path);
   JSONObject colorLimits = calibrationParameters.getJSONObject("Color Limits");
   for(int i=0; i<colorLimits.size(); i++){
     int id = colorLimits.getJSONObject(str(i)).getInt("id");
     String name = colorLimits.getJSONObject(str(i)).getString("name");
     float  maxHue = colorLimits.getJSONObject(str(i)).getFloat("maxHue");
     JSONArray stdColor = colorLimits.getJSONObject(str(i)).getJSONArray("standarHSV");

     if(name.equals("white")){
       float satMax = colorLimits.getJSONObject(str(i)).getFloat("satMax");
       float briMin = colorLimits.getJSONObject(str(i)).getFloat("briMin");
       float satMax2 = colorLimits.getJSONObject(str(i)).getFloat("satMax2");
       float hueMin = colorLimits.getJSONObject(str(i)).getFloat("hueMin");
       colorConf.add(new Color(id,maxHue, stdColor, name, satMax, briMin, satMax2,hueMin));    
     }else if(name.equals("black")){
       float briMax = colorLimits.getJSONObject(str(i)).getFloat("briMax");
       float briMax2 = colorLimits.getJSONObject(str(i)).getFloat("briMax2");
       float satMax = colorLimits.getJSONObject(str(i)).getFloat("satMax");
       colorConf.add(new Color(id, maxHue, stdColor, name, briMax, briMax2, satMax));  
     }else{
       colorConf.add(new Color(id, maxHue, stdColor, name));
     }
   }
   
   JSONObject points = calibrationParameters.getJSONObject("Calibration Points");
   for(int i=0; i<points.size(); i++){
     JSONArray point = points.getJSONArray(str(i));
     calibrationPoints.add(new PVector(point.getFloat(0), point.getFloat(1)));
   }
   JSONObject resize = calibrationParameters.getJSONObject("resizeCanvas");
   this.resizeCanvas.append(resize.getInt("rWa"));
   this.resizeCanvas.append(resize.getInt("rHa"));
   this.contour = calibrationPoints ;
   this.colorLimits = colorConf;
   this.nblocks = calibrationParameters.getInt("nblocks");
   this.saturationLevel = calibrationParameters.getFloat("Saturation");
   this.brightnessLevel = calibrationParameters.getFloat("Brightness");
 
   println("Calibration parameters loaded");
  } 

  
}

//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
public class Color{
  int id;
  float maxHue;
  JSONArray stdColor;
  String name;
  Boolean selectionMode;
  int n;
  float satMax;
  float briMin;
  float satMax2;
  float hueMin;
  float briMax;
  float briMax2;
  
  
  /**
  *Constructure for colors in hue scale
  **/
  public Color(int id, float maxHue, JSONArray stdColor, String name){
    this.n = 0;
    this.id = id;
    this.maxHue = maxHue;
    this.stdColor = stdColor;
    this.name = name;
    this.selectionMode = false;
  }

  /**
  *Constructure for white
  **/
  public Color(int id,float maxHue, JSONArray stdColor, String name, float satMax, float briMin, float satMax2, float hueMin){
    this.n = 0;
    this.id = id;
    this.maxHue = maxHue;
    this.stdColor = stdColor;
    this.name = name;
    this.selectionMode = false;
    this.satMax = satMax;
    this.briMin = briMin;
    this.satMax2 = satMax2;
    this.hueMin = hueMin;
  }

  /**
  *Constructure for black
  **/
  public Color(int id,float maxHue, JSONArray stdColor, String name, float briMax, float briMax2, float satMax){
    this.n = 0;
    this.id = id;
    this.maxHue = maxHue;
    this.stdColor = stdColor;
    this.name = name;
    this.selectionMode = false;
    this.briMax = briMax;
    this.briMax2 = briMax2;
    this.satMax = satMax;
  }

  
  /**
  *Return a PVector with hue,saturation and brightness respectively
  **/   
   public PVector getColor(){
     return new PVector(this.stdColor.getInt(0),this.stdColor.getInt(1),this.stdColor.getInt(2));
   }
   
   
  /**
  *Change selectionMode of the Color to calibration mode
  **/ 
   public void changeMode(){
    this.selectionMode = !selectionMode;
    print(true);
   }
}

//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
public class Cells{
  ArrayList<PVector> corners = new ArrayList();
  color ownColor;
  PVector center;
  int[] counter; 
  int movilAverageRange;
  IntList indexes;
  int id;
  String colorName;
  Configuration config;
  //ArrayList<Color> colorLimits;
    
  public Cells(int id, ArrayList<PVector> corners, Configuration config){
      this.corners = corners;
      this.id = id;
      this.config = config;
      setCenter();
      this.ownColor = color(random(0,255),random(0,255),random(0,255));
      this.settingCounter();
      this.indexes = new IntList();
  }
  
  
  /**
  * Set the counter of the Cell to 0
  **/
  public void settingCounter(){
    this.counter = new int[config.colorLimits.size()];
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
    this.colorName = col.name;                        ///////<-- CAMBIAR-->/////////
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
    //canvas.text(str(id), center.x, center.y);
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
  ArrayList<Color> colorLimits;
  ArrayList<Cells> celdas = new ArrayList();
  int nblocks;  
  ArrayList<patternBlock> patternBlocks = new ArrayList<patternBlock>();
  Configuration config;
  
  public Mesh(int nblocks, int w, Configuration config){
    this.nblocks = nblocks;
    this.scl = w/nblocks;
    this.config = config;
    this.malla = new PVector[nblocks+1][nblocks+1];
    this.create();
    this.setSizePattern();
    
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
          celdas.add(new Cells(id,cornersTemp,config));
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
  
  
  void drawBlockReader(PGraphics canvasColor){
    canvasColor.beginDraw();
    canvasColor.background(255);
    this.draw(canvasColor, true);
    this.checkPattern();
    this.drawPattern(canvasColor);
    canvasColor.endDraw();
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
        patternBlocks.add(new patternBlock(cont,latent));
        //print(j+i," ",j+i+1," ",j+i+n," ", j+i+n+1);
        //println();
        cont++;
     }
    }
    //println(cont);
    
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
  int id;
  color ownColor = color(random(0,255),random(0,255),random(0,255));
  ArrayList colorPatterns = new ArrayList();
  int indexPattern = -1;
  boolean pattern = false;
  
  public patternBlock(int id, ArrayList<Cells> cells){
    this.id =id; 
    this.cells = cells;
    this.getCorners();
    this.setColorPattern();
  }
   
  
  public void getCorners(){
    PVector latent1 = cells.get(0).corners.get(0);
    PVector latent2 = cells.get(1).corners.get(3);
    PVector latent3 = cells.get(2).corners.get(1);
    PVector latent4 = cells.get(3).corners.get(2);
    this.corners.add(latent1);
    this.corners.add(latent2);
    this.corners.add(latent3);
    this.corners.add(latent4);
  }
  
  void draw(PGraphics canvas){
    /*
      for(PVector vector : corners){
        canvas.fill(this.ownColor);
        canvas.ellipse(vector.x,vector.y,20,20);
      }
      */
      canvas.fill(0);
      for(Cells celda : cells){
        //celda.draw(canvas, withColor);
        //canvas.fill(this.ownColor);
        //canvas.ellipse(celda.center.x,celda.center.y,10,10);
        canvas.textSize(7);canvas.stroke(#000000);canvas.fill(#000000);
        canvas.text(str(indexPattern), celda.center.x, celda.center.y);
      }
  }
  
  public void setColorPattern(){
    ArrayList<String> colorPattern1 = new ArrayList<String>(){{add("white"); add("blue"); add("white"); add("white");}};
    ArrayList<String> colorPattern2 = new ArrayList<String>(){{add("green"); add("white"); add("white"); add("white");}};
    ArrayList<String> colorPattern3 = new ArrayList<String>(){{add("white"); add("white"); add("green"); add("white");}};
    ArrayList<String> colorPattern4 = new ArrayList<String>(){{add("green"); add("green"); add("green"); add("green");}};
    ArrayList<String> colorPattern5 = new ArrayList<String>(){{add("white"); add("blue"); add("green"); add("white");}};
    ArrayList<String> colorPattern6 = new ArrayList<String>(){{add("blue"); add("yellow"); add("blue"); add("red");}};
    ArrayList<String> colorPattern7 = new ArrayList<String>(){{add("red"); add("red"); add("red"); add("red");}};
    colorPatterns.add(colorPattern1);
    colorPatterns.add(colorPattern2);
    colorPatterns.add(colorPattern3);
    colorPatterns.add(colorPattern4);
    colorPatterns.add(colorPattern5);
    colorPatterns.add(colorPattern6);
    colorPatterns.add(colorPattern7);
  }
  
  public void checkPattern(){
    this.pattern = false;
    int index = 0;
    for(int i = 0; i < colorPatterns.size(); i++){
      ArrayList<String> colorPattern = (ArrayList<String>)colorPatterns.get(i);
      boolean correct1 = true;
      boolean correct2 = true;
      boolean correct3 = true;
      boolean correct4 = true;
      
      //check 0123
      for(int j = 0 ; j < colorPattern.size(); j++){
        String namePattern = colorPattern.get(j);
        String nameCelda = cells.get(j).colorName;
        if(!namePattern.equals(nameCelda)){
          correct1 = false;
          break;
        }
      }
      
      //check 3210
      for(int j = 0 ; j < colorPattern.size(); j++){
        String namePattern = colorPattern.get(colorPattern.size()-1-j);
        String nameCelda = cells.get(j).colorName;
        if(!namePattern.equals(nameCelda)){
          correct2 = false;
          break;
        }
      }

      //check 1302
      if(colorPattern.size() == 4){
        boolean verify1 =  colorPattern.get(1).equals(cells.get(0).colorName);
        boolean verify2 =  colorPattern.get(3).equals(cells.get(1).colorName);
        boolean verify3 =  colorPattern.get(0).equals(cells.get(2).colorName);
        boolean verify4 =  colorPattern.get(2).equals(cells.get(3).colorName);
        if(!(verify1 && verify2 && verify3 && verify4)){ correct3 = false;}
      }
      
      //check 2031
      if(colorPattern.size() == 4){
        boolean verify1 =  colorPattern.get(2).equals(cells.get(0).colorName);
        boolean verify2 =  colorPattern.get(0).equals(cells.get(1).colorName);
        boolean verify3 =  colorPattern.get(3).equals(cells.get(2).colorName);
        boolean verify4 =  colorPattern.get(1).equals(cells.get(3).colorName);
        if(!(verify1 && verify2 && verify3 && verify4)){ correct4 = false;}
      }
      
      if(correct1 || correct2 || correct3 || correct4){this.indexPattern = index; this.pattern = true; break;}
      index += 1;
    }
    if(!pattern){this.indexPattern = -1;}
  }
  
}

//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
public class WrappedPerspective{
  ArrayList<PVector> contour = new ArrayList();
  PVector pointSelected;
  boolean selected;
  
  public WrappedPerspective(ArrayList<PVector> contour){
    this.contour = contour;
    this.selected = false;
  }
  
  Mat getPerspectiveTransformation(ArrayList<PVector> inputPoints, int w, int h) {
    Point[] canonicalPoints = new Point[4];
    canonicalPoints[0] = new Point(w, 0);
    canonicalPoints[1] = new Point(0, 0);
    canonicalPoints[2] = new Point(0, h);
    canonicalPoints[3] = new Point(w, h);
  
    MatOfPoint2f canonicalMarker = new MatOfPoint2f();
    canonicalMarker.fromArray(canonicalPoints);
  
    Point[] points = new Point[4];
    for (int i = 0; i < 4; i++) {
      points[i] = new Point(inputPoints.get(i).x, inputPoints.get(i).y);
    }
    MatOfPoint2f marker = new MatOfPoint2f(points);
    return Imgproc.getPerspectiveTransform(marker, canonicalMarker);
  }
  
  
  Mat warpPerspective( int w, int h, OpenCV opencv) {
    Mat transform = getPerspectiveTransformation(this.contour, w, h);
    Mat unWarpedMarker = new Mat(w, h, CvType.CV_8UC1);    
    Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
    return unWarpedMarker;
  }
}

public class Plano_edificio extends PApplet {

  int w = 800;
  int h = 800;
  float x0;
  float y0;
  float zoom = 1;
  float angleZ = radians(30);
  float angleX = radians(30);
  Boolean selected = false;
  PGraphics canvas;
  ArrayList<PVector> buildingType;
  Plano plano;
  
  Plano_edificio(PGraphics canvas, int sizeCanvas, int nblocks, ArrayList<patternBlock> patternBlocks){
    this.canvas = canvas;
    plano = new Plano(sizeCanvas, nblocks,patternBlocks);
  }

  public void settings() {
    size(this.w, this.h,P3D);
  }
  
  public void setup(){
    smooth();
    //noStroke();
    colorMode(HSB,360,100,100);
    x0 = this.w/2;
    y0 = this.h/2;
    canvas = createGraphics(this.w,this.h,P3D);
  }
  
  public void draw(){
    canvas.beginDraw();
    canvas.background(0,0,10);
    canvas.translate(x0,y0);
    canvas.lights();
    canvas.noFill(); canvas.stroke(#818181);canvas.strokeWeight(2);
    canvas.scale(zoom);
    canvas.rotateX(angleX);
    canvas.rotateZ(angleZ);
    plano.draw(canvas);
    canvas.endDraw();
    image(canvas,0,0);
  }

  
  public void keyPressed(KeyEvent e){
    switch(key){
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
      selected = !selected;
      break;
      
    }
    switch(e.getKeyCode()){
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
  
  public void mouseDragged(){
    x0 = x0 + (mouseX - pmouseX);
    y0 = y0 + (mouseY - pmouseY);
  }
  
}

//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------------------
public class Plano{
  int sizeCanvas;
  int nblocks;
  int scl;
  float variancia;
  ArrayList<patternBlock> patternBlocks;
  PVector[][] malla;  
  HashMap<Integer,PVector> hm = new HashMap<Integer,PVector>();
  
  public Plano(int sizeCanvas, int nblocks,ArrayList<patternBlock> patternBlocks){
    this.sizeCanvas = sizeCanvas;
    this.scl = (sizeCanvas/nblocks) * 2;
    this.nblocks = nblocks;
    this.malla = new PVector[nblocks+1][nblocks+1];     
    this.patternBlocks = patternBlocks;
    asignType();
  }

  public void draw(PGraphics canvas){
    canvas.pushMatrix();
    //canvas.translate(-scl/variancia,-scl/variancia,-scl/variancia);
    //canvas.translate(-scl/variancia-scl/variancia,-scl/variancia);
    canvas.fill(#D4D3D3);
    canvas.rect(0,0,sizeCanvas,sizeCanvas);
    create(canvas);
    canvas.popMatrix();
    createBuildings(canvas);
  }
  
  public void asignType(){
    int a = patternBlocks.get(0).colorPatterns.size();
    for(int i=0; i<a;i++){
      if(i==0) hm.put(i, new PVector(i+2,4));
      if(i==1) hm.put(i, new PVector(i+2,4));
      if(i==2) hm.put(i, new PVector(i+2,4));
      if(i==3) hm.put(i, new PVector(i+2,3));
      if(i==4) hm.put(i, new PVector(i+2,4));
      if(i==5) hm.put(i, new PVector(i+2,4));
      if(i==6) hm.put(i, new PVector(i+2,4));
    }
    
    
    
  }
  
  public void create(PGraphics canvas){
    for(patternBlock p:patternBlocks){
      p.draw(canvas);
    }
  }
  
  public void createBuildings(PGraphics canvas){
    for(patternBlock p: patternBlocks){
      if(p.indexPattern != -1 ){
        PVector a = hm.get(p.indexPattern);
        Building b = new Building(a.x, a.y, scl, p.corners.get(0), p.cells);
        canvas.pushMatrix();
        int variancia = int(scl/ (a.y * 2 - 0.5));
        canvas.translate(variancia,variancia,variancia);
        b.draw(canvas);
        canvas.popMatrix();
      }      
    }
  }
  
  
}

public class Building{
  float roomSide;
  float numFloors;
  int scl;
  PVector loc;
  ArrayList<Cells> cells;
  
  Building(float numFloors, float roomSide,int scl, PVector loc, ArrayList<Cells> cells){
    this.roomSide = roomSide;
    this.numFloors = numFloors; 
    this.scl = scl;
    this.loc = new PVector(loc.x,0,loc.y);
    this.cells = cells;
  }
  
  public void draw(PGraphics canvas){
   for(int y=0; y<numFloors; y++){
     for(int x=0; x<roomSide; x++ ){
       for(int z=0; z<roomSide; z++){
         float ratio = scl/roomSide;
         if( x == 0 | x == roomSide - 1| z == 0 | z == roomSide - 1){
           //ClassRoom(b,pos.x + x*newR,  pos.z + z*newR,pos.y+ floorNumber *newR,newR,rooms.get(x+z))
           PVector pos = new PVector(loc.x + x*ratio,  loc.z + z*ratio,loc.y+ y *ratio);
           canvas.pushMatrix();
           //canvas.fill(#FFFFFF,90);
           canvas.fill(#FFFFFF);
           if(y == numFloors-1) canvas.fill(asignColor(x,z));
           canvas.translate(pos.x,pos.y,pos.z);
           canvas.box(ratio);
           canvas.popMatrix();
         }
       }
     }
   } 
  }
  
  public color asignColor(int x,int y){
    color col = color(#FFFFFF);
    if(x == 0 && y == 0) col = cells.get(0).ownColor;
    if(x == roomSide-1 && y == 0) col = cells.get(1).ownColor;
    if(x == roomSide-1 && y == roomSide-1) col = cells.get(3).ownColor;
    if(x == 0 && y == roomSide-1) col = cells.get(2).ownColor;
    return col;
  }  
}