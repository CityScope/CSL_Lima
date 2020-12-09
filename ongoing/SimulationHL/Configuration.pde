/**
 * Configuration - Class to facilitate instantiation
 * @author        Javier Zárate
 * @version       1.0
 */

public class Configuration {
  String path;
  ArrayList<PVector> contour;
  ArrayList<Color> colorLimits;
  float saturationLevel;
  float brightnessLevel;

  public Configuration(String path) {
    this.path = path;
  }


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
   * Increase/decrease the brightness and saturation of the canvas
   */
  public void SBCorrection(PGraphics canvas) {
    canvas.loadPixels();
    for (int y = 0; y < canvas.height; y++) {
      for (int x = 0; x < canvas.width; x++) {
        int i = y * canvas.width + x;
        color actual = canvas.pixels[i];
        float h = hue(actual);
        float newS = saturation(actual);
        float newB = brightness(actual);
        newS += saturationLevel;
        newB += brightnessLevel;
        canvas.set(x, y, color(h, newS, newB));
      }
    }
  }


  /**
   * Asign a standar color in the range to every pixel in the canvas 
   * Black and white: comparing brightness and saturation in a HSV scale
   * Other Colors: comparing hue in a HSV scale
   * Specific parameters for white and Red
   */
  public void applyFilter(PImage colorImage) {
    for (int y = 0; y < colorImage.height; y++) {
      for (int x = 0; x < colorImage.width; x++) {
        int i = y * colorImage.width + x;
        color actual = colorImage.pixels[i];   

        float hue = hue(actual);
        float brightness = brightness(actual);
        float saturation = saturation(actual);
        boolean breakLoop = false;

        for (Color colorL : this.colorLimits) {
          String colorName = colorL.getColorName();
          if (colorName.equals("white")) {
            //if( ( (saturation < colorL.satMax) & (brightness > colorL.briMin)) | ((saturation < colorL.satMax2) & (hue < colorL.hueMax) & (hue > colorL.hueMin)) ) {
            if ( ( (saturation < 15) & (brightness > 55)) | ((saturation < 50) & (hue < 70) & (hue > 30)) ) {
              actual = colorL.getColor();
              breakLoop = true;
              break;
            }
          } else if (!breakLoop & colorName.equals("black")) {
            //if( brightness < colorL.briMax | ( (brightness < colorL.briMax2 ) & (saturation  < colorL.satMax ) )){
            if ( brightness < 25 | ( (brightness < 40 ) & (saturation  < 15 ) )) {  
              actual = colorL.getColor();
              breakLoop = true;
              break;
            }
          } else {
            if (!breakLoop & (hue < colorL.MAXHUE)) {
              actual = colorL.getColor();
              breakLoop = true;
              break;
            }
          }
        }
        if (!breakLoop) actual = color(0, 0, 100); ///// REMEMBER!

        colorImage.pixels[i] = actual;
      }
    }
  }


  /**
   * load colors ranges, saturation, brightness and perspective calibration points.
   */
  public void loadConfiguration() {
    ArrayList<Color> colorConf = new ArrayList<Color>();
    ArrayList<PVector> calibrationPoints = new ArrayList<PVector>();
    JSONObject calibrationParameters =  loadJSONObject(this.path);

    JSONArray colorLimits = calibrationParameters.getJSONArray("Color Limits");      
    for (int i = 0; i < colorLimits.size(); i++) {
      JSONObject c = colorLimits.getJSONObject(i);  
      String acronym = c.getString("acronym");  
      if (acronym.equals("W")) {
        White w = new White(c);
        colorConf.add(w);
      } else if (acronym.equals("BK")) {
        Black bl = new Black(c);
        colorConf.add(bl);
      } else {
        Other o = new Other(c);
        colorConf.add(o);
      }
    }

    JSONObject points = calibrationParameters.getJSONObject("Calibration Points");    
    for (int i = 0; i < points.size(); i++) {
      JSONArray point = points.getJSONArray(str(i));
      calibrationPoints.add(new PVector(point.getInt(0), point.getInt(1)));
    }

    this.contour = calibrationPoints;
    this.colorLimits = colorConf;
    this.saturationLevel = calibrationParameters.getFloat("Saturation");
    this.brightnessLevel = calibrationParameters.getFloat("Brightness");

    println("Calibration parameters loaded");
  }
}
