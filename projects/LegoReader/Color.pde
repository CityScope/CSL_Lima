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