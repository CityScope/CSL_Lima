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

public class Configuration {
  String path;
  ArrayList<PVector> contour;
  ArrayList<Color> colorLimits;
  Color colorW;
  Color colorB;
  ArrayList<Color> colorO;
  float saturationLevel;
  float brightnessLevel;
  int nblocks; 
  IntList resizeCanvas = new IntList();
  int actualSize;
  ArrayList<ArrayList<String>> patterns = new ArrayList<ArrayList<String>>();

  //UDP
  int PORT = 9877;
  String HOST_IP = "localhost"; //IP Address of the PC in which this App is running
  UDP udp; //Create UDP object for recieving
  String previousMess = "";

  Configuration(int actualSize, String path) {
    this.actualSize = actualSize;
    this.path = path;
    udp= new UDP(this);  
    udp.log(true);
    udp.listen(true);
  }

  public void updateSizeCanvas(int w, int h) {
    this.resizeCanvas= new IntList();
    resizeCanvas.append(w);
    resizeCanvas.append(h);
    
  }

  /**
    *Mirrors the image shown by the camera
  **/
  public void flip(PGraphics canvas, Capture cam, boolean flip) {
    if (flip) {
      canvas.pushMatrix();
      canvas.scale(-1, 1);
      canvas.image(cam, -canvas.width, 0);
      canvas.popMatrix();
    } else {
      canvas.image(cam, 0, 0);
    }
  }
    
  /**
    *Takes factorial of num
  **/
  public final int fact(int num) {
    return num == 1? 1 : fact(num - 1)*num;
  }

  /**
   *Checks if there is any other possible combination to create a new pattern
  **/
  public boolean possiblePatterns() {
    int total = fact(6)/(fact(4) * fact(2));
    if (config.patterns.size() < total) return true;
    return false;
  }

  /**
   *Restart every pixel counter for each color
  **/
  public void restartColors() {  
    for(Color c:colorLimits){
      c.n = 0;
    }
  }

  void receive(byte[] data){
    println("Processing received an unexpected message");   
  }
  
  void send(String message){
    //println("sending " + message + " to " + HOST_IP + " port:" + PORT);
    if(!message.equals(previousMess)){
      udp.send(message,HOST_IP,PORT);
      previousMess =message;
    }
    
  }

  /**
   *Export a JSONfile with pattern and cells color name
  **/
  public void exportGrid(ArrayList<patternBlock> patternBlocks, Patterns patterns) {
    JSONObject mesh = new JSONObject();
    JSONObject meta = new JSONObject();
    meta.setString("id", "AOpifOF");
    meta.setFloat("timestamp", millis());
    meta.setString("apiv", "2.1.0");
    JSONObject header = new JSONObject();
    header.setString("name", "cityscope_lima");
    JSONObject spatial = new JSONObject();
    spatial.setInt("nrows", this.nblocks);
    spatial.setInt("ncols", this.nblocks);
    spatial.setFloat("physical_longitude", -77);
    spatial.setFloat("physical_latitude", 12);
    spatial.setInt("longitude", -77);
    spatial.setInt("latitude", 12);
    spatial.setInt("cellSize", patterns.blockSize);
    spatial.setInt("rotation", 0);
    header.setJSONObject("spatial", spatial);
    JSONObject owner = new JSONObject();
    owner.setString("name", "Vanesa and Jesús");
    owner.setString("title", "Researcher");
    owner.setString("institute", "Pacific´s University");
    header.setJSONObject("owner", owner);
    JSONArray block = new JSONArray();
    block.setString(1, "type");
    block.setString(0, "rotation");
    header.setJSONArray("block", block);
    JSONObject type = new JSONObject();
    JSONObject mapping = new JSONObject();
    int j = 0;
    for (int i = 0; i < config.patterns.size(); i++) {
      type.setFloat(str(i), j);
      j++;
    }
    mapping.setJSONObject("type", type);
    header.setJSONObject("mapping", mapping);
    int k = 0;
    JSONArray grid = new JSONArray();
    for (int w = 0; w < patternBlocks.size(); w++) {
      JSONObject arrayValue = new JSONObject();
      arrayValue.setFloat("type", patternBlocks.get(w).indexPattern);
      arrayValue.setFloat("rotation", 0);
      grid.setJSONObject(k, arrayValue);
      k++;
    }
    header.setJSONArray("grid", grid);
    mesh.setJSONObject("meta", meta);
    mesh.setJSONObject("header", header);
    saveJSONObject(mesh, "data/grid.json");
    println("Grid exported.");
  }
  
  /**
  *Export a JSONfile with pattern and cells color name
  **/
  public void exportGridUDP(ArrayList<patternBlock> patternBlocks, Patterns patterns){
    String message = "";
    int k = 0;
    for (int w = 0; w < patternBlocks.size(); w++) {
      message = message + patternBlocks.get(w).indexPattern + ";";
      k++;
    }
    send(message);
    //println("UDP Grid exported.");    
  }

  /**
   *Save color ranges, saturation, brightness and perspective calibration points.
  **/
  public void saveConfiguration(ArrayList<Color> colors) { 
    JSONObject calibrationParameters = new JSONObject();
    JSONObject limitsColors = new JSONObject();
    for (Color col : colors) {
      JSONObject limitColor = new JSONObject();
      limitColor.setInt("id", col.id);
      limitColor.setFloat("maxHue", col.maxHue); 
      JSONArray values = new JSONArray();
      values.setFloat(0, hue(col.stdColor));
      values.setFloat(1, saturation(col.stdColor));
      values.setFloat(2, brightness(col.stdColor));
      limitColor.setJSONArray("standarHSV", values );
      limitColor.setString("name", col.name);
      limitColor.setString("acronym", col.acron);
      if (col.name.equals("white")) {
        limitColor.setFloat("satMax", col.satMax);
        limitColor.setFloat("briMin", col.briMin);
        limitColor.setFloat("satMax2", col.satMax2);
        limitColor.setFloat("hueMax", col.maxHue);
        limitColor.setFloat("hueMin", col.hueMin);
      }
      if (col.name.equals("black")) {
        limitColor.setFloat("briMax", col.briMax);
        limitColor.setFloat("briMax2", col.briMax2);
        limitColor.setFloat("satMax", col.satMax);
      }
      limitsColors.setJSONObject(str(col.id), limitColor);
    }

    JSONObject calibrationPoints = new JSONObject();
    for (int i=0; i <this.contour.size(); i++) {
      JSONArray calibrationPoint = new JSONArray();
      calibrationPoint.setFloat(0, this.contour.get(i).x);
      calibrationPoint.setFloat(1, this.contour.get(i).y);
      calibrationPoints.setJSONArray(str(i), calibrationPoint);
    }

    JSONObject resize = new JSONObject();
    for (int i=0; i < this.resizeCanvas.size(); i++) {
      resize.setInt("rWa", this.resizeCanvas.get(0));
      resize.setInt("rHa", this.resizeCanvas.get(1));
    }

    JSONObject patternsLatent = new JSONObject();
    int index = 0;
    for (ArrayList<String> pattern : patternBlocks.patternString) {
      JSONArray patternValues = new JSONArray();
      int indexP = 0;
      for (String pat : pattern) {
        patternValues.setString(indexP, pat);
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
    println("Calibration parameters saved.");
  }

  /**
   *Load color ranges, saturation, brightness and perspective calibration points.
  **/
  public void loadConfiguration() {
    ArrayList<ArrayList<String>> patternsLatent = new ArrayList<ArrayList<String>>();
    ArrayList<Color> colorConf = new ArrayList<Color>();
    Color colorW = null;
    Color colorB  = null;
    ArrayList<Color> colorO = new ArrayList();
    ArrayList<PVector> calibrationPoints = new ArrayList();
    JSONObject calibrationParameters =  loadJSONObject(this.path);
    JSONObject colorLimits = calibrationParameters.getJSONObject("Color Limits");
    
    for (int i=0; i<colorLimits.size(); i++) {
      int id = colorLimits.getJSONObject(str(i)).getInt("id");
      String name = colorLimits.getJSONObject(str(i)).getString("name");
      String acron = colorLimits.getJSONObject(str(i)).getString("acronym");
      float  maxHue = colorLimits.getJSONObject(str(i)).getFloat("maxHue");
      JSONArray stdColorp = colorLimits.getJSONObject(str(i)).getJSONArray("standarHSV");
      color stdColor = color(stdColorp.getInt(0), stdColorp.getInt(1), stdColorp.getInt(2));

      if (name.equals("white")) {
        float satMax = colorLimits.getJSONObject(str(i)).getFloat("satMax");
        float briMin = colorLimits.getJSONObject(str(i)).getFloat("briMin");
        float satMax2 = colorLimits.getJSONObject(str(i)).getFloat("satMax2");
        float hueMin = colorLimits.getJSONObject(str(i)).getFloat("hueMin");
        colorW = new Color(id, maxHue, stdColor, name, acron, satMax, briMin, satMax2, hueMin);
      } else if (name.equals("black")) {
        float briMax = colorLimits.getJSONObject(str(i)).getFloat("briMax");
        float briMax2 = colorLimits.getJSONObject(str(i)).getFloat("briMax2");
        float satMax = colorLimits.getJSONObject(str(i)).getFloat("satMax");
        colorB = new Color(id, maxHue, stdColor, name, acron, briMax, briMax2, satMax);
      } else {
        colorO.add(new Color(id, maxHue, stdColor, name, acron));
      }
    }
    int canvasSize = calibrationParameters.getInt("Canvas size");
    int factor = this.actualSize / canvasSize ;
    JSONObject points = calibrationParameters.getJSONObject("Calibration Points");
    
    for (int i = 0; i < points.size(); i++) {
      JSONArray point = points.getJSONArray(str(i));
      calibrationPoints.add(new PVector(point.getFloat(0) * factor, point.getFloat(1) * factor));
    }
    JSONObject resize = calibrationParameters.getJSONObject("resizeCanvas");
    JSONObject patterns = calibrationParameters.getJSONObject("Patterns");
    
    for (int i = 0; i < patterns.size(); i++) {
      ArrayList<String> latent = new ArrayList<String>();
      JSONArray pattern = patterns.getJSONArray(str(i));
      
      for (int j = 0; j < pattern.size(); j++) {
        latent.add(pattern.getString(j));
      }
      patternsLatent.add(latent);
    }
    colorConf.add(colorW);
    colorConf.add(colorB);
    colorConf.addAll(colorO);
    this.patterns = patternsLatent;
    this.resizeCanvas.append(resize.getInt("rWa"));
    this.resizeCanvas.append(resize.getInt("rHa"));
    this.contour = calibrationPoints ;
    this.colorLimits = colorConf;
    this.colorW = colorW;
    this.colorB = colorB;
    this.colorO = colorO;
    this.nblocks = calibrationParameters.getInt("nblocks");
    this.saturationLevel = calibrationParameters.getFloat("Saturation");
    this.brightnessLevel = calibrationParameters.getFloat("Brightness");
    println("Calibration parameters loaded.");
  }
}
