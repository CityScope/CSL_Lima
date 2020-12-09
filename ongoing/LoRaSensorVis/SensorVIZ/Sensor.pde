import java.util.Observer;

/**
 * Kind of a facade to create and manage all the sensors
 * @author      Guillem Francisco
 * @modified    Jesús García
 * @version     0.2
 */
public class Sensors {
  private final ArrayList<Sensor> SENSORS = new ArrayList<Sensor>();


  /**
   * Initiate sensors facade
   * @param file      JSON file direction
   * @param client    MQTTClient in which we will add some observers
   * @param surface   WarpSurface in which we will add some observers
   * @param sql       MySQLClient in which we will add some observers
   */
  public Sensors(String file, MQTTClient client, WarpSurface surface, MySQLClient sql) {
    load(file, client, surface, sql);
  }


  /**
   * Create sensors Objects from JSON file and add observers to MQTTClient, MySQLClient and WarpSurface
   * @param file    JSON file direction
   * @param client    MQTTClient in which we will add some observers
   * @param surface   WarpSurface in which we will add some observers
   * @param sql       MySQLClient in which we will add some observers 
   */
  private void load(String file, MQTTClient client, WarpSurface surface, MySQLClient sql) {
    processing.data.JSONObject object = loadJSONObject(file);
    processing.data.JSONArray sensors = object.getJSONArray("sensors");

    for (int i = 0; i < sensors.size(); i++) {
      processing.data.JSONObject sensor = sensors.getJSONObject(i);

      String id = sensor.getString("deviceID");
      String type = sensor.getString("type");
      processing.data.JSONArray variables = sensor.getJSONArray("variables");
      String[] vrbls = {};

      for (int j = 0; j < variables.size(); j++) {
        vrbls = append(vrbls, variables.getString(j));
      }

      if (type.equals("GPSTempHum")) {
        GPSTempHum newSensor = new GPSTempHum(id, vrbls);
        MySQLSensor newMySQL = new MySQLSensor(id, vrbls);

        SENSORS.add(newSensor);
        SENSORS.add(newMySQL);

        client.addObserver(newSensor);

        surface.addObserver(newSensor);

        sql.addObserver(newMySQL);
      }
    }
  }


  /**
   * Gets the list of Sensor objects
   * @returns ArrayList of Sensor objects
   */
  public ArrayList<Sensor> getSensors() {
    return SENSORS;
  }
}


/**
 * Sensor - Abstract Observer object that represents a generic sensor. It has the specified variables and
 * updates them when a new value is collected
 * @author    Guillem Francisco
 * @modified  Jesús García
 * @version   0.2
 */
public abstract class Sensor implements Observer {
  protected final String ID;
  protected Table variablesValues = new Table();
  protected boolean historical;
  protected boolean selected;


  /**
   * Initiates sensor with parameters that define itself
   * @param id           ID of the sensor
   * @param variables    Variables that the sensor is gathering
   */
  public Sensor(String id, String[] variables) {
    ID = id;
    createTable(variables);
  }


  /**
   * Initiates table with the keys provided in the constructor
   * @param sensorVariables String array with all the keys
   */
  private void createTable (String[] sensorVariables) {
    for (int i = 0; i < sensorVariables.length; i++) {
      variablesValues.addColumn(sensorVariables[i]);
    }
  }


  /**
   * Returns table with variables and values of each
   * @returns Table with the variables and values
   */
  protected Table getVariablesValues() {
    return variablesValues;
  }


  /**
   * Gets the type of the sensor
   * @returns true if is historical, false otherwise
   */
  protected boolean getType() {
    return historical;
  }


  /**
   * Gets the status of the sensor
   * @returns true if it has been selected, false otherwise
   */
  protected boolean getStatus() {
    return selected;
  }


  /**
   * Observer function that updates values of the table
   * @param obs Observable from which we are getting the data
   * @param obj Object the Observable is sending
   */
  public abstract void update(Observable obs, Object obj);
}


/**
 * GPSTempHum - Extended object represents a sensor with gps, temperature and humidity variables
 * @author    Guillem Francisco
 * @modified  Jesús García
 * @version   0.2
 */
public class GPSTempHum extends Sensor {
  private TableRow valuesRow;


  /**
   * Initiate sensor with parameters that define itself
   * @param id          ID of the sensor
   * @param variables   Variables that the sensor is gathering
   */
  public GPSTempHum(String id, String[] variables) {
    super(id, variables);
    valuesRow = variablesValues.addRow();

    for (int i = 0; i < variables.length; i++) {
      valuesRow.setFloat(variables[i], 0);
    }

    variablesValues.addColumn("plat");
    variablesValues.addColumn("plon");

    valuesRow.setFloat("plat", 0);
    valuesRow.setFloat("plon", 0);

    historical = false;
  }


  /**
   * Observer function which performs certain updates depending on the Observable that sent the data
   * @param obs Observable from which we are getting the data
   * @param obj Object the Observable is sending
   */
  @Override
    public void update(Observable obs, Object obj) {
    if (obs instanceof MQTTClient) updateValues(obj);
    else select(obj);
  }


  /**
   * Updates values of the table
   * @param obj Object the Observable is sending
   */
  private void updateValues(Object obj) {
    processing.data.JSONObject payload = (processing.data.JSONObject)obj;
    String sensorID = payload.getString("dev_id");

    if (sensorID.equals(ID)) {
      processing.data.JSONObject payloadFields = payload.getJSONObject("payload_fields");
      String[] columns = variablesValues.getColumnTitles();

      valuesRow.setFloat("plat", valuesRow.getFloat("lat"));
      valuesRow.setFloat("plon", valuesRow.getFloat("lon"));

      for (int i = 0; i < columns.length; i++) {
        if (!payloadFields.isNull(columns[i])) {
          float value = payloadFields.getFloat(columns[i]);
          valuesRow.setFloat(columns[i], value);
        }
      }
    }
  }


  /**
   * Updates the value of selected
   * @param obj Object the Observable is sending
   */
  private void select(Object obj) {
    LatLon location = (LatLon) obj;
    LatLon lastPos = new LatLon(valuesRow.getFloat("plat"), valuesRow.getFloat("plon"));
    LatLon currPos = new LatLon(valuesRow.getFloat("lat"), valuesRow.getFloat("lon"));

    selected = ((lastPos.dist(location) < 20) || (currPos.dist(location) < 20));
  }
}


/**
 * MySQLSensor - Extends Sensor. Represents the historically collected values of a sensor
 * @author    Jesús García
 * @version   0.2
 */
public class MySQLSensor extends Sensor {


  /**
   * Creates a MySQLSensor object
   * @param id          ID of the sensor
   * @param variables   Variables of interest for the sensor
   */
  public MySQLSensor(String id, String[] variables) {
    super(id, variables);
    historical = true;
  }


  /**
   * Observer function that updates values of the table
   * @param obs Observable from which we are getting the data
   * @param obj Object the Observable is sending
   */
  @Override
    public void update(Observable obs, Object obj) {
    MySQL result = (MySQL) obj;
    variablesValues.clearRows();

    while (result.next()) {
      if (result.getString("deviceID").equals(ID)) {

        String[] columns = variablesValues.getColumnTitles();
        TableRow valuesRow = variablesValues.addRow();

        for (int i = 0; i < columns.length; i++) {
          float value = result.getFloat(columns[i]);
          valuesRow.setFloat(columns[i], value);
        }
      }
    }
  }
}
