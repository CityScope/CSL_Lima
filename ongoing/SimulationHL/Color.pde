/**
 * Color - Abstract class which holds the values shared amongst all the colors
 * @authors:   Javier Zárate & Vanesa Alcántara
 * @modified:  Jesús García
 * @version:   1.1
 */
public abstract class Color {
  protected int ID;
  protected String ACRONYM;
  protected String NAME;
  protected color STD;
  protected float MAXHUE;
  protected boolean SELECTED;
  protected int COUNTER = 0;


  /**
   * Initiates Color class with values retrieved from a JSONObject
   * @param: obj  JSONObject that stores values for different colors
   */
  public Color(JSONObject obj) {
    ID = obj.getInt("id");
    ACRONYM = obj.getString("acronym");
    NAME = obj.getString("name");

    JSONArray hsv = obj.getJSONArray("standarHSV");
    STD = color(hsv.getInt(0), hsv.getInt(1), hsv.getInt(2));

    MAXHUE = obj.getFloat("maxHue");
  }


  /**
   * Gets the value of the ACRONYM attribute
   * @returns: String  Value of ACRONYM
   */
  protected String getAcronym() {
    return ACRONYM;
  }


  /**
   * Gets the value of the SELECTED attribute
   * @returns: boolean  True - It's selected / False - It's not selected
   */
  protected boolean getSelected() {
    return SELECTED;
  }


  /**
   * Gets the value of the MAXHUE attribute
   * @returns: float  Value of MAXHUE
   */
  protected float getMaxHue() {
    return MAXHUE;
  }


  /**
   * Sets the value of the MAXHUE attribute
   * @param: maxHue  New value of MAXHUE
   */
  protected void setMaxHue(float maxHue) {
    MAXHUE = maxHue;
  }


  /**
   * Gets the value of the COUNTER attribute
   * @returns: int  Value of COUNTER
   */
  protected int getCounter() {
    return COUNTER;
  }


  /**
   * Increases the value of the COUNTER attribute by 1
   */
  protected void setCounter() {
    COUNTER++;
  }


  /**
   * Sets the value of COUNTER to 0
   */
  protected void resetCounter() {
    COUNTER = 0;
  }


  /**
   * Gets the value of the ID attribute
   * @returns: int  Value of ID
   */
  protected int getID() {
    return ID;
  }


  /**
   * Gets the value of the NAME attribute
   * @returns: String  Value of NAME
   */
  protected String getColorName() {
    return NAME;
  }


  /**
   * Gets the value of the STD attribute (HSB format)
   * @returns: Value of STD
   */
  protected color getColor() {
    return STD;
  }


  /**
   * Changes selectionMode of the Color to calibration mode
   */
  protected void changeMode() {
    SELECTED = !SELECTED;
  }
}


/**
 * White - Class which specifically represents the color white and its associated values. Extends the Color class
 * @author:    Jesús García
 * @see:       Color
 * @version:   1.0
 */
public class White extends Color {
  private float MINHUE;
  private float MAXSAT;
  private float MAXSAT2;
  private float MINBRI;


  /**
   * Creates an instance of White with values retrieved from a JSONObject
   * @param: obj  JSONObject that stores values for different colors
   */
  public White(JSONObject obj) {
    super(obj);
    MINHUE = obj.getFloat("minHue");
    MAXSAT = obj.getFloat("maxSat");
    MAXSAT2 = obj.getFloat("maxSat2");
    MINBRI = obj.getFloat("minBri");
  }


  /**
   * Gets the value of the MINHUE attribute
   * @returns: Value of MINHUE
   */
  public float getMinHue() {
    return MINHUE;
  }


  /**
   * Sets the value of the MINHUE attribute
   * @param: minHue  New MINHUE value
   */
  public void setMinHue(float minHue) {
    MINHUE = minHue;
  }


  /**
   * Gets the value of the MAXSAT attribute
   * @returns: Value of MAXSAT
   */
  public float getMaxSat() {
    return MAXSAT;
  }


  /**
   * Sets the value of the MAXSAT attribute
   * @param: maxSat  New MAXSAT value
   */
  public void setMaxSat(float maxSat) {
    MAXSAT = maxSat;
  }


  /**
   * Gets the value of the MAXSAT2 attribute
   * @returns: Value of MAXSAT2
   */
  public float getMaxSat2() {
    return MAXSAT2;
  }


  /**
   * Sets the value of the MAXSAT2 attribute
   * @param: maxSat2  New MAXSAT2 value
   */
  public void setMaxSat2(float maxSat2) {
    MAXSAT2 = maxSat2;
  }


  /**
   * Gets the value of the MINBRI attribute
   * @returns: Value of MINBRI
   */
  public float getMinBri() {
    return MINBRI;
  }


  /**
   * Sets the value of the MINBRI attribute
   * @param: minBri  New MINBRI value
   */
  public void setMinBri(float minBri) {
    MINBRI = minBri;
  }


  /**
   * Saves the current values of this object
   * @returns: JSONObject  A JSONObject with all the values
   */
  public JSONObject saveConfiguration() {
    JSONObject whiteLimit = new JSONObject();
    whiteLimit.setInt("id", ID);

    JSONArray hsv = new JSONArray();
    hsv.setFloat(0, hue(STD));
    hsv.setFloat(1, saturation(STD));
    hsv.setFloat(2, brightness(STD));
    whiteLimit.setJSONArray("standarHSV", hsv);

    whiteLimit.setString("acronym", ACRONYM);
    whiteLimit.setString("name", NAME);
    whiteLimit.setFloat("maxHue", MAXHUE);
    whiteLimit.setFloat("minHue", MINHUE);
    whiteLimit.setFloat("maxSat", MAXSAT);
    whiteLimit.setFloat("maxSat2", MAXSAT2);
    whiteLimit.setFloat("minBri", MINBRI);

    return whiteLimit;
  }
}


/**
 * Black - Class which specifically represents the color black and its associated values. Extends the Color class
 * @author:    Jesús García
 * @see:       Color
 * @version:   1.0
 */
public class Black extends Color {
  private float MAXSAT;
  private float MAXBRI;
  private float MAXBRI2;


  /**
   * Creates an instance of Black with values retrieved from a JSONObject
   * @param: obj  JSONObject that stores values for different colors
   */
  public Black(JSONObject obj) {
    super(obj);
    MAXSAT = obj.getFloat("maxSat");
    MAXBRI = obj.getFloat("maxBri");
    MAXBRI2 = obj.getFloat("maxBri2");
  }


  /**
   * Gets the value of the MAXSAT attribute
   * @returns: Value of MAXSAT
   */
  public float getMaxSat() {
    return MAXSAT;
  }


  /**
   * Sets the value of the MAXSAT attribute
   * @param: maxSat  New MAXSAT value
   */
  public void setMaxSat(float maxSat) {
    MAXSAT = maxSat;
  }


  /**
   * Gets the value of the MAXBRI attribute
   * @returns: Value of MAXBRI
   */
  public float getMaxBri() {
    return MAXBRI;
  }


  /**
   * Sets the value of the MAXBRI attribute
   * @param: maxBri  New MAXBRI value
   */
  public void setMaxBri(float maxBri) {
    MAXBRI = maxBri;
  }


  /**
   * Gets the value of the MAXBRI2 attribute
   * @returns: Value of MAXBRI2
   */
  public float getMaxBri2() {
    return MAXBRI2;
  }


  /**
   * Sets the value of the MAXBRI2 attribute
   * @param: maxBri2  New MAXBRI2 value
   */
  public void setMaxBri2(float maxBri2) {
    MAXBRI2 = maxBri2;
  }


  /**
   * Saves the current values of this object
   * @returns: JSONObject  A JSONObject with all the values
   */
  public JSONObject saveConfiguration() {
    JSONObject blackLimit = new JSONObject();
    blackLimit.setInt("id", ID);

    JSONArray hsv = new JSONArray();
    hsv.setFloat(0, hue(STD));
    hsv.setFloat(1, saturation(STD));
    hsv.setFloat(2, brightness(STD));
    blackLimit.setJSONArray("standarHSV", hsv);

    blackLimit.setString("acronym", ACRONYM);
    blackLimit.setString("name", NAME);
    blackLimit.setFloat("maxHue", MAXHUE);
    blackLimit.setFloat("maxSat", MAXSAT);
    blackLimit.setFloat("maxBri", MAXBRI);
    blackLimit.setFloat("maxBri2", MAXBRI2);

    return blackLimit;
  }
}


/**
 * Other - Class which specifically represents a color different to black or white and its associated values. Extends the Color class
 * @author:    Jesús García
 * @see:       Color
 * @version:   1.0
 */
public class Other extends Color {


  /**
   * Creates an instance of Other with values retrieved from a JSONObject
   * @param: obj  JSONObject that stores values for different colors
   */
  public Other(JSONObject obj) {
    super(obj);
  }


  /**
   * Saves the current values of this object
   * @returns: JSONObject  A JSONObject with all the values
   */
  public JSONObject saveConfiguration() {
    JSONObject otherLimit = new JSONObject();
    otherLimit.setInt("id", ID);

    JSONArray hsv = new JSONArray();
    hsv.setFloat(0, hue(STD));
    hsv.setFloat(1, saturation(STD));
    hsv.setFloat(2, brightness(STD));
    otherLimit.setJSONArray("standarHSV", hsv);

    otherLimit.setString("acronym", ACRONYM);
    otherLimit.setString("name", NAME);
    otherLimit.setFloat("maxHue", MAXHUE);

    return otherLimit;
  }
}
