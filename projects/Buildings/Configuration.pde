/**
* estadictic_graphics - templates for different kinds of graphics changing with time
* @author        Vanesa Alcantara & Javier Zarate
* @version       2.0
*/
public class Configuration{
  String path;
  ArrayList<PVector> contour;
  ArrayList<Color> colorLimits;
  float saturationLevel;
  float brightnessLevel;
  int nblocks; 
  IntList resizeCanvas = new IntList();
  int actualSize;
  ArrayList<ArrayList<String>> patterns = new ArrayList<ArrayList<String>>();
  
  Configuration(int actualSize,String path){
    this.actualSize = actualSize;
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
        
        color colors = color(0,0,0);
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
        if(!breakLoop) colors = colorLimits.get(2).getColor();
        colorimage.set(x,y,colors);
      }
     }
   }

  
  /**
  * Safe colors ranges, saturation, brightness and perspective calibration points.
  **/
  public void safeConfiguration(ArrayList<Color> colors){ 
    JSONObject calibrationParameters = new JSONObject();
    JSONObject limitsColors = new JSONObject();
    for(Color col :colors){
        JSONObject limitColor = new JSONObject();
        limitColor.setInt("id",col.id);
        limitColor.setFloat("maxHue",col.maxHue); 
        JSONArray values = new JSONArray();
          values.setFloat(0,hue(col.stdColor));
          values.setFloat(1,saturation(col.stdColor));
          values.setFloat(2,brightness(col.stdColor));
        limitColor.setJSONArray("standarHSV",values );
        limitColor.setString("name",col.name);
        if(col.name.equals("white")){
              limitColor.setFloat("satMax",col.satMax);
              limitColor.setFloat("briMin",col.briMin);
              limitColor.setFloat("satMax2",col.satMax2);
              limitColor.setFloat("hueMax",col.maxHue);
              limitColor.setFloat("hueMin",col.hueMin);
        }
        if(col.name.equals("black")){
              limitColor.setFloat("briMax",col.briMax);
              limitColor.setFloat("briMax2",col.briMax2);
              limitColor.setFloat("satMax",col.satMax);          
        }
        limitsColors.setJSONObject(str(col.id),limitColor);
    }
    
    JSONObject calibrationPoints = new JSONObject();
    for(int i=0; i <this.contour.size();i++){
      JSONArray calibrationPoint = new JSONArray();
      calibrationPoint.setFloat(0,this.contour.get(i).x);
      calibrationPoint.setFloat(1,this.contour.get(i).y);
      calibrationPoints.setJSONArray(str(i),calibrationPoint);
    }
    
    JSONObject resize = new JSONObject();
    for(int i=0; i < this.resizeCanvas.size(); i++){
      resize.setInt("rWa", this.resizeCanvas.get(0));
      resize.setInt("rHa", this.resizeCanvas.get(1));
    }

    JSONObject patternsLatent = new JSONObject();
    int index = 0;
    for(ArrayList<String> pattern : patternBlocks.patternString){
      JSONArray patternValues = new JSONArray();
      int indexP = 0;
      for(String pat : pattern){
        patternValues.setString(indexP,pat);
        indexP += 1;
      }
      patternsLatent.setJSONArray(str(index), patternValues);
      index += 1;
    }    
    calibrationParameters.setJSONObject("Calibration Points", calibrationPoints);
    calibrationParameters.setInt("Canvas size", actualSize);  
    calibrationParameters.setJSONObject("Color Limits", limitsColors);
    calibrationParameters.setFloat("Saturation", this.saturationLevel);
    calibrationParameters.setFloat("Brightness", this.brightnessLevel);
    calibrationParameters.setInt("nblocks", nblocks);
    calibrationParameters.setJSONObject("resizeCanvas", resize);
    calibrationParameters.setJSONObject("Patterns", patternsLatent);
    
    saveJSONObject(calibrationParameters, this.path, "compact");
    println("Calibration parameters uploaded"); 
  }
  
  
  /**
  * load colors ranges, saturation, brightness and perspective calibration points.
  **/
  public void loadConfiguration(){
   ArrayList<ArrayList<String>> patternsLatent = new ArrayList<ArrayList<String>>();
   ArrayList<Color> colorConf = new ArrayList();
   ArrayList<PVector> calibrationPoints = new ArrayList();
   JSONObject calibrationParameters =  loadJSONObject(this.path);
   JSONObject colorLimits = calibrationParameters.getJSONObject("Color Limits");
   for(int i=0; i<colorLimits.size(); i++){
     int id = colorLimits.getJSONObject(str(i)).getInt("id");
     String name = colorLimits.getJSONObject(str(i)).getString("name");
     float  maxHue = colorLimits.getJSONObject(str(i)).getFloat("maxHue");
     JSONArray stdColorp = colorLimits.getJSONObject(str(i)).getJSONArray("standarHSV");
     color stdColor = color(stdColorp.getInt(0),stdColorp.getInt(1),stdColorp.getInt(2));

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
   int canvasSize = calibrationParameters.getInt("Canvas size");
   int factor = this.actualSize / canvasSize ;
   JSONObject points = calibrationParameters.getJSONObject("Calibration Points");
   for(int i=0; i<points.size(); i++){
     JSONArray point = points.getJSONArray(str(i));
     calibrationPoints.add(new PVector(point.getFloat(0) * factor , point.getFloat(1) * factor));
   }
   JSONObject resize = calibrationParameters.getJSONObject("resizeCanvas");
   JSONObject patterns = calibrationParameters.getJSONObject("Patterns");
   for(int i= 0; i < patterns.size(); i++){
     ArrayList<String> latent = new ArrayList<String>();
     JSONArray pattern = patterns.getJSONArray(str(i));
     for(int j = 0; j < pattern.size(); j++){
       latent.add(pattern.getString(j));
     }
     patternsLatent.add(latent);
   }
   this.patterns = patternsLatent;
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